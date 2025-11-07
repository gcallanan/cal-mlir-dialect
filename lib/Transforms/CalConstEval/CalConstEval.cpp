//===- CalConstEval.cpp - Const-eval helper funcs for CAL nets ---------===//
// A lightweight skeleton pass that will later inline and fold constexpr-like
// helpers so structural conditions and trip counts become constants.
// For now, it performs no transformation, serving as a registered placeholder.
//===----------------------------------------------------------------------===//

#include "mlir/Pass/Pass.h"
// Dependent dialects referenced in the generated registration for this pass.
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Math/IR/Math.h"
#include "mlir/Dialect/Complex/IR/Complex.h"
// LLVM dialect for lowering target
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
// The canonicalizer/inliner may reference UB ops; ensure the dialect is registered.
#include "mlir/Dialect/UB/IR/UBOps.h"
// ExecutionEngine and lowering scaffolding (JIT const-eval prep)
#include "mlir/ExecutionEngine/ExecutionEngine.h"
#include "mlir/Conversion/Passes.h" // Needed for createConvertToLLVMPass
#include "mlir/Conversion/FuncToLLVM/ConvertFuncToLLVM.h"
#include "mlir/Conversion/ArithToLLVM/ArithToLLVM.h"
#include "mlir/Conversion/SCFToControlFlow/SCFToControlFlow.h"
#include "mlir/Conversion/ControlFlowToLLVM/ControlFlowToLLVM.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/SymbolTable.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/Passes.h"
// For DialectInlinerInterface detection (guarded inliner usage)
#include "mlir/Transforms/InliningUtils.h"
// Generic constant matcher
#include "mlir/IR/Matchers.h"
// Env var check
#include <cstdlib>
// Time watchdog
#include <chrono>
// Bit utilities for float bitcasts
#include <cstring>
// APInt for safe constant evaluation
#include "llvm/ADT/APInt.h"
// DenseMap / SmallVector / String
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/SmallString.h"
// Pattern helpers for constant folding checks
#include "mlir/IR/PatternMatch.h"
// CAL ops to scope work under cal.network
#include "Dialect/Cal/CalOps.h"
#include "Transforms/Passes.h"
// For identifying FIFO port-typed block arguments when computing param counts.
#include "Dialect/Fifo/FifoTypes.h"

using namespace mlir;

namespace mlir {
#define GEN_PASS_DECL_CALCONSTEVALPASS
#define GEN_PASS_DEF_CALCONSTEVALPASS
#include "Transforms/Passes.h.inc"

namespace {
struct CalConstEvalPass : public impl::CalConstEvalPassBase<CalConstEvalPass> {
  // Cache to deduplicate specializations in one pass run.
  // Key format: symName + '|' + per-param ("-" for dynamic or attribute dump).
  llvm::StringMap<FlatSymbolRefAttr> specCache;

  // Experimental: cache for JIT const-eval results (callee+args).
  // Keyed by callee symbol plus comma-joined signed argument values.
  llvm::StringMap<llvm::APInt> jitConstMemo;

  // Stub for upcoming JIT-based const evaluation. Returns nullopt until
  // fully implemented. The interface is stable: takes a pure helper callee
  // and its constant integer/index arguments, and returns a folded APInt
  // or nullopt if not supported/fails. Budget limits compile/exec effort.
  std::optional<llvm::APInt>
  tryJitConstEval(func::FuncOp callee,
                  ArrayRef<llvm::APInt> args,
                  unsigned budget);

