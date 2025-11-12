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
          switch (cmp.getPredicate()) {
            case P::eq: res = (*A == *B); break; case P::ne: res = (*A != *B); break; case P::slt: res = (*A < *B); break;
            case P::sle: res = (*A <= *B); break; case P::sgt: res = (*A > *B); break; case P::sge: res = (*A >= *B); break;
            case P::ult: res = (static_cast<uint64_t>(*A) < static_cast<uint64_t>(*B)); break; case P::ule: res = (static_cast<uint64_t>(*A) <= static_cast<uint64_t>(*B)); break;
            case P::ugt: res = (static_cast<uint64_t>(*A) > static_cast<uint64_t>(*B)); break; case P::uge: res = (static_cast<uint64_t>(*A) >= static_cast<uint64_t>(*B)); break;
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
      SmallVector<cal::InstantiateOp, 16> insts;
      module.walk([&](cal::InstantiateOp inst) {
        Operation *target = nullptr;
        if (auto net = symTable.lookupNearestSymbolFrom<cal::NetworkOp>(inst, inst.getActorRefAttr())) target = net.getOperation();
        else if (auto act = symTable.lookupNearestSymbolFrom<cal::ActorOp>(inst, inst.getActorRefAttr())) target = act.getOperation();
        if (!target) return;
        // Do not specialize already-specialized clones to avoid cascades.
        if (target->hasAttr("cal.specialized")) return;
        int paramCount = static_cast<int>(inst.getNumOperands());
        bool anyConst = false;
        for (int i = 0; i < paramCount; ++i) if (valueToTypedAttr(inst.getOperand(i))) { anyConst = true; break; }
        if (!anyConst) return;
        insts.push_back(inst);
      });

      for (cal::InstantiateOp inst : insts) {
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
          if (auto cNet = dyn_cast<cal::NetworkOp>(clone)) inlineConstantsIntoRegion(cNet.getBody(), actuals, paramCount);
          else if (auto cAct = dyn_cast<cal::ActorOp>(clone)) inlineConstantsIntoRegion(cAct.getBody(), actuals, paramCount);
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
