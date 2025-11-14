//===- ParamSpecialize.cpp - Clone symbols with constant params -*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/SymbolTable.h"
#include "mlir/IR/Matchers.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/Passes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"

#include "Dialect/Cal/CalOps.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "Transforms/Passes.h"

using namespace mlir;

namespace {

/// Pass that scans for cal.instantiate ops with at least one constant parameter
/// and produces a specialized clone of the referenced cal.actor or cal.network
/// symbol where those constant arguments are inlined as arith.constant values
/// in the region entry block. The instantiate op is retargeted to the clone.
///
/// This logic was originally embedded inside CalConstEval; extracting it lets
/// us run constant parameter specialization early (Stage B) while keeping
/// ConstJITResolve dedicated to JIT const-eval of expressions.
class ParamSpecializePass : public PassWrapper<ParamSpecializePass, OperationPass<ModuleOp>> {
public:
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(ParamSpecializePass)
  StringRef getArgument() const final { return "cal-param-specialize"; }
  StringRef getDescription() const final { return "Clone CAL symbols on constant parameter sets and retarget instantiations"; }

  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<arith::ArithDialect, cal::CalDialect>();
  }

  void runOnOperation() override {
    ModuleOp module = getOperation();
    SymbolTable symTable(module);

    llvm::StringMap<FlatSymbolRefAttr> specCache;

    auto valueToTypedAttr = [&](Value v) -> TypedAttr {
      if (!v) return {};
  Attribute a; if (matchPattern(v, m_Constant(&a))) if (auto ta = dyn_cast<TypedAttr>(a)) return ta;
      if (auto c = v.getDefiningOp<arith::ConstantOp>()) if (auto ta = dyn_cast<TypedAttr>(c.getValue())) return ta;
      // Small integer evaluator for simple arithmetic to treat derived ints as constants.
      std::function<std::optional<int64_t>(Value)> quickInt;
      quickInt = [&](Value vv) -> std::optional<int64_t> {
        if (auto kc = vv.getDefiningOp<arith::ConstantOp>())
          if (auto ia = dyn_cast<IntegerAttr>(kc.getValue())) return ia.getInt();
        if (auto ic = vv.getDefiningOp<arith::IndexCastOp>()) { auto x = quickInt(ic.getIn()); if (x) return *x; }
        if (auto ai = vv.getDefiningOp<arith::AddIOp>()) { auto A = quickInt(ai.getLhs()); auto B = quickInt(ai.getRhs()); if (A && B) return *A + *B; }
        if (auto si = vv.getDefiningOp<arith::SubIOp>()) { auto A = quickInt(si.getLhs()); auto B = quickInt(si.getRhs()); if (A && B) return *A - *B; }
        if (auto mi = vv.getDefiningOp<arith::MulIOp>()) { auto A = quickInt(mi.getLhs()); auto B = quickInt(mi.getRhs()); if (A && B) return (*A) * (*B); }
        if (auto cmp = vv.getDefiningOp<arith::CmpIOp>()) {
          auto A = quickInt(cmp.getLhs()); auto B = quickInt(cmp.getRhs()); if (!A || !B) return std::nullopt;
          using P = arith::CmpIPredicate; bool res = false;
          auto clampNN = [](int64_t v) -> uint64_t { return v < 0 ? static_cast<uint64_t>(0) : static_cast<uint64_t>(v); };
          switch (cmp.getPredicate()) {
            case P::eq: res = (*A == *B); break; case P::ne: res = (*A != *B); break; case P::slt: res = (*A < *B); break;
            case P::sle: res = (*A <= *B); break; case P::sgt: res = (*A > *B); break; case P::sge: res = (*A >= *B); break;
            // Treat negatives as 0 for unsigned predicates to model natural-number params and avoid underflow-induced growth.
            case P::ult: res = (clampNN(*A) < clampNN(*B)); break; case P::ule: res = (clampNN(*A) <= clampNN(*B)); break;
            case P::ugt: res = (clampNN(*A) > clampNN(*B)); break; case P::uge: res = (clampNN(*A) >= clampNN(*B)); break;
          }
          return res ? 1 : 0;
        }
        if (auto sel = vv.getDefiningOp<arith::SelectOp>()) {
          auto C = quickInt(sel.getCondition()); if (!C) return std::nullopt; return *C ? quickInt(sel.getTrueValue()) : quickInt(sel.getFalseValue());
        }
        return std::nullopt;
      };
      if (auto vInt = quickInt(v)) {
        Type ty = v.getType();
        if (auto it = dyn_cast<IntegerType>(ty)) return IntegerAttr::get(it, *vInt);
        if (isa<IndexType>(ty)) return IntegerAttr::get(IntegerType::get(v.getContext(), 64), *vInt);
        return IntegerAttr::get(IntegerType::get(v.getContext(), 64), *vInt);
      }
      return {};
    };

    // Local simplifier: fold const cmp/select, fold scf.if with const cond, and erase zero-trip scf.for in a region.
    auto locallySimplifyRegion = [&](Region &region) {
      if (region.empty()) return;
      bool changedLocal = true;
      while (changedLocal) {
        changedLocal = false;
        for (Block &b : region) {
          for (Operation &op : llvm::make_early_inc_range(b)) {
            // Fold arith.cmpi with constant-like operands
            if (auto cmp = dyn_cast<arith::CmpIOp>(&op)) {
              auto A = valueToTypedAttr(cmp.getLhs());
              auto B = valueToTypedAttr(cmp.getRhs());
              if (auto ia = dyn_cast_or_null<IntegerAttr>(A)) {
                if (auto ib = dyn_cast_or_null<IntegerAttr>(B)) {
                  // Reuse quick evaluator path via building a fake Select over constants
                  bool res = false; using P = arith::CmpIPredicate;
                  auto a = ia.getInt(); auto b = ib.getInt();
                  auto clampNN = [](int64_t v) -> uint64_t { return v < 0 ? static_cast<uint64_t>(0) : static_cast<uint64_t>(v); };
                  switch (cmp.getPredicate()) {
                    case P::eq: res = (a == b); break; case P::ne: res = (a != b); break; case P::slt: res = (a < b); break;
                    case P::sle: res = (a <= b); break; case P::sgt: res = (a > b); break; case P::sge: res = (a >= b); break;
                    case P::ult: res = (clampNN(a) < clampNN(b)); break; case P::ule: res = (clampNN(a) <= clampNN(b)); break;
                    case P::ugt: res = (clampNN(a) > clampNN(b)); break; case P::uge: res = (clampNN(a) >= clampNN(b)); break;
                  }
                  OpBuilder rb(cmp);
                  auto c = rb.create<arith::ConstantIntOp>(cmp.getLoc(), res ? 1 : 0, 1);
                  cmp.replaceAllUsesWith(c.getResult());
                  cmp.erase();
                  changedLocal = true;
                  continue;
                }
              }
            }
            // Fold arith.select with constant condition
            if (auto sel = dyn_cast<arith::SelectOp>(&op)) {
              if (auto ca = valueToTypedAttr(sel.getCondition())) {
                if (auto ci = dyn_cast<IntegerAttr>(ca)) {
                  Value repl = ci.getInt() ? sel.getTrueValue() : sel.getFalseValue();
                  sel.replaceAllUsesWith(repl);
                  sel.erase();
                  changedLocal = true; continue;
                }
              }
            }
            // Simplify scf.if with constant condition
            if (auto ifOp = dyn_cast<scf::IfOp>(&op)) {
              if (auto ca = valueToTypedAttr(ifOp.getCondition())) {
                if (auto ci = dyn_cast<IntegerAttr>(ca)) {
                  bool takeThen = ci.getInt() != 0;
                  Region &chosen = takeThen ? ifOp.getThenRegion() : ifOp.getElseRegion();
                  SmallVector<Value, 4> replVals;
                  // Gather yield operands for result replacement (if present)
                  if (!chosen.empty()) {
                    Block &cb = chosen.front();
                    if (auto y = dyn_cast<scf::YieldOp>(cb.getTerminator()))
                      replVals.append(y.getOperands().begin(), y.getOperands().end());
                  }
                  // Move chosen body ops (except terminator) before the ifOp
                  if (!chosen.empty()) {
                    for (Operation &inner : llvm::make_early_inc_range(chosen.front())) {
                      if (isa<scf::YieldOp>(&inner)) continue;
                      inner.moveBefore(ifOp);
                    }
                  }
                  // Replace results when counts match; otherwise drop results if unused.
                  if (ifOp->getNumResults() == replVals.size() && replVals.size() > 0) {
                    ifOp.replaceAllUsesWith(ValueRange{replVals});
                  } else if (ifOp->getNumResults() == 0) {
                    // nothing to replace
                  } else {
                    // If there are results but we couldn't produce replacements, skip folding here.
                    // Continue without erasing to avoid invalid IR.
                    continue;
                  }
                  ifOp.erase();
                  changedLocal = true; continue;
                }
              }
            }
            // Erase zero-trip scf.for (upper <= lower) by replacing results with iter_args
            if (auto forOp = dyn_cast<scf::ForOp>(&op)) {
              auto lowerC = valueToTypedAttr(forOp.getLowerBound());
              auto upperC = valueToTypedAttr(forOp.getUpperBound());
              auto stepC  = valueToTypedAttr(forOp.getStep());
              if (auto li = dyn_cast_or_null<IntegerAttr>(lowerC))
                if (auto ui = dyn_cast_or_null<IntegerAttr>(upperC))
                  if (auto si = dyn_cast_or_null<IntegerAttr>(stepC)) {
                    int64_t L = li.getInt(), U = ui.getInt(), S = std::abs(si.getInt());
                    if (S == 0) S = 1; // be safe
                    if (U <= L) {
                      // Zero-trip: replace results with iter operands
                      for (auto [res, init] : llvm::zip(forOp.getResults(), forOp.getInitArgs()))
                        res.replaceAllUsesWith(init);
                      forOp.erase();
                      changedLocal = true; continue;
                    }
                  }
            }
          }
        }
      }
    };

    auto buildKeyForSpec = [&](StringRef symName, ArrayRef<Value> actuals, int paramCount) -> std::string {
      std::string key; key.reserve(symName.size() + 32 + actuals.size() * 8);
      key.append(symName.str()); key.push_back('|');
      for (int i = 0; i < paramCount && i < (int)actuals.size(); ++i) {
        if (auto ta = valueToTypedAttr(actuals[i])) { std::string tmp; llvm::raw_string_ostream os(tmp); ta.print(os); os.flush(); key.append(tmp); }
        else key.push_back('-');
        key.push_back(';');
      }
      return key;
    };

    auto inlineConstantsIntoRegion = [&](Region &region, ArrayRef<Value> params, int paramCount) {
      if (region.empty()) return;
      Block &blk = region.front();
      OpBuilder b(module.getContext()); b.setInsertionPointToStart(&blk);
      for (int i = 0; i < paramCount && i < (int)blk.getNumArguments(); ++i) {
        if (auto ta = valueToTypedAttr(params[i])) {
          auto loc = blk.getArgument(i).getLoc();
          auto c = b.create<arith::ConstantOp>(loc, ta);
          blk.getArgument(i).replaceAllUsesExcept(c.getResult(), c);
        }
      }
    };

    bool changed = true; unsigned guard = 0, guardMax = 8;
    while (changed && guard++ < guardMax) {
      changed = false;
      // Worklist of instantiations to process in this sweep (including those appearing inside newly created clones).
      SmallVector<cal::InstantiateOp, 32> worklist;
      DenseSet<Operation *> seenInsts;

      auto considerInst = [&](cal::InstantiateOp inst) {
        if (!inst || seenInsts.contains(inst)) return;
        Operation *target = nullptr;
        if (auto net = symTable.lookupNearestSymbolFrom<cal::NetworkOp>(inst, inst.getActorRefAttr())) target = net.getOperation();
        else if (auto act = symTable.lookupNearestSymbolFrom<cal::ActorOp>(inst, inst.getActorRefAttr())) target = act.getOperation();
        if (!target) return;
        if (target->hasAttr("cal.specialized")) return; // don't specialize a clone symbol itself
        int paramCount = static_cast<int>(inst.getNumOperands());
        bool anyConst = false;
        for (int i = 0; i < paramCount; ++i) if (valueToTypedAttr(inst.getOperand(i))) { anyConst = true; break; }
        if (!anyConst) return;
        seenInsts.insert(inst);
        worklist.push_back(inst);
      };

      // Seed from current module contents.
      module.walk([&](cal::InstantiateOp inst) { considerInst(inst); });

      while (!worklist.empty()) {
        cal::InstantiateOp inst = worklist.back();
        worklist.pop_back();
        Operation *target = nullptr;
  if (auto net = symTable.lookupNearestSymbolFrom<cal::NetworkOp>(inst, inst.getActorRefAttr())) target = net.getOperation();
  else if (auto act = symTable.lookupNearestSymbolFrom<cal::ActorOp>(inst, inst.getActorRefAttr())) target = act.getOperation();
        if (!target) continue;
  if (target->hasAttr("cal.specialized")) continue;
        int paramCount = static_cast<int>(inst.getNumOperands());
        SmallVector<Value, 8> actuals(inst.getOperands().begin(), inst.getOperands().end());
        std::string cacheKey = buildKeyForSpec(SymbolTable::getSymbolName(target).getValue(), actuals, paramCount);
        auto it = specCache.find(cacheKey);
        FlatSymbolRefAttr specializedRef;
        if (it != specCache.end()) {
          specializedRef = it->second;
        } else {
          Operation *clone = target->clone();
          std::string baseName = SymbolTable::getSymbolName(target).getValue().str() + std::string("$spec");
          std::string newName = baseName + std::string("_") + std::to_string(llvm::hash_value(cacheKey));
          clone->setAttr(SymbolTable::getSymbolAttrName(), StringAttr::get(module.getContext(), newName));
          SymbolTable(module).insert(clone);
          if (auto cNet = dyn_cast<cal::NetworkOp>(clone)) {
            inlineConstantsIntoRegion(cNet.getBody(), actuals, paramCount);
            // Locally simplify constants/guards to enable termination (e.g., NSTAGES<=1 => zero-trip, no recurse)
            locallySimplifyRegion(cNet.getBody());
            // Discover new instantiates inside this clone and enqueue them immediately.
            cNet.walk([&](cal::InstantiateOp inner) { considerInst(inner); });
          } else if (auto cAct = dyn_cast<cal::ActorOp>(clone)) {
            inlineConstantsIntoRegion(cAct.getBody(), actuals, paramCount);
            locallySimplifyRegion(cAct.getBody());
            cAct.walk([&](cal::InstantiateOp inner) { considerInst(inner); });
          }
          specializedRef = FlatSymbolRefAttr::get(StringAttr::get(module.getContext(), newName));
          clone->setAttr("cal.specialized", UnitAttr::get(module.getContext()));
          specCache.try_emplace(cacheKey, specializedRef);
        }
        if (inst.getActorRefAttr() != specializedRef) {
          inst->setAttr("actorRef", specializedRef);
          if (auto hTy = dyn_cast<cal::InstanceType>(inst.getHandle().getType())) {
            auto newHTy = cal::InstanceType::get(module.getContext(), specializedRef);
            inst.getHandle().setType(newHTy);
          }
          changed = true;
        }
      }

      // Note: Avoid running a nested PassManager here to prevent dialect
      // loading in a multi-threaded context. Downstream pipelines can run
      // canonicalization/CSE. We just iterate the specialization until no
      // new clones are created.
    }
  }
};
} // namespace

std::unique_ptr<mlir::Pass> mlir::createParamSpecializePass() {
  return std::make_unique<ParamSpecializePass>();
}