  void runOnOperation() override {
    // Run a tiny inner pipeline: prefer MLIR's inliner when available,
    // otherwise fall back to a simple local inliner, then canonicalize.
    Operation *op = getOperation();

    bool ranGlobalInliner = false;
    // Prefer pass option; keep env var as a secondary dev toggle.
    bool useGlobalInliner = this->enableGlobalInliner ||
                            (std::getenv("CAL_ENABLE_GLOBAL_INLINER") != nullptr);
    if (useGlobalInliner) {
      if (auto *ctx = op->getContext()) {
        PassManager pm(ctx);
        pm.enableVerifier(false);
        pm.addPass(mlir::createInlinerPass());
        pm.addPass(mlir::createCanonicalizerPass());
        if (succeeded(pm.run(op))) {
          ranGlobalInliner = true;
        }
      }
    }

    if (!ranGlobalInliner) {
      // Small, local inliner for pure, single-block helper functions with constant
      // arguments. This avoids relying on the global inliner interface.
      if (auto module = dyn_cast<ModuleOp>(op)) {
        SymbolTable symTable(module);
        SmallVector<func::CallOp, 8> calls;
        module.walk([&](func::CallOp call) {
          // Broaden scope: allow const-eval anywhere in the module (actors, networks, helpers).
          // This helps fold helpers inside functions called by networks as well.
          calls.push_back(call);
        });
        for (func::CallOp call : calls) {
          // Only handle single-result calls for now.
          if (call.getNumResults() != 1)
            continue;
          // Callee must be resolvable.
          auto callee = symTable.lookup<func::FuncOp>(call.getCallee());
          if (!callee)
            continue;
          // Callee must be a simple, single-block function with a single return.
          if (!callee.getBody().hasOneBlock())
            continue;
          Block &body = callee.getBody().front();
          // Require same number of args as operands.
          if (callee.getFunctionType().getNumInputs() != call.getNumOperands())
            continue;
          // Conservatively skip functions with nested regions or ops outside arith/func.return.
          bool simple = true;
          for (Operation &inner : body) {
            if (isa<func::ReturnOp>(&inner))
              continue;
            // Allow only arith dialect ops and constants.
            if (!(inner.getName().getDialectNamespace() == "arith")) {
              simple = false;
              break;
            }
          }
          if (!simple)
            continue;
          // Inline by cloning body ops at call site.
          OpBuilder rewriter(module.getContext());
          rewriter.setInsertionPoint(call);
          IRMapping map;
          // Map callee block arguments to call operands.
          for (auto [arg, operand] : llvm::zip(body.getArguments(), call.getOperands()))
            map.map(arg, operand);
          Value retValue;
          for (Operation &inner : body) {
            if (auto ret = dyn_cast<func::ReturnOp>(&inner)) {
              if (ret.getNumOperands() == 1)
                retValue = map.lookupOrNull(ret.getOperand(0));
              break;
            }
            Operation *cloned = rewriter.clone(inner, map);
            for (auto [oldRes, newRes] : llvm::zip(inner.getResults(), cloned->getResults()))
              map.map(oldRes, newRes);
          }
          if (retValue) {
            call.getResult(0).replaceAllUsesWith(retValue);
            call.erase();
          }
        }
      }
      // Canonicalize after local inlining.
      PassManager pm2(op->getContext());
      pm2.enableVerifier(false);
      pm2.addPass(mlir::createCanonicalizerPass());
      if (failed(pm2.run(op))) {
        signalPassFailure();
      }
    }

    // Phase 2 (Stage 1): Specialize instantiated symbols (actor/network)
    // when at least one parameter is a constant. We clone the symbol, inline
    // constant params into the cloned body, keep the signature unchanged, and
    // retarget the instantiate op to the specialized clone. This preserves
    // symbolic construction while enabling aggressive folding downstream.
    if (auto module = dyn_cast<ModuleOp>(op)) {
      SymbolTable symTable(module);

      auto getParamCount = [&](Operation *ent) -> int {
        // Robust param inference: count leading non-FIFO block arguments.
        auto countByLeadingNonFifo = [&](Region &r) -> int {
          if (r.empty()) return 0;
          Block &b = r.front();
          int count = 0;
          for (BlockArgument arg : b.getArguments()) {
            Type ty = arg.getType();
            // Treat any FIFO port types as the start of port section.
            if (isa<fifo::InputPortType>(ty) || isa<fifo::OutputPortType>(ty))
              break;
            ++count;
          }
          return std::max(count, 0);
        };

        if (auto net = dyn_cast<cal::NetworkOp>(ent))
          return countByLeadingNonFifo(net.getBody());
        if (auto act = dyn_cast<cal::ActorOp>(ent))
          return countByLeadingNonFifo(act.getBody());
        return -1;
      };

  // Try to evaluate a Value to a typed constant Attribute suitable for cloning
      // into a cal.actor/cal.network parameter. Handles:
      //  - arith.constant (all types supported)
      //  - simple integer expressions (addi/subi/muli/select/cmpi/index_cast)
      auto valueToTypedAttr = [&](Value v) -> TypedAttr {
        if (!v)
          return {};
        // Try generic constant matcher first (handles arith.constant and friends).
        Attribute a;
        if (matchPattern(v, m_Constant(&a)))
          if (auto ta = dyn_cast<TypedAttr>(a)) return ta;
        if (auto c = v.getDefiningOp<arith::ConstantOp>()) {
          if (auto ta = dyn_cast<TypedAttr>(c.getValue()))
            return ta;
        }
        // Small integer evaluator (copy of the quick evaluator used below).
        std::function<std::optional<int64_t>(Value)> quickInt;
        quickInt = [&](Value vv) -> std::optional<int64_t> {
          if (auto kc = vv.getDefiningOp<arith::ConstantOp>())
            if (auto ia = dyn_cast<IntegerAttr>(kc.getValue()))
              return ia.getInt();
          if (auto ic = vv.getDefiningOp<arith::IndexCastOp>()) {
            auto x = quickInt(ic.getIn()); if (x) return *x;
          }
          if (auto ai = vv.getDefiningOp<arith::AddIOp>()) {
            auto A = quickInt(ai.getLhs()); auto B = quickInt(ai.getRhs()); if (A && B) return *A + *B;
          }
          if (auto si = vv.getDefiningOp<arith::SubIOp>()) {
            auto A = quickInt(si.getLhs()); auto B = quickInt(si.getRhs()); if (A && B) return *A - *B;
          }
          if (auto mi = vv.getDefiningOp<arith::MulIOp>()) {
            auto A = quickInt(mi.getLhs()); auto B = quickInt(mi.getRhs()); if (A && B) return (*A) * (*B);
          }
          if (auto cmp = vv.getDefiningOp<arith::CmpIOp>()) {
            auto A = quickInt(cmp.getLhs()); auto B = quickInt(cmp.getRhs()); if (!A || !B) return std::nullopt;
            using P = arith::CmpIPredicate;
            bool res = false;
            switch (cmp.getPredicate()) {
              case P::eq:  res = (*A == *B); break;
              case P::ne:  res = (*A != *B); break;
              case P::slt: res = (*A < *B); break;
              case P::sle: res = (*A <= *B); break;
              case P::sgt: res = (*A > *B); break;
              case P::sge: res = (*A >= *B); break;
              case P::ult: res = (static_cast<uint64_t>(*A) < static_cast<uint64_t>(*B)); break;
              case P::ule: res = (static_cast<uint64_t>(*A) <= static_cast<uint64_t>(*B)); break;
              case P::ugt: res = (static_cast<uint64_t>(*A) > static_cast<uint64_t>(*B)); break;
              case P::uge: res = (static_cast<uint64_t>(*A) >= static_cast<uint64_t>(*B)); break;
            }
            return res ? 1 : 0;
          }
          if (auto sel = vv.getDefiningOp<arith::SelectOp>()) {
            auto C = quickInt(sel.getCondition()); if (!C) return std::nullopt; return *C ? quickInt(sel.getTrueValue()) : quickInt(sel.getFalseValue());
          }
          return std::nullopt;
        };
        if (auto vInt = quickInt(v)) {
          // Default to i64 unless the value already has a specific integer type.
          Type ty = v.getType();
          if (auto it = dyn_cast<IntegerType>(ty))
            return IntegerAttr::get(it, *vInt);
          if (isa<IndexType>(ty))
            return IntegerAttr::get(IntegerType::get(v.getContext(), 64), *vInt);
          // Fallback: create a 64-bit int attr when no better type is known.
          return IntegerAttr::get(IntegerType::get(v.getContext(), 64), *vInt);
        }
        return {};
      };

      auto buildKeyForSpec = [&](StringRef symName, ArrayRef<Value> actuals,
                                 int paramCount) -> std::string {
        std::string key;
        key.reserve(symName.size() + 32 + actuals.size() * 8);
        key.append(symName.str());
        key.push_back('|');
        // Only the leading paramCount operands are parameters by convention.
        for (int i = 0; i < paramCount && i < (int)actuals.size(); ++i) {
          if (auto ta = valueToTypedAttr(actuals[i])) {
            std::string tmp; llvm::raw_string_ostream os(tmp); ta.print(os); os.flush(); key.append(tmp);
          } else { key.push_back('-'); }
          key.push_back(';'); }
        return key;
      };

      auto materializeConstAttr = [&](OpBuilder &b, Location loc, Attribute attr,
                                      Type /*ty*/) -> Value {
        // Prefer the typed builder to preserve the exact attribute type.
        if (auto typed = dyn_cast<TypedAttr>(attr))
          return b.create<arith::ConstantOp>(loc, typed).getResult();
        // Fall back to integer/float cases if needed (unlikely for params).
        if (auto intAttr = dyn_cast<IntegerAttr>(attr))
          return b.create<arith::ConstantOp>(loc, intAttr).getResult();
        if (auto fltAttr = dyn_cast<FloatAttr>(attr))
          return b.create<arith::ConstantOp>(loc, fltAttr).getResult();
        return {};
      };

      bool changed = true;
      unsigned guard = 0, guardMax = 8;
      while (changed && guard++ < guardMax) {
        changed = false;
        SmallVector<cal::InstantiateOp, 16> insts;
        module.walk([&](cal::InstantiateOp inst) {
          // Debug: mark all instantiate ops we visit.
          inst->setAttr("cal.specialization.seen", UnitAttr::get(module.getContext()));
          // Consider all instantiations (both in networks and any nested regions).
          // We no longer restrict to parents that are strictly cal.network, since
          // specializations can introduce nested networks in new symbols within the
          // same pass iteration and we want to catch those as well.
          // Resolve target to either cal.network or cal.actor.
          Operation *target = nullptr;
          if (auto net = symTable.lookupNearestSymbolFrom<cal::NetworkOp>(inst, inst.getActorRefAttr()))
            target = net.getOperation();
          else if (auto act = symTable.lookupNearestSymbolFrom<cal::ActorOp>(inst, inst.getActorRefAttr()))
            target = act.getOperation();
          if (!target) return;
          // Allow multi-stage specialization: even if the target is already a
          // specialized clone, we may still be able to inline additional
          // constant parameters from the current instantiation. Avoid early
          // returns here; deduplication is handled by the specCache key below.
          // Be robust: if we cannot determine the entity param count (e.g.,
          // verifier helpers not wired yet), fall back to using the number of
          // actual operands on the instantiate as the parameter count.
          int paramCount = getParamCount(target);
          if (paramCount < 0)
            paramCount = static_cast<int>(inst.getNumOperands());
          // Be defensive: if the entity declared no non-port parameters but the
          // instantiate supplies operands, treat at least the first operand as a
          // parameter candidate for specialization. This helps in cases where
          // port vs param inference is not yet wired for certain entities.
          if (paramCount == 0 && inst.getNumOperands() > 0)
            paramCount = 1;
          // Detect if at least one of the first paramCount operands is constant.
          bool anyConst = false;
          for (int i = 0, e = std::min(paramCount, (int)inst.getNumOperands()); i < e; ++i) {
            Value v = inst.getOperand(i);
            if (valueToTypedAttr(v)) { anyConst = true; break; }
            if (Operation *def = v.getDefiningOp())
              if (def->hasTrait<OpTrait::ConstantLike>()) { anyConst = true; break; }
          }
          if (!anyConst) return;
          // Mark as a candidate immediately for debugging visibility.
          inst->setAttr("cal.specialization.candidate", UnitAttr::get(module.getContext()));
          insts.push_back(inst);
        });

        for (cal::InstantiateOp inst : insts) {
          Operation *target = nullptr;
          auto net = symTable.lookupNearestSymbolFrom<cal::NetworkOp>(inst, inst.getActorRefAttr());
          auto act = symTable.lookupNearestSymbolFrom<cal::ActorOp>(inst, inst.getActorRefAttr());
          if (net)
            target = net.getOperation();
          else if (act)
            target = act.getOperation();
          if (!target) continue;

          // Treat all instantiate operands as parameters. cal.connect wires ports
          // separately, so operands here are exactly the symbolic parameters.
          int paramCount = static_cast<int>(inst.getNumOperands());

          // Lookup or build a specialized clone name.
          SmallVector<Value, 8> actuals(inst.getOperands().begin(), inst.getOperands().end());
          std::string cacheKey = buildKeyForSpec(SymbolTable::getSymbolName(target).getValue(), actuals, paramCount);
          auto it = specCache.find(cacheKey);
          FlatSymbolRefAttr specializedRef;
          if (it != specCache.end()) {
            specializedRef = it->second;
          } else {
            // Mark this instantiate as a specialization candidate for visibility in IR dumps.
            inst->setAttr("cal.specialization.candidate", UnitAttr::get(module.getContext()));
            // Clone the symbol, assign a unique name, and insert after the original.
            Operation *clone = target->clone();
            // Give it a unique name based on original + "$spec" and a hash of the key.
            std::string baseName = SymbolTable::getSymbolName(target).getValue().str() + std::string("$spec");
            // Use a hash of the cache key for a deterministic, low-collision suffix.
            std::string newName = baseName + std::string("_") + std::to_string(llvm::hash_value(cacheKey));
            clone->setAttr(SymbolTable::getSymbolAttrName(), StringAttr::get(module.getContext(), newName));
            // Insert into the module's symbol table (end of the region). This also
            // ensures name uniqueness if a collision occurs.
            SymbolTable(module).insert(clone);

            // Inline constants into the cloned region body for param indices.
            auto inlineConstantsIntoRegion = [&](Region &region) {
              if (region.empty()) return;
              Block &blk = region.front();
              OpBuilder b(module.getContext());
              b.setInsertionPointToStart(&blk);
              for (int i = 0; i < paramCount && i < (int)blk.getNumArguments(); ++i) {
                if (auto ta = valueToTypedAttr(inst.getOperand(i))) {
                  // If types mismatch, coerce via materializeConstAttr with the formal parameter type.
                  Value newC = materializeConstAttr(b, blk.getArgument(i).getLoc(), ta, blk.getArgument(i).getType());
                  if (newC)
                    blk.getArgument(i).replaceAllUsesWith(newC);
                }
              }
            };

            if (auto cNet = dyn_cast<cal::NetworkOp>(clone)) {
              inlineConstantsIntoRegion(cNet.getBody());
            } else if (auto cAct = dyn_cast<cal::ActorOp>(clone)) {
              inlineConstantsIntoRegion(cAct.getBody());
            }

            specializedRef = FlatSymbolRefAttr::get(StringAttr::get(module.getContext(), newName));
            // Mark the clone as specialized to avoid re-specializing.
            clone->setAttr("cal.specialized", UnitAttr::get(module.getContext()));
            specCache.try_emplace(cacheKey, specializedRef);
          }

          // Retarget instantiate to the specialized symbol when it actually changes.
          if (inst.getActorRefAttr() != specializedRef) {
            inst->setAttr("actorRef", specializedRef);
            // Debug marker to verify retargeting occurred in dumps.
            inst->setAttr("cal.specialization.retargeted", UnitAttr::get(module.getContext()));
            changed = true;
          }
        }

        if (changed) {
          PassManager pm(op->getContext());
          pm.enableVerifier(false);
          pm.addPass(mlir::createCanonicalizerPass());
          pm.addPass(mlir::createCSEPass());
          if (failed(pm.run(module))) {
            signalPassFailure();
            return;
          }
        }
      }
      // Second-chance specialization sweep: some instantiations with constant
      // operands may appear only after earlier clones/canonicalization. Force
      // clone for any network/actor not yet marked cal.specialized when at
      // least one operand is constant-like.
      {
        bool lateChanged = true;
        unsigned lateGuard = 0, lateGuardMax = 6; // iterate to fixed point
        while (lateChanged && lateGuard++ < lateGuardMax) {
          lateChanged = false;
          SmallVector<cal::InstantiateOp, 16> lateInsts;
          module.walk([&](cal::InstantiateOp inst){
            Operation *target = nullptr;
            if (auto net = symTable.lookupNearestSymbolFrom<cal::NetworkOp>(inst, inst.getActorRefAttr()))
              target = net.getOperation();
            else if (auto act = symTable.lookupNearestSymbolFrom<cal::ActorOp>(inst, inst.getActorRefAttr()))
              target = act.getOperation();
            if (!target) return;
            // If this exact instantiate already points at a spec variant (symbol name contains $spec or $specLate) skip.
            if (inst.getActorRef().contains("$spec")) return;
            bool anyConst = false;
            for (Value v : inst.getOperands()) {
              if (valueToTypedAttr(v) || (v.getDefiningOp() && v.getDefiningOp()->hasTrait<OpTrait::ConstantLike>())) { anyConst = true; break; }
            }
            if (!anyConst) return;
            lateInsts.push_back(inst);
          });
          for (auto inst : lateInsts) {
            Operation *target = nullptr;
            if (auto net = symTable.lookupNearestSymbolFrom<cal::NetworkOp>(inst, inst.getActorRefAttr()))
              target = net.getOperation();
            else if (auto act = symTable.lookupNearestSymbolFrom<cal::ActorOp>(inst, inst.getActorRefAttr()))
              target = act.getOperation();
            if (!target) continue;
            Operation *clone = target->clone();
            std::string baseName = SymbolTable::getSymbolName(target).getValue().str() + std::string("$specLate");
            std::string key = baseName; key.push_back('|');
            for (Value v : inst.getOperands()) {
              if (auto ta = valueToTypedAttr(v)) { std::string tmp; llvm::raw_string_ostream os(tmp); ta.print(os); os.flush(); key.append(tmp); }
              else key.push_back('-');
              key.push_back(';');
            }
            std::string newName = baseName + std::string("_") + std::to_string(llvm::hash_value(key));
            clone->setAttr(SymbolTable::getSymbolAttrName(), StringAttr::get(module.getContext(), newName));
            SymbolTable(module).insert(clone);
            clone->setAttr("cal.specialized", UnitAttr::get(module.getContext()));
            auto inlineRegion = [&](Region &r){
              if (r.empty()) return;
              Block &b = r.front();
              OpBuilder ib(module.getContext()); ib.setInsertionPointToStart(&b);
              for (unsigned i=0;i<b.getNumArguments() && i<inst.getNumOperands();++i){
                if (auto ta = valueToTypedAttr(inst.getOperand(i))) {
                  Value cv = ib.create<arith::ConstantOp>(b.getArgument(i).getLoc(), ta);
                  b.getArgument(i).replaceAllUsesWith(cv);
                }
              }
            };
            if (auto nC = dyn_cast<cal::NetworkOp>(clone)) inlineRegion(nC.getBody());
            if (auto aC = dyn_cast<cal::ActorOp>(clone)) inlineRegion(aC.getBody());
            auto newRef = FlatSymbolRefAttr::get(StringAttr::get(module.getContext(), newName));
            inst->setAttr("actorRef", newRef);
            inst->setAttr("cal.specialization.retargeted", UnitAttr::get(module.getContext()));
            lateChanged = true;
          }
          if (lateChanged) {
            PassManager pm(op->getContext()); pm.enableVerifier(false);
            pm.addPass(mlir::createCanonicalizerPass()); pm.addPass(mlir::createCSEPass());
            (void)pm.run(module);
          }
        }
      }
    }

    // Phase 3a: Post-specialization pow2 folding (second pass).
    // After the late second-chance specialization sweep above we may have
    // introduced fresh specialized clones (e.g. fft__Butterfly$specLate_*).
    // These clones can still contain recursive pow2 helper calls whose
    // arguments have become constant only after inlining parameter constants.
    // The original Phase 3 pow2 fast-path ran before these clones existed,
    // so we re-run a lightweight fold here to catch and eliminate those calls
    // prior to pruning/DCE. We purposely keep this duplicate logic local to
    // avoid refactoring the earlier section during rapid iteration.
    if (this->enablePow2Fastpath && std::getenv("CAL_DISABLE_POW2_FASTPATH") == nullptr) {
      if (auto module = dyn_cast<ModuleOp>(op)) {
        SymbolTable symTable(module);
        SmallVector<func::CallOp, 8> pow2Calls;
        module.walk([&](func::CallOp call){
          if (call.getNumOperands() != 1) return; // heuristic
          auto callee = symTable.lookup<func::FuncOp>(call.getCallee());
          if (!callee) return;
          // Quick name check first (avoid expensive structural match for non-pow2 helpers).
          bool nameHit = callee.getSymName().contains("pow2");
          // Structural matcher reused from earlier phase (simplified):
          auto matchesPow2 = [&](func::FuncOp fn)->bool {
            if (!fn || !fn.getBody().hasOneBlock()) return false;
            Block &body = fn.getBody().front();
            auto ret = dyn_cast_or_null<func::ReturnOp>(body.getTerminator());
            if (!ret || ret.getNumOperands() != 1) return false;
            Value retVal = ret.getOperand(0);
            // Pattern A: Recursive select-based recurrence:
            if (auto sel = retVal.getDefiningOp<arith::SelectOp>()) {
              auto cmp = sel.getCondition().getDefiningOp<arith::CmpIOp>();
              if (!cmp || cmp.getPredicate() != arith::CmpIPredicate::eq) return false;
              Value lhs = cmp.getLhs(); Value rhs = cmp.getRhs();
              Value arg0 = fn.getArgument(0);
              auto isZero = [](Value v){ if (auto c = v.getDefiningOp<arith::ConstantOp>()) if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) return ia.getValue().isZero(); return false; };
              if (!((lhs == arg0 && isZero(rhs)) || (rhs == arg0 && isZero(lhs)))) return false;
              auto mul = sel.getFalseValue().getDefiningOp<arith::MulIOp>(); if (!mul) return false;
              func::CallOp recCall = nullptr; IntegerAttr mulCst;
              auto pick = [&](Value A, Value B){
                if (auto c = A.getDefiningOp<arith::ConstantOp>()) if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) mulCst = ia;
                if (auto c = B.getDefiningOp<arith::ConstantOp>()) if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) mulCst = ia;
                if (auto cc = A.getDefiningOp<func::CallOp>()) recCall = cc;
                if (auto cc = B.getDefiningOp<func::CallOp>()) recCall = cc;
                return recCall && mulCst && mulCst.getValue() == 2;
              };
              if (!pick(mul.getLhs(), mul.getRhs())) return false;
              if (recCall.getCallee() != fn.getSymName() || recCall.getNumOperands() != 1) return false;
              auto sub = recCall.getOperand(0).getDefiningOp<arith::SubIOp>(); if (!sub) return false;
              auto isOne = [](Value v){ if (auto c = v.getDefiningOp<arith::ConstantOp>()) if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) return ia.getInt() == 1; return false; };
              if (!((sub.getLhs() == arg0 && isOne(sub.getRhs())) || (sub.getRhs() == arg0 && isOne(sub.getLhs())))) return false;
              auto thenC = sel.getTrueValue().getDefiningOp<arith::ConstantOp>(); if (!thenC) return false;
              if (auto ia = dyn_cast<IntegerAttr>(thenC.getValue())) { auto bw = ia.getValue().getBitWidth(); if (!(ia.getValue() == llvm::APInt(bw, 1))) return false; } else return false;
              return true;
            }
            // Pattern B: Iterative scf.for accumulator form:
            if (auto forOp = retVal.getDefiningOp<scf::ForOp>()) {
              // Expect single iter_arg initialized to 1, lb=0, step=1, ub=arg0 (possibly index_cast), body multiplies accumulator by 2.
              if (forOp.getInitArgs().size() != 1) return false;
              auto initC = forOp.getInitArgs()[0].getDefiningOp<arith::ConstantOp>(); if (!initC) return false;
              auto initIA = dyn_cast<IntegerAttr>(initC.getValue()); if (!initIA || initIA.getInt() != 1) return false;
              auto cLb = forOp.getLowerBound().getDefiningOp<arith::ConstantOp>(); auto cSt = forOp.getStep().getDefiningOp<arith::ConstantOp>();
              if (!cLb || !cSt) return false;
              auto lbIA = dyn_cast<IntegerAttr>(cLb.getValue()); auto stIA = dyn_cast<IntegerAttr>(cSt.getValue());
              if (!lbIA || !lbIA.getValue().isZero() || !stIA || stIA.getInt() != 1) return false;
              auto unwrapUB = [](Value v){ if (auto ic = v.getDefiningOp<arith::IndexCastOp>()) return ic.getIn(); return v; };
              if (unwrapUB(forOp.getUpperBound()) != fn.getArgument(0)) return false;
              Block *fb = forOp.getBody(); if (!fb) return false;
              // scf.for region args: %iv, %acc. We want yield muli(%acc, 2).
              if (fb->getArguments().size() != 2) return false;
              auto yield = dyn_cast<scf::YieldOp>(fb->getTerminator()); if (!yield || yield.getNumOperands() != 1) return false;
              auto mul = yield.getOperand(0).getDefiningOp<arith::MulIOp>(); if (!mul) return false;
              Value acc = fb->getArgument(1);
              auto isTwo = [](Value v){ if (auto c = v.getDefiningOp<arith::ConstantOp>()) if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) return ia.getInt() == 2; return false; };
              if (!((mul.getLhs() == acc && isTwo(mul.getRhs())) || (mul.getRhs() == acc && isTwo(mul.getLhs())))) return false;
              return true;
            }
            return false;
          };
          if (nameHit || matchesPow2(callee)) pow2Calls.push_back(call);
        });
        // Quick integer evaluator (simplified) for the single argument.
        std::function<std::optional<int64_t>(Value)> evalIntArg;
        evalIntArg = [&](Value v)->std::optional<int64_t>{
          if (auto c = v.getDefiningOp<arith::ConstantOp>())
            if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) return ia.getInt();
          if (auto castOp = v.getDefiningOp<arith::IndexCastOp>()) return evalIntArg(castOp.getIn());
          if (auto addi = v.getDefiningOp<arith::AddIOp>()) { auto A = evalIntArg(addi.getLhs()); auto B = evalIntArg(addi.getRhs()); if (A && B) return *A + *B; }
          if (auto subi = v.getDefiningOp<arith::SubIOp>()) { auto A = evalIntArg(subi.getLhs()); auto B = evalIntArg(subi.getRhs()); if (A && B) return *A - *B; }
          if (auto sel = v.getDefiningOp<arith::SelectOp>()) { auto C = evalIntArg(sel.getCondition()); if (!C) return std::nullopt; return *C ? evalIntArg(sel.getTrueValue()) : evalIntArg(sel.getFalseValue()); }
          if (auto cmp = v.getDefiningOp<arith::CmpIOp>()) { auto A = evalIntArg(cmp.getLhs()); auto B = evalIntArg(cmp.getRhs()); if (!A || !B) return std::nullopt; bool res=false; using P=arith::CmpIPredicate; switch(cmp.getPredicate()){case P::eq:res=*A==*B;break;case P::ne:res=*A!=*B;break;case P::slt:res=*A<*B;break;case P::sle:res=*A<=*B;break;case P::sgt:res=*A>*B;break;case P::sge:res=*A>=*B;break;default:res=false;} return res?1:0; }
          return std::nullopt; };
        for (auto call : pow2Calls) {
          auto nOpt = evalIntArg(call.getArgOperands()[0]);
          if (!nOpt) continue;
          int64_t n = *nOpt; if (n < 0 || n > 63) continue; // guard
          Type resTy = call.getResult(0).getType();
          auto intTy = dyn_cast<IntegerType>(resTy); if (!intTy) continue;
          unsigned bw = intTy.getWidth(); if (n >= (int64_t)bw) continue;
          llvm::APInt val(bw, 1); val = val.shl(n);
          OpBuilder rw(module.getContext()); rw.setInsertionPoint(call);
          auto folded = rw.create<arith::ConstantIntOp>(call.getLoc(), val.getSExtValue(), bw);
          call.getResult(0).replaceAllUsesWith(folded.getResult());
          call.erase();
        }
      }
    }

    // Phase 2b: (optional) Inline networks when explicitly enabled.
    // Keep disabled by default to prefer symbolic specialization in Stage 1.
    bool useNetworkInline = this->enableNetworkInline ||
                            (std::getenv("CAL_ENABLE_NETWORK_INLINE") != nullptr);
    if (useNetworkInline) {
      if (auto module = dyn_cast<ModuleOp>(op)) {
        SymbolTable symTable(module);
        bool changed = true;
        unsigned guard = 0, guardMax = 4;
        while (changed && guard++ < guardMax) {
          changed = false;
          SmallVector<cal::InstantiateOp, 16> insts;
          module.walk([&](cal::InstantiateOp inst) {
            if (!inst->getParentOfType<cal::NetworkOp>()) return;
            bool allConst = llvm::all_of(inst.getOperands(), [](Value v){
              return v.getDefiningOp<arith::ConstantOp>() != nullptr;
            });
            if (!allConst) return;
            auto target = symTable.lookupNearestSymbolFrom<cal::NetworkOp>(inst, inst.getActorRefAttr());
            if (!target) return;
            insts.push_back(inst);
          });
          for (cal::InstantiateOp inst : insts) {
            auto target = symTable.lookupNearestSymbolFrom<cal::NetworkOp>(inst, inst.getActorRefAttr());
            if (!target) continue;
            IRMapping map;
            auto formalArgs = target.getBody().getArguments();
            auto actuals = inst.getOperands();
            if (formalArgs.size() != actuals.size()) continue;
            for (auto it : llvm::zip(formalArgs, actuals))
              map.map(std::get<0>(it), std::get<1>(it));
            Block &body = target.getBody().front();
            IRRewriter rewriter(module.getContext());
            rewriter.setInsertionPoint(inst);
            for (Operation &inner : body.getOperations()) {
              if (isa<cal::NetworkOp>(&inner) || isa<cal::ActorOp>(&inner)) continue;
              Operation *cloned = rewriter.clone(inner, map);
              for (auto [oldRes, newRes] : llvm::zip(inner.getResults(), cloned->getResults()))
                map.map(oldRes, newRes);
            }
            inst.erase();
            changed = true;
          }
          if (changed) {
            PassManager pm3(op->getContext());
            pm3.enableVerifier(false);
            pm3.addPass(mlir::createCanonicalizerPass());
            (void)pm3.run(op);
          }
        }
      }
    }

    // Phase 3: Recognize and fold simple recursive pow-style helpers when
    // called with constant integer arguments. This makes array extents and
    // scf conditions fully static earlier.
  bool usePow2Fastpath = this->enablePow2Fastpath &&
                         (std::getenv("CAL_DISABLE_POW2_FASTPATH") == nullptr); // default ON
  if (usePow2Fastpath) if (auto module = dyn_cast<ModuleOp>(op)) {
      SymbolTable symTable(module);
      SmallVector<func::CallOp, 16> calls;
      module.walk([&](func::CallOp call) {
        // Consider pow2-like helpers anywhere; don't restrict to network regions.
        if (call.getNumOperands() != 1) return; // heuristic targets 1-arg pow2 helpers
        calls.push_back(call);
      });

      // Helper: try to evaluate an SSA integer value to a concrete int64_t by
      // recursively interpreting a small subset of arith ops over constant
      // operands. This is intentionally conservative but sufficient for our
      // structural helpers (e.g., pow2 patterns constructed from subi/select/muli).
      std::function<std::optional<int64_t>(Value)> evalInt;
      evalInt = [&](Value v) -> std::optional<int64_t> {
        if (!v) return std::nullopt;
        if (auto c = v.getDefiningOp<arith::ConstantOp>()) {
          if (auto ia = dyn_cast<IntegerAttr>(c.getValue()))
            return ia.getInt();
          // Some constants may be index-typed integers.
          if (auto ti = dyn_cast<TypedAttr>(c.getValue()))
            if (auto ity = dyn_cast<IntegerType>(ti.getType()))
              if (auto ia2 = dyn_cast<IntegerAttr>(c.getValue()))
                return ia2.getInt();
          return std::nullopt;
        }
        if (auto castOp = v.getDefiningOp<arith::IndexCastOp>()) {
          auto src = evalInt(castOp.getIn());
          if (src) return *src;
          return std::nullopt;
        }
        if (auto addi = v.getDefiningOp<arith::AddIOp>()) {
          auto a = evalInt(addi.getLhs()); auto b = evalInt(addi.getRhs());
          if (a && b) return *a + *b; return std::nullopt;
        }
        if (auto subi = v.getDefiningOp<arith::SubIOp>()) {
          auto a = evalInt(subi.getLhs()); auto b = evalInt(subi.getRhs());
          if (a && b) return *a - *b; return std::nullopt;
        }
        if (auto muli = v.getDefiningOp<arith::MulIOp>()) {
          auto a = evalInt(muli.getLhs()); auto b = evalInt(muli.getRhs());
          if (a && b) return *a * *b; return std::nullopt;
        }
        if (auto sel = v.getDefiningOp<arith::SelectOp>()) {
          // Only handle i1 condition that is constant.
          auto cst = evalInt(sel.getCondition());
          if (!cst) return std::nullopt;
          // Convention: non-zero => true.
          if (*cst != 0) return evalInt(sel.getTrueValue());
          return evalInt(sel.getFalseValue());
        }
        if (auto cmpi = v.getDefiningOp<arith::CmpIOp>()) {
          auto a = evalInt(cmpi.getLhs()); auto b = evalInt(cmpi.getRhs());
          if (!a || !b) return std::nullopt;
          using P = arith::CmpIPredicate;
          bool res = false;
          switch (cmpi.getPredicate()) {
            case P::eq: res = (*a == *b); break;
            case P::ne: res = (*a != *b); break;
            case P::slt: res = (*a < *b); break;
            case P::sle: res = (*a <= *b); break;
            case P::sgt: res = (*a > *b); break;
            case P::sge: res = (*a >= *b); break;
            case P::ult: res = (static_cast<uint64_t>(*a) < static_cast<uint64_t>(*b)); break;
            case P::ule: res = (static_cast<uint64_t>(*a) <= static_cast<uint64_t>(*b)); break;
            case P::ugt: res = (static_cast<uint64_t>(*a) > static_cast<uint64_t>(*b)); break;
            case P::uge: res = (static_cast<uint64_t>(*a) >= static_cast<uint64_t>(*b)); break;
          }
          return res ? 1 : 0;
        }
        return std::nullopt;
      };

      auto matchesPow2Recurrence = [](func::FuncOp callee) -> bool {
        if (!callee || !callee.getBody().hasOneBlock()) return false;
        Block &body = callee.getBody().front();
        auto ret = dyn_cast_or_null<func::ReturnOp>(body.getTerminator());
        if (!ret || ret.getNumOperands() != 1) return false;
        Value retVal = ret.getOperand(0);
        // Pattern A: recursive select-based form.
        if (auto sel = retVal.getDefiningOp<arith::SelectOp>()) {
          auto cmp = sel.getCondition().getDefiningOp<arith::CmpIOp>();
          if (!cmp || cmp.getPredicate() != arith::CmpIPredicate::eq) return false;
          auto arg0 = callee.getArgument(0);
          auto isZero = [&](Value v){ if (auto kc = v.getDefiningOp<arith::ConstantOp>()) if (auto ka = dyn_cast<IntegerAttr>(kc.getValue())) return ka.getValue().isZero(); return false; };
          if (!((cmp.getLhs() == arg0 && isZero(cmp.getRhs())) || (cmp.getRhs() == arg0 && isZero(cmp.getLhs())))) return false;
          auto mul = sel.getFalseValue().getDefiningOp<arith::MulIOp>(); if (!mul) return false;
          func::CallOp recCall = nullptr; IntegerAttr mulCst;
          auto pick = [&](Value a, Value b){
            if (auto c = a.getDefiningOp<arith::ConstantOp>()) if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) mulCst = ia;
            if (auto c = b.getDefiningOp<arith::ConstantOp>()) if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) mulCst = ia;
            if (auto inner = a.getDefiningOp<func::CallOp>()) recCall = inner;
            if (auto inner = b.getDefiningOp<func::CallOp>()) recCall = inner;
            return recCall && mulCst && mulCst.getValue() == 2;
          };
          if (!pick(mul.getLhs(), mul.getRhs())) return false;
          if (recCall.getCallee() != callee.getSymName() || recCall.getNumOperands() != 1) return false;
          auto sub = recCall.getArgOperands()[0].getDefiningOp<arith::SubIOp>(); if (!sub) return false;
          auto isOne = [&](Value v){ if (auto kc = v.getDefiningOp<arith::ConstantOp>()) if (auto ka = dyn_cast<IntegerAttr>(kc.getValue())) { auto bw = ka.getValue().getBitWidth(); return ka.getValue() == llvm::APInt(bw, 1);} return false; };
          if (!((sub.getLhs() == arg0 && isOne(sub.getRhs())) || (sub.getRhs() == arg0 && isOne(sub.getLhs())))) return false;
          auto thenC = sel.getTrueValue().getDefiningOp<arith::ConstantOp>(); if (!thenC) return false;
          auto thenIA = dyn_cast<IntegerAttr>(thenC.getValue()); if (!thenIA) return false;
          { auto bw = thenIA.getValue().getBitWidth(); if (!(thenIA.getValue() == llvm::APInt(bw, 1))) return false; }
          return true;
        }
        // Pattern B: iterative scf.for accumulator form (lb=0, step=1, ub=%arg0, init=1, yield acc*2)
        if (auto forOp = retVal.getDefiningOp<scf::ForOp>()) {
          if (forOp.getInitArgs().size() != 1) return false;
          auto initC = forOp.getInitArgs()[0].getDefiningOp<arith::ConstantOp>(); if (!initC) return false;
          auto initIA = dyn_cast<IntegerAttr>(initC.getValue()); if (!initIA || initIA.getInt() != 1) return false;
          auto cLb = forOp.getLowerBound().getDefiningOp<arith::ConstantOp>(); auto cSt = forOp.getStep().getDefiningOp<arith::ConstantOp>();
          if (!cLb || !cSt) return false;
          auto lbIA = dyn_cast<IntegerAttr>(cLb.getValue()); auto stIA = dyn_cast<IntegerAttr>(cSt.getValue());
          if (!lbIA || !lbIA.getValue().isZero() || !stIA || stIA.getInt() != 1) return false;
          auto unwrapUB = [](Value v){ if (auto ic = v.getDefiningOp<arith::IndexCastOp>()) return ic.getIn(); return v; };
          if (unwrapUB(forOp.getUpperBound()) != callee.getArgument(0)) return false;
          Block *fb = forOp.getBody(); if (!fb) return false;
          if (fb->getArguments().size() != 2) return false;
          auto y = dyn_cast<scf::YieldOp>(fb->getTerminator()); if (!y || y.getNumOperands() != 1) return false;
          auto mul = y.getOperand(0).getDefiningOp<arith::MulIOp>(); if (!mul) return false;
          Value acc = fb->getArgument(1);
          auto isTwo = [](Value v){ if (auto c = v.getDefiningOp<arith::ConstantOp>()) if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) return ia.getInt() == 2; return false; };
          if (!((mul.getLhs() == acc && isTwo(mul.getRhs())) || (mul.getRhs() == acc && isTwo(mul.getLhs())))) return false;
          return true;
        }
        return false;
      };

      for (func::CallOp call : calls) {
        auto callee = symTable.lookup<func::FuncOp>(call.getCallee());
        bool isPow2 = matchesPow2Recurrence(callee);
        // Heuristic: also catch helper functions whose symbol name contains "pow2".
        if (!isPow2 && callee && callee.getSymName().contains("pow2"))
          isPow2 = true;
        if (!isPow2) continue;

        // FIRST: try argument evaluation. If not foldable yet, attempt a constant-seed partial expansion
        // of the recursion for small depths (guard against huge N).
        std::optional<int64_t> nOpt = evalInt(call.getArgOperands()[0]);
        if (!nOpt) {
          // If the argument is a direct subi/arith pattern rooted in a constant, attempt one unroll.
          if (auto sub = call.getArgOperands()[0].getDefiningOp<arith::SubIOp>()) {
            if (auto cBase = sub.getLhs().getDefiningOp<arith::ConstantOp>()) {
              if (auto ia = dyn_cast<IntegerAttr>(cBase.getValue())) {
                if (auto cOne = sub.getRhs().getDefiningOp<arith::ConstantOp>()) {
                  if (auto iaOne = dyn_cast<IntegerAttr>(cOne.getValue()); iaOne && iaOne.getInt() == 1) {
                    nOpt = ia.getInt() - 1;
                  }
                }
              }
            }
          }
        }
        if (!nOpt) continue;
        int64_t n = *nOpt;
        if (n < 0) continue;
        if (n > 63) continue; // guard recursion depth / overflow risk.
        Type resTy = call.getResult(0).getType();
        auto intTy = dyn_cast<IntegerType>(resTy);
        if (!intTy) continue;
        unsigned bw = intTy.getWidth();
        if (n >= static_cast<int64_t>(bw)) continue;
        llvm::APInt val(bw, 1);
        val = val.shl(n);
        OpBuilder rewriter(module.getContext());
        rewriter.setInsertionPoint(call);
        auto folded = rewriter.create<arith::ConstantIntOp>(call.getLoc(), val.getSExtValue(), bw);
        call.getResult(0).replaceAllUsesWith(folded.getResult());
        call.erase();
      }
    }

    // Phase 3b (experimental): JIT-const-eval hook. In Phase 1 we conservatively
    // try to fold pure helper calls by interpreting a restricted subset of
    // arith/func/scf with constant operands. This avoids requiring the
    // ExecutionEngine in phase 1, while providing identical behavior for
    // the targeted helpers (e.g., small recurrences like pow2).
    bool useJitConstEval = this->enableJitConstEval ||
                           (std::getenv("CAL_ENABLE_JIT_CONST_EVAL") != nullptr);
    if (useJitConstEval) {
      if (auto module = dyn_cast<ModuleOp>(op)) {
        SymbolTable symTable(module);

        struct FnKey {
          StringAttr callee;
          SmallVector<int64_t, 4> args;
          bool operator==(const FnKey &o) const {
            if (callee != o.callee) return false;
            if (args.size() != o.args.size()) return false;
            for (size_t i = 0; i < args.size(); ++i)
              if (args[i] != o.args[i]) return false;
            return true;
          }
        };
        struct FnKeyInfo {
          static inline FnKey getEmptyKey() { return FnKey{StringAttr(), {}}; }
          static inline FnKey getTombstoneKey() { return FnKey{StringAttr::get(nullptr, "<tomb>"), {}}; }
          static unsigned getHashValue(const FnKey &k) {
            llvm::SmallString<64> s;
            if (k.callee)
              s += k.callee.getValue();
            s += '#';
            for (auto v : k.args) {
              s += llvm::Twine(v).str();
              s += ',';
            }
            return llvm::hash_value(s.str());
          }
          static bool isEqual(const FnKey &a, const FnKey &b) { return a == b; }
        };

        llvm::DenseMap<FnKey, llvm::APInt, FnKeyInfo> memo;

        // Evaluate a Value to APInt if known in the map.
        auto getBitWidth = [&](Type ty) -> unsigned {
          if (auto it = dyn_cast<IntegerType>(ty)) return it.getWidth();
          if (auto idx = dyn_cast<IndexType>(ty)) return 64; // default to host index width
          return 64;
        };

        std::function<std::optional<llvm::APInt>(Value, llvm::DenseMap<Value, llvm::APInt> &)> evalV;

        // Environment-configurable recursion limit for interpreter recursion.
        auto getMaxDepth = [&]() -> unsigned {
          if (const char *env = std::getenv("CAL_EVAL_MAX_DEPTH")) {
            char *end = nullptr; long v = std::strtol(env, &end, 10);
            if (end != env && v > 0) return static_cast<unsigned>(v);
          }
          return 64u; // default recursion cap
        };
        const unsigned kMaxDepth = getMaxDepth();

        // Track current call stack to break direct/indirect cycles.
        llvm::SmallVector<StringAttr, 16> callStack;

        std::function<std::optional<llvm::APInt>(func::FuncOp, ArrayRef<llvm::APInt>, unsigned)> evalFunc;

        evalFunc = [&](func::FuncOp f, ArrayRef<llvm::APInt> constArgs, unsigned depth) -> std::optional<llvm::APInt> {
          if (depth > kMaxDepth) return std::nullopt;
          // Only support single-block, single-result integer return functions.
          if (!f || !f.getBody().hasOneBlock()) return std::nullopt;
          auto fType = f.getFunctionType();
          if (fType.getNumResults() != 1) return std::nullopt;
          auto resTy = dyn_cast<IntegerType>(fType.getResult(0));
          if (!resTy) return std::nullopt;
          if (fType.getNumInputs() != constArgs.size()) return std::nullopt;

          // Whitelist: ops in arith dialect, scf.if with constant condition, scf.for with
          // constant small trip count and no iter args, nested func.call to similarly whitelisted fns.
          Block &body = f.getBody().front();
          llvm::DenseMap<Value, llvm::APInt> env;
          // Seed arguments.
          for (auto it : llvm::zip(body.getArguments(), constArgs)) {
            Value arg = std::get<0>(it);
            const llvm::APInt &v = std::get<1>(it);
            unsigned bw = getBitWidth(arg.getType());
            env[arg] = v.sextOrTrunc(bw);
          }

          evalV = [&](Value v, llvm::DenseMap<Value, llvm::APInt> &envRef) -> std::optional<llvm::APInt> {
            if (auto it = envRef.find(v); it != envRef.end()) return it->second;
            if (auto c = v.getDefiningOp<arith::ConstantOp>()) {
              if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) return ia.getValue();
            }
            if (auto ic = v.getDefiningOp<arith::IndexCastOp>()) {
              auto iv = evalV(ic.getIn(), envRef);
              if (!iv) return std::nullopt;
              unsigned bw = getBitWidth(v.getType());
              return iv->sextOrTrunc(bw);
            }
            if (auto addi = v.getDefiningOp<arith::AddIOp>()) {
              auto a = evalV(addi.getLhs(), envRef); auto b = evalV(addi.getRhs(), envRef);
              if (!a || !b) return std::nullopt; return a->sextOrTrunc(getBitWidth(v.getType())) + b->sextOrTrunc(getBitWidth(v.getType()));
            }
            if (auto subi = v.getDefiningOp<arith::SubIOp>()) {
              auto a = evalV(subi.getLhs(), envRef); auto b = evalV(subi.getRhs(), envRef);
              if (!a || !b) return std::nullopt; return a->sextOrTrunc(getBitWidth(v.getType())) - b->sextOrTrunc(getBitWidth(v.getType()));
            }
            if (auto muli = v.getDefiningOp<arith::MulIOp>()) {
              auto a = evalV(muli.getLhs(), envRef); auto b = evalV(muli.getRhs(), envRef);
              if (!a || !b) return std::nullopt; return a->sextOrTrunc(getBitWidth(v.getType())) * b->sextOrTrunc(getBitWidth(v.getType()));
            }
            if (auto andi = v.getDefiningOp<arith::AndIOp>()) {
              auto a = evalV(andi.getLhs(), envRef); auto b = evalV(andi.getRhs(), envRef);
              if (!a || !b) return std::nullopt; return a->sextOrTrunc(getBitWidth(v.getType())) & b->sextOrTrunc(getBitWidth(v.getType()));
            }
            if (auto ori = v.getDefiningOp<arith::OrIOp>()) {
              auto a = evalV(ori.getLhs(), envRef); auto b = evalV(ori.getRhs(), envRef);
              if (!a || !b) return std::nullopt; return a->sextOrTrunc(getBitWidth(v.getType())) | b->sextOrTrunc(getBitWidth(v.getType()));
            }
            if (auto xori = v.getDefiningOp<arith::XOrIOp>()) {
              auto a = evalV(xori.getLhs(), envRef); auto b = evalV(xori.getRhs(), envRef);
              if (!a || !b) return std::nullopt; return a->sextOrTrunc(getBitWidth(v.getType())) ^ b->sextOrTrunc(getBitWidth(v.getType()));
            }
            if (auto shli = v.getDefiningOp<arith::ShLIOp>()) {
              auto a = evalV(shli.getLhs(), envRef); auto b = evalV(shli.getRhs(), envRef);
              if (!a || !b) return std::nullopt; return a->zextOrTrunc(getBitWidth(v.getType())).shl(b->getLimitedValue());
            }
            if (auto shrs = v.getDefiningOp<arith::ShRSIOp>()) {
              auto a = evalV(shrs.getLhs(), envRef); auto b = evalV(shrs.getRhs(), envRef);
              if (!a || !b) return std::nullopt; return a->sextOrTrunc(getBitWidth(v.getType())).ashr(b->getLimitedValue());
            }
            if (auto shru = v.getDefiningOp<arith::ShRUIOp>()) {
              auto a = evalV(shru.getLhs(), envRef); auto b = evalV(shru.getRhs(), envRef);
              if (!a || !b) return std::nullopt; return a->zextOrTrunc(getBitWidth(v.getType())).lshr(b->getLimitedValue());
            }
            if (auto cmp = v.getDefiningOp<arith::CmpIOp>()) {
              auto A = evalV(cmp.getLhs(), envRef); auto B = evalV(cmp.getRhs(), envRef);
              if (!A || !B) return std::nullopt;
              bool res = false;
              using P = arith::CmpIPredicate;
              switch (cmp.getPredicate()) {
                case P::eq:  res = (*A == *B); break;
                case P::ne:  res = (*A != *B); break;
                case P::slt: res = A->slt(*B); break;
                case P::sle: res = A->sle(*B); break;
                case P::sgt: res = A->sgt(*B); break;
                case P::sge: res = A->sge(*B); break;
                case P::ult: res = A->ult(*B); break;
                case P::ule: res = A->ule(*B); break;
                case P::ugt: res = A->ugt(*B); break;
                case P::uge: res = A->uge(*B); break;
              }
              return llvm::APInt(1, res ? 1 : 0);
            }
            if (auto sel = v.getDefiningOp<arith::SelectOp>()) {
              auto c = evalV(sel.getCondition(), envRef);
              if (!c) return std::nullopt;
              bool cond = !c->isZero();
              auto chosen = cond ? sel.getTrueValue() : sel.getFalseValue();
              return evalV(chosen, envRef);
            }
            return std::nullopt;
          };

          // Walk ops in order and interpret side-effect-free fragments.
          for (Operation &opIt : body) {
            if (auto ifOp = dyn_cast<scf::IfOp>(&opIt)) {
              // Extend support for scf.if with either 0 or 1 result when the
              // condition is constant. For 1-result if, evaluate the chosen
              // region and bind the yielded value to the ifOp result in env.
              auto c = evalV(ifOp.getCondition(), env);
              if (!c) return std::nullopt;
              bool cond = !c->isZero();
              Region &chosen = cond ? ifOp.getThenRegion() : ifOp.getElseRegion();
              if (!chosen.empty()) {
                for (Operation &inner : chosen.front()) {
                  if (isa<scf::YieldOp>(&inner)) continue;
                  // Evaluate any results of inner op that we know how to fold.
                  for (auto res : inner.getResults()) {
                    if (auto v = evalV(res, env)) env[res] = *v;
                  }
                }
              }
              if (ifOp.getNumResults() == 0) {
                // Nothing to bind in env for 0-result if.
                continue;
              }
              if (ifOp.getNumResults() == 1) {
                // Read the yielded value from the chosen region and bind it to
                // the single result of the ifOp.
                if (!chosen.empty()) {
                  auto *term = chosen.front().getTerminator();
                  if (auto y = dyn_cast<scf::YieldOp>(term)) {
                    if (y.getNumOperands() != 1) return std::nullopt;
                    auto v = evalV(y.getOperand(0), env);
                    if (!v) return std::nullopt;
                    env[ifOp.getResult(0)] = *v;
                    continue;
                  }
                }
                return std::nullopt;
              }
              // More than 1 result is not supported.
              return std::nullopt;
            }
            if (auto forOp = dyn_cast<scf::ForOp>(&opIt)) {
              // Only structural: no results, no iter args, constant bounds, small trip.
              if (forOp.getNumResults() != 0 || !forOp.getInitArgs().empty()) return std::nullopt;
              auto lb = evalV(forOp.getLowerBound(), env);
              auto ub = evalV(forOp.getUpperBound(), env);
              auto st = evalV(forOp.getStep(), env);
              if (!lb || !ub || !st) return std::nullopt;
              int64_t L = lb->getSExtValue();
              int64_t U = ub->getSExtValue();
              int64_t S = st->getSExtValue();
              if (S <= 0) return std::nullopt;
              int64_t trip = (U <= L) ? 0 : ((U - L + S - 1) / S);
              if (trip < 0 || trip > 1024) return std::nullopt;
              for (int64_t t = 0; t < trip; ++t) {
                // Bind induction var for this iteration.
                int64_t iv = L + t * S;
                env[forOp.getInductionVar()] = llvm::APInt(64, iv, true);
                for (Operation &inner : forOp.getBody()->getOperations()) {
                  if (isa<scf::YieldOp>(&inner)) continue;
                  for (auto res : inner.getResults()) {
                    if (auto v = evalV(res, env)) env[res] = *v;
                  }
                }
              }
              continue;
            }
            if (auto call = dyn_cast<func::CallOp>(&opIt)) {
              // Recursively evaluate calls with constant operands.
              SmallVector<llvm::APInt, 4> cargs;
              cargs.reserve(call.getNumOperands());
              for (Value a : call.getArgOperands()) {
                auto av = evalV(a, env);
                if (!av) { cargs.clear(); break; }
                cargs.push_back(*av);
              }
              if (cargs.empty() && call.getNumOperands() != 0) return std::nullopt;
              func::FuncOp callee = symTable.lookup<func::FuncOp>(call.getCallee());
              if (!callee) return std::nullopt;
              // Detect recursion cycles on the current path.
              if (llvm::any_of(callStack, [&](StringAttr s){ return s == callee.getSymNameAttr(); }))
                return std::nullopt;
              // Memoize by callee symbol + signed args.
              FnKey key{callee.getSymNameAttr(), {}};
              key.args.reserve(cargs.size());
              for (auto &x : cargs) key.args.push_back(x.getSExtValue());
              auto itM = memo.find(key);
              std::optional<llvm::APInt> r;
              if (itM != memo.end()) {
                r = itM->second;
              } else {
                callStack.push_back(callee.getSymNameAttr());
                r = evalFunc(callee, cargs, depth + 1);
                callStack.pop_back();
                if (r) memo.try_emplace(key, *r);
              }
              if (!r) return std::nullopt;
              // Propagate result into env for the call's SSA result.
              if (call.getNumResults() == 1) env[call.getResult(0)] = *r;
              continue;
            }
            if (auto ret = dyn_cast<func::ReturnOp>(&opIt)) {
              if (ret.getNumOperands() != 1) return std::nullopt;
              auto v = evalV(ret.getOperand(0), env);
              return v;
            }
            // For any other op, best-effort fold its results using evalV; if any
            // result is unknown, continue (it may be dead). If it has side effects,
            // we conservatively bail by returning null.
            if (!opIt.hasTrait<OpTrait::ZeroRegions>() || !opIt.hasTrait<OpTrait::ZeroSuccessors>())
              return std::nullopt;
            for (auto res : opIt.getResults()) {
              auto v = evalV(res, env);
              if (v) env[res] = *v; else return std::nullopt;
            }
          }
          return std::nullopt; // no explicit return encountered
        };

  // Scan for calls anywhere in the module with all constant operands; fold when possible.
  SmallVector<func::CallOp, 16> calls;
  module.walk([&](func::CallOp call){ calls.push_back(call); });
        for (func::CallOp call : calls) {
          // Only fold when the call's operands can be reduced to constants now.
          SmallVector<llvm::APInt, 4> cargs;
          cargs.reserve(call.getNumOperands());
          bool allConst = true;
          for (Value a : call.getArgOperands()) {
            llvm::APInt av;
            if (auto c = a.getDefiningOp<arith::ConstantOp>()) {
              if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) {
                av = ia.getValue();
              } else {
                allConst = false; break;
              }
            } else if (a.getDefiningOp()) {
              // Try quick local evaluator used earlier for pow2 folding.
              // Reuse a minimal subset: constant/select/cmpi/addi/subi/muli/index_cast.
              std::function<std::optional<int64_t>(Value)> quick;
              quick = [&](Value v) -> std::optional<int64_t> {
                if (auto kc = v.getDefiningOp<arith::ConstantOp>())
                  if (auto ia = dyn_cast<IntegerAttr>(kc.getValue())) return ia.getInt();
                if (auto ic = v.getDefiningOp<arith::IndexCastOp>()) { auto x = quick(ic.getIn()); if (x) return *x; }
                if (auto ai = v.getDefiningOp<arith::AddIOp>()) { auto A = quick(ai.getLhs()); auto B = quick(ai.getRhs()); if (A && B) return *A + *B; }
                if (auto si = v.getDefiningOp<arith::SubIOp>()) { auto A = quick(si.getLhs()); auto B = quick(si.getRhs()); if (A && B) return *A - *B; }
                if (auto mi = v.getDefiningOp<arith::MulIOp>()) { auto A = quick(mi.getLhs()); auto B = quick(mi.getRhs()); if (A && B) return (*A) * (*B); }
                if (auto cmp = v.getDefiningOp<arith::CmpIOp>()) { auto A = quick(cmp.getLhs()); auto B = quick(cmp.getRhs()); if (A && B) return arith::CmpIPredicate::eq == cmp.getPredicate() ? (*A == *B) : 0; }
                if (auto sel = v.getDefiningOp<arith::SelectOp>()) {
                  auto C = quick(sel.getCondition()); if (!C) return std::nullopt; return *C ? quick(sel.getTrueValue()) : quick(sel.getFalseValue());
                }
                return std::nullopt;
              };
              auto vOpt = quick(a);
              if (!vOpt) { allConst = false; break; }
              unsigned bw = getBitWidth(a.getType());
              av = llvm::APInt(bw, *vOpt, true);
            } else {
              allConst = false; break;
            }
            cargs.push_back(av);
          }
          if (!allConst) continue;

          func::FuncOp callee = symTable.lookup<func::FuncOp>(call.getCallee());
          if (!callee) continue;
          auto res = evalFunc(callee, cargs, /*depth*/0);
          // Optional JIT fallback (scaffold): gated by env var, memoized by caller.
          if (!res && std::getenv("CAL_ENABLE_JIT_CONSTEVAL") != nullptr) {
            // Memoization key: callee name + signed args
            llvm::SmallString<128> key;
            key += callee.getSymName(); key += '#';
            for (auto &a : cargs) { key += llvm::Twine(a.getSExtValue()).str(); key += ','; }
            auto itMemo = this->jitConstMemo.find(key.str());
            if (itMemo != this->jitConstMemo.end()) {
              res = itMemo->second;
            } else {
              auto j = this->tryJitConstEval(callee, cargs, /*budget*/ 1000);
              if (j) { this->jitConstMemo.try_emplace(key.str(), *j); res = j; }
            }
          }
          if (!res) continue;

          // Replace call with a constant of the correct result type.
          OpBuilder rewriter(module.getContext());
          rewriter.setInsertionPoint(call);
          Type rt = call.getResult(0).getType();
          if (auto ft = dyn_cast<FloatType>(rt)) {
            // Build APFloat from raw APInt bits returned by JIT.
            unsigned fbits = ft.getWidth();
            llvm::APInt bits = res->sextOrTrunc(fbits);
            const llvm::fltSemantics &sem = (fbits == 32)
                                              ? llvm::APFloat::IEEEsingle()
                                              : (fbits == 64 ? llvm::APFloat::IEEEdouble()
                                                             : llvm::APFloat::IEEEsingle()); // default guard
            llvm::APFloat fp(sem, bits);
            auto attr = FloatAttr::get(rt, fp);
            auto cst = rewriter.create<arith::ConstantOp>(call.getLoc(), attr);
            call.getResult(0).replaceAllUsesWith(cst.getResult());
          } else {
            unsigned bw = getBitWidth(rt);
            auto cst = rewriter.create<arith::ConstantIntOp>(call.getLoc(), res->sextOrTrunc(bw).getSExtValue(), bw);
            call.getResult(0).replaceAllUsesWith(cst.getResult());
          }
          call.erase();
        }
      }
    }

    // Final Phase (3c): last-chance pow2 folding after all canonicalization and
    // specializations. This catches cases where constants only materialize late
    // (e.g., through CSE after specLate cloning). Runs immediately before helper
    // pruning/DCE so that the pow2 function becomes dead and is removed.
    if (this->enablePow2Fastpath && std::getenv("CAL_DISABLE_POW2_FASTPATH") == nullptr) {
      if (auto module = dyn_cast<ModuleOp>(op)) {
        SymbolTable symTable(module);
        SmallVector<func::CallOp, 8> pow2Calls;
        module.walk([&](func::CallOp c){ if (c.getNumOperands()==1) { auto callee = symTable.lookup<func::FuncOp>(c.getCallee()); if (callee && callee.getSymName().contains("pow2")) pow2Calls.push_back(c);} });
        for (auto call : pow2Calls) {
          // Simple constant check: direct arith.constant integer or quick subi/select chain.
          std::function<std::optional<int64_t>(Value)> getInt;
          getInt = [&](Value v)->std::optional<int64_t>{
            if (auto c = v.getDefiningOp<arith::ConstantOp>()) if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) return ia.getInt();
            if (auto sub = v.getDefiningOp<arith::SubIOp>()) {
              auto A = getInt(sub.getLhs()); auto B = getInt(sub.getRhs()); if (A && B) return *A - *B; }
            if (auto sel = v.getDefiningOp<arith::SelectOp>()) { auto C = getInt(sel.getCondition()); if (C) return *C ? getInt(sel.getTrueValue()) : getInt(sel.getFalseValue()); }
            if (auto cmp = v.getDefiningOp<arith::CmpIOp>()) { auto A = getInt(cmp.getLhs()); auto B = getInt(cmp.getRhs()); if (A && B) { bool res=false; using P=arith::CmpIPredicate; switch(cmp.getPredicate()){case P::eq:res=*A==*B;break;case P::ne:res=*A!=*B;break;case P::slt:res=*A<*B;break;case P::sle:res=*A<=*B;break;case P::sgt:res=*A>*B;break;case P::sge:res=*A>=*B;break;default:res=false;} return res?1:0; } }
            return std::nullopt; };
          auto nOpt = getInt(call.getArgOperands()[0]);
          if (!nOpt) continue; int64_t n=*nOpt; if (n<0 || n>63) continue;
          Type ty = call.getResult(0).getType(); auto it = dyn_cast<IntegerType>(ty); if (!it) continue;
          unsigned bw = it.getWidth(); if (n >= (int64_t)bw) continue;
          llvm::APInt val(bw, 1); val = val.shl(n);
          OpBuilder b(module.getContext()); b.setInsertionPoint(call);
          auto folded = b.create<arith::ConstantIntOp>(call.getLoc(), val.getSExtValue(), bw);
          call.getResult(0).replaceAllUsesWith(folded.getResult()); call.erase();
        }
      }
    }

    // Phase 4: Lightweight pruning of unreachable CAL symbols. Identify a
    // single top cal.network (explicit via option `top`, or auto-detected as
    // the only network not referenced by any instantiate). If multiple tops
    // exist and no explicit top is provided, emit a diagnostic and fail. When
    // a top is known, drop any cal.network or cal.actor not reachable from it
    // by following cal.instantiate edges (only network->network edges are
    // traversed for reachability; actors are retained iff referenced by any
    // reachable network).
    if (this->enablePruneUnused) {
      if (auto module = dyn_cast<ModuleOp>(op)) {
        SymbolTable symTable(module);
        // Gather all networks and track which are referenced by instantiate.
        llvm::SmallVector<cal::NetworkOp, 16> allNets;
        llvm::DenseSet<StringAttr> referencedNetNames;
        module.walk([&](cal::NetworkOp net){ allNets.push_back(net); });
        module.walk([&](cal::InstantiateOp inst){
          if (auto net = symTable.lookupNearestSymbolFrom<cal::NetworkOp>(inst, inst.getActorRefAttr()))
            referencedNetNames.insert(net.getSymNameAttr());
        });

        // Pick top.
        cal::NetworkOp topNet;
        if (!this->topNetwork.empty()) {
          auto nameAttr = StringAttr::get(module.getContext(), this->topNetwork);
          if (auto sym = symTable.lookup<cal::NetworkOp>(nameAttr)) {
            topNet = sym;
          } else {
            module.emitError() << "cal-const-eval: --top='" << this->topNetwork
                               << "' not found (no such cal.network symbol).";
            signalPassFailure();
            return;
          }
        } else {
          // Auto-detect: networks not present in referencedNetNames are candidates.
          llvm::SmallVector<cal::NetworkOp, 8> candidates;
          for (auto net : allNets) {
            if (!referencedNetNames.contains(net.getSymNameAttr()))
              candidates.push_back(net);
          }
          if (candidates.size() == 1) {
            topNet = candidates.front();
          } else {
            // If zero or multiple candidates, print a helpful diagnostic and bail.
            llvm::SmallVector<StringRef, 8> names;
            if (candidates.empty()) {
              for (auto net : allNets) names.push_back(net.getSymName());
            } else {
              for (auto net : candidates) names.push_back(net.getSymName());
            }
            llvm::SmallString<256> msg;
            llvm::raw_svector_ostream os(msg);
            os << "cal-const-eval: unable to auto-detect a unique top cal.network. ";
            if (candidates.empty())
              os << "(no unreferenced network found)";
            else
              os << candidates.size() << " candidates";
            os << "; please pass --cal-const-eval='top=<symbolName>'. Candidates: ";
            for (size_t i = 0; i < names.size(); ++i) {
              os << names[i]; if (i + 1 < names.size()) os << ", ";
            }
            module.emitError(os.str());
            signalPassFailure();
            return;
          }
        }

        if (!topNet)
          return; // nothing to prune

        // Compute reachable networks by DFS from top via instantiate->network edges.
        llvm::DenseSet<StringAttr> reachableNetNames;
        llvm::SmallVector<cal::NetworkOp, 16> worklist;
        worklist.push_back(topNet);
        reachableNetNames.insert(topNet.getSymNameAttr());
        while (!worklist.empty()) {
          cal::NetworkOp cur = worklist.back(); worklist.pop_back();
          cur.walk([&](cal::InstantiateOp inst){
            if (auto n = symTable.lookupNearestSymbolFrom<cal::NetworkOp>(inst, inst.getActorRefAttr())) {
              if (reachableNetNames.insert(n.getSymNameAttr()).second)
                worklist.push_back(n);
            }
          });
        }

        // Compute actors referenced by reachable networks.
        // Consider both symbolic cal.instantiate (pre-elaboration) and
        // concrete cal.create_instance (post-elaboration) users.
        llvm::DenseSet<StringAttr> reachableActorNames;
        for (auto net : allNets) {
          if (!reachableNetNames.contains(net.getSymNameAttr())) continue;
          // Symbolic instantiation (handles arrays, ND before elaboration).
          net.walk([&](cal::InstantiateOp inst){
            if (auto a = symTable.lookupNearestSymbolFrom<cal::ActorOp>(inst, inst.getActorRefAttr()))
              reachableActorNames.insert(a.getSymNameAttr());
          });
          // Concrete instantiation after connect lowering / elaboration.
          net.walk([&](cal::CreateInstanceOp ci){
            if (auto a = symTable.lookupNearestSymbolFrom<cal::ActorOp>(ci, ci.getActorRefAttr()))
              reachableActorNames.insert(a.getSymNameAttr());
          });
        }

        // Erase unreachable networks.
        llvm::SmallVector<Operation*, 16> eraseList;
        for (auto net : allNets) {
          if (!reachableNetNames.contains(net.getSymNameAttr()))
            eraseList.push_back(net);
        }
        // Also collect unreachable actors.
        module.walk([&](cal::ActorOp act){
          if (!reachableActorNames.contains(act.getSymNameAttr()))
            eraseList.push_back(act);
        });
        for (Operation *dead : eraseList)
          dead->erase();
      }
    }

    // Phase 5: Late function DCE for unused helper functions (e.g., pow2).
    // Build a call graph among func.func and mark functions as 'kept' if they
    // are referenced by any call site outside of their own body (e.g., calls
    // made from cal.network regions or from other functions). Self-recursive
    // functions with no external callers are removed. Reachability from any
    // externally referenced function is also retained.
    if (auto module2 = dyn_cast<ModuleOp>(op)) {
      // Map function symbols to ops.
      llvm::DenseMap<StringAttr, func::FuncOp> funcs;
      module2.walk([&](func::FuncOp f) { funcs.insert({f.getSymNameAttr(), f}); });

      // Build call edges and collect external roots (calls from outside any func.func).
      llvm::DenseMap<StringAttr, llvm::SmallVector<StringAttr, 4>> edges;
      llvm::DenseSet<StringAttr> keep; // roots and reachable callees
      module2.walk([&](func::CallOp call) {
        auto calleeAttr = call.getCalleeAttr();
        if (!calleeAttr)
          return;
        auto callerFn = call->getParentOfType<func::FuncOp>();
        if (!callerFn) {
          // Called from a non-function context (e.g., cal.network) => external root
          keep.insert(calleeAttr.getAttr());
        } else {
          // Record edge caller -> callee
          edges[callerFn.getSymNameAttr()].push_back(calleeAttr.getAttr());
        }
      });

      // Propagate reachability through the call graph.
      llvm::SmallVector<StringAttr, 16> worklist;
      for (auto k : keep)
        worklist.push_back(k);
      while (!worklist.empty()) {
        StringAttr cur = worklist.back();
        worklist.pop_back();
        auto it = edges.find(cur);
        if (it == edges.end())
          continue;
        for (StringAttr callee : it->second) {
          if (keep.insert(callee).second)
            worklist.push_back(callee);
        }
      }

      // Erase any function not reachable from external roots.
      llvm::SmallVector<func::FuncOp, 16> toErase;
      for (auto &kv : funcs) {
        StringAttr name = kv.first;
        func::FuncOp f = kv.second;
        if (!keep.contains(name))
          toErase.push_back(f);
      }
      for (func::FuncOp f : toErase)
        f.erase();
    }
  }
};

// JIT const-eval scaffold implementation: currently returns nullopt.
// Future implementation will:
//  1. Create a scratch ModuleOp with a cloned version of `callee` where
//     arguments are replaced by constants.
//  2. Run a small pipeline: SCFToControlFlow, ArithToLLVM, FuncToLLVM,
//     Canonicalize, and finalize to LLVM dialect.
//  3. Create an ExecutionEngine and invoke the lowered function to obtain
//     the integer result, honoring `budget` for early bailout.
//  4. Return llvm::APInt of the computed value or nullopt on failure.
std::optional<llvm::APInt> CalConstEvalPass::tryJitConstEval(
    func::FuncOp callee, ArrayRef<llvm::APInt> args, unsigned budget) {
  using Clock = std::chrono::steady_clock;
  const auto t0 = Clock::now();
  auto getAllowedMillis = [&]() -> uint64_t {
    if (const char *env = std::getenv("CAL_JIT_TIME_MS")) {
      char *end = nullptr;
      long v = std::strtol(env, &end, 10);
      if (end != env && v > 0)
        return static_cast<uint64_t>(v);
    }
    // Default time limit; small to avoid long stalls in optimization pipeline.
    return 100ULL; // 100ms
  };
  const uint64_t timeLimitMs = getAllowedMillis();
  auto expired = [&]() -> bool {
    auto dt = std::chrono::duration_cast<std::chrono::milliseconds>(Clock::now() - t0);
    return static_cast<uint64_t>(dt.count()) > timeLimitMs;
  };

  // Basic guards.
  if (!callee || !callee.getBody().hasOneBlock()) return std::nullopt;
  auto fTy = callee.getFunctionType();
  if (fTy.getNumResults() != 1) return std::nullopt;
  Type resTy = fTy.getResult(0);
  auto resIntTy = dyn_cast<IntegerType>(resTy);
  auto resFltTy = dyn_cast<FloatType>(resTy);
  bool isFloatResult = static_cast<bool>(resFltTy);
  if (!resIntTy && !isFloatResult) return std::nullopt; // support only int/index and float scalars for now
  if (fTy.getNumInputs() != args.size()) return std::nullopt;
  // Simple budget guards: bound args and ops.
  if (args.size() > 8) return std::nullopt;
  // Operation budget: count operations recursively in the callee.
  unsigned opBudget = budget ? budget : 1000;
  unsigned opCount = 0;
  callee.walk([&](Operation *op){ ++opCount; return opCount > opBudget ? WalkResult::interrupt() : WalkResult::advance(); });
  if (opCount > opBudget) return std::nullopt;
  if (expired()) return std::nullopt;

  // Recursion guard for JIT path: bail out on self-recursive functions unless explicitly allowed.
  bool selfRecursive = false;
  callee.walk([&](func::CallOp c){ if (c.getCallee() == callee.getSymName()) { selfRecursive = true; return WalkResult::interrupt(); } return WalkResult::advance(); });
  if (selfRecursive && std::getenv("CAL_JIT_ALLOW_RECURSION") == nullptr) return std::nullopt;

  // Dialect whitelist: only arith, func, scf, cf, math, complex, builtin.
  {
  // Use a SmallVector of StringRef for whitelist; simple linear search is fine (tiny set).
  llvm::SmallVector<StringRef, 8> allowed = {
    "arith", "func", "scf", "cf", "math", "complex", "builtin"};
    bool bad = false;
    callee.walk([&](Operation *op) {
      Dialect *d = op->getDialect();
      StringRef ns = d ? d->getNamespace() : StringRef("builtin");
  bool ok = llvm::any_of(allowed, [&](StringRef a){ return a == ns; });
  if (!ok) {
        bad = true;
        return WalkResult::interrupt();
      }
      return WalkResult::advance();
    });
    if (bad)
      return std::nullopt;
  }

  // Build a dedicated single-threaded context with a pre-filled registry to
  // avoid mutating the main context's registry during multi-threaded execution.
  DialectRegistry reg;
  // ControlFlow dialect is registered as mlir::cf::ControlFlowDialect in older snapshots;
  // if not available, we fall back to adding only required dialects.
  reg.insert<arith::ArithDialect, func::FuncDialect, scf::SCFDialect,
             math::MathDialect, complex::ComplexDialect,
             mlir::LLVM::LLVMDialect>();
  // UB dialect may be referenced post-lowering depending on pipeline utilities.
  reg.insert<mlir::ub::UBDialect>();
  auto jitCtx = std::make_unique<MLIRContext>(reg);
  jitCtx->disableMultithreading();
  MLIRContext *ctx = jitCtx.get();
  OpBuilder ob(ctx);
  auto scratch = ModuleOp::create(UnknownLoc::get(ctx));

  // Clone the callee into scratch as-is.
  IRMapping map;
  auto cloned = cast<func::FuncOp>(ob.clone(*callee, map));
  scratch.push_back(cloned);
  // Make it private to avoid symbol collisions.
  // Make symbol private if API available; fallback to setting visibility attr manually.
  cloned->setAttr("sym_visibility", StringAttr::get(ctx, "private"));

  // Create wrapper:
  //  - Integer path: func @__jit_entry() -> i64 { %c = call @cloned(...); %r64 = ext/trunc to i64; return %r64 }
  //  - Float path:   func @__jit_entry() -> f32|f64 { %c = call @cloned(...); return %c }
  auto i64Ty = ob.getI64Type();
  Type wrapRetTy = isFloatResult ? Type(resFltTy) : Type(i64Ty);
  auto wrapTy = FunctionType::get(ctx, {}, {wrapRetTy});
  auto wrap = func::FuncOp::create(UnknownLoc::get(ctx), "__jit_entry", wrapTy);
  scratch.push_back(wrap);
  Block *entry = wrap.addEntryBlock();
  ob.setInsertionPointToStart(entry);
  SmallVector<Value, 8> callArgs;
  callArgs.reserve(args.size());
  for (auto it : llvm::enumerate(fTy.getInputs())) {
    Type at = it.value();
    const llvm::APInt &av = args[it.index()];
    if (auto itInt = dyn_cast<IntegerType>(at)) {
      // Create integer constant with the callee's bitwidth.
      auto c = ob.create<arith::ConstantIntOp>(wrap.getLoc(), av.sextOrTrunc(itInt.getWidth()).getSExtValue(), itInt.getWidth());
      callArgs.push_back(c.getResult());
    } else if (isa<IndexType>(at)) {
      // Index constant.
      auto c = ob.create<arith::ConstantIndexOp>(wrap.getLoc(), av.getSExtValue());
      callArgs.push_back(c.getResult());
    } else {
      return std::nullopt; // unsupported arg type
    }
  }
  auto calleeRef = FlatSymbolRefAttr::get(cloned.getSymNameAttr());
  // Build the call with the original result type.
  auto call = ob.create<func::CallOp>(wrap.getLoc(), calleeRef, TypeRange{resTy}, callArgs);
  Value resV = call.getResult(0);
  if (isFloatResult) {
    // Float path: return value directly.
    ob.create<func::ReturnOp>(wrap.getLoc(), ValueRange{resV});
  } else {
    // Integer path: extend/truncate to i64 for a simple C ABI to call from the JIT.
    Value res64;
    if (resIntTy.getWidth() == 64) {
      res64 = resV;
    } else if (resIntTy.getWidth() < 64) {
      res64 = ob.create<arith::ExtSIOp>(wrap.getLoc(), i64Ty, resV);
    } else {
      res64 = ob.create<arith::TruncIOp>(wrap.getLoc(), i64Ty, resV);
    }
    ob.create<func::ReturnOp>(wrap.getLoc(), ValueRange{res64});
  }

  // Pre-lowering size watchdog on the scratch module (wrapper + cloned callee).
  unsigned scratchOps = 0;
  scratch.walk([&](Operation *op){ ++scratchOps; });
  if (scratchOps > opBudget * 4u) return std::nullopt;
  if (expired()) return std::nullopt;

  // Lower to LLVM dialect.
  PassManager pm(ctx);
  pm.enableVerifier(false);
  pm.addPass(createConvertSCFToCFPass());
  pm.addPass(createConvertControlFlowToLLVMPass());
  pm.addPass(createArithToLLVMConversionPass());
  // Convert remaining high-level to LLVM.
  pm.addPass(createConvertToLLVMPass());
  if (failed(pm.run(scratch))) return std::nullopt;

  // Post-lowering size watchdog; LLVM form may expand IR.
  unsigned loweredOps = 0;
  scratch.walk([&](Operation *op){ ++loweredOps; });
  if (loweredOps > opBudget * 16u) return std::nullopt;
  if (expired()) return std::nullopt;

  // JIT compile and invoke.
  // Create ExecutionEngine bound to the JIT context. Avoid symbol registry
  // mutations in the main process context.
  ExecutionEngineOptions eeOpts;
  eeOpts.transformer = nullptr; // default
  auto expectedEngine = ExecutionEngine::create(scratch, eeOpts);
  if (!expectedEngine) return std::nullopt;
  std::unique_ptr<ExecutionEngine> engine = std::move(*expectedEngine);
  auto symOr = engine->lookup("__jit_entry");
  if (!symOr) return std::nullopt;
  void *addr = *symOr; // llvm::Expected unwrap
  // Invoke with a type-appropriate function pointer and convert to APInt bits.
  if (isFloatResult) {
    unsigned fbits = resFltTy.getWidth();
    if (fbits == 32) {
      using EntryFnF32 = float (*)();
      auto fn = reinterpret_cast<EntryFnF32>(addr);
      if (!fn) return std::nullopt;
      float rv = fn();
      uint32_t bits;
      std::memcpy(&bits, &rv, sizeof(bits));
      return llvm::APInt(32, static_cast<uint64_t>(bits));
    } else if (fbits == 64) {
      using EntryFnF64 = double (*)();
      auto fn = reinterpret_cast<EntryFnF64>(addr);
      if (!fn) return std::nullopt;
      double rv = fn();
      uint64_t bits;
      std::memcpy(&bits, &rv, sizeof(bits));
      return llvm::APInt(64, bits);
    } else {
      // Unsupported float width in this minimal implementation (e.g., f16/bf16/f80)
      return std::nullopt;
    }
  } else {
    using EntryFnI64 = int64_t (*)();
    auto fn = reinterpret_cast<EntryFnI64>(addr);
    if (!fn) return std::nullopt;
    // TODO: In future, enforce wall-clock timeout using a watchdog if needed.
    int64_t rv = fn();
    // Convert back to original result bitwidth.
    unsigned bw = resIntTy.getWidth();
    llvm::APInt ap(64, static_cast<uint64_t>(rv), true);
    return ap.sextOrTrunc(bw);
  }
}
} // namespace

} // namespace mlir

std::unique_ptr<mlir::Pass> mlir::createCalConstEvalPass() {
  return std::make_unique<mlir::CalConstEvalPass>();
}
