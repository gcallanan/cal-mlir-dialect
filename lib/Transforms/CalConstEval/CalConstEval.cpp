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
// The canonicalizer/inliner may reference UB ops; ensure the dialect is registered.
#include "mlir/Dialect/UB/IR/UBOps.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/SymbolTable.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/Passes.h"
// For DialectInlinerInterface detection (guarded inliner usage)
#include "mlir/Transforms/InliningUtils.h"
// Env var check
#include <cstdlib>
// APInt for safe constant evaluation
#include "llvm/ADT/APInt.h"
// CAL ops to scope work under cal.network
#include "Dialect/Cal/CalOps.h"
#include "Transforms/Passes.h"

using namespace mlir;

namespace mlir {
#define GEN_PASS_DEF_CALCONSTEVALPASS
#include "Transforms/Passes.h.inc"

namespace {
struct CalConstEvalPass : public impl::CalConstEvalPassBase<CalConstEvalPass> {
  void runOnOperation() override {
    // Run a tiny inner pipeline: prefer MLIR's inliner when available,
    // otherwise fall back to a simple local inliner, then canonicalize.
    Operation *op = getOperation();

    bool ranGlobalInliner = false;
    // Use an opt-in env var to enable MLIR's global inliner. This avoids
    // hard failures on builds where the inliner interface isn't registered.
  if (std::getenv("CAL_ENABLE_GLOBAL_INLINER") != nullptr) {
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
          // Restrict const-eval to calls that are nested within a cal.network
          if (call->getParentOfType<cal::NetworkOp>())
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

    // Phase 2: Inline cal.network bodies at instantiate sites when all
    // actual operands are constants. This specializes nested networks so
    // structural predicates (e.g., scf.if on %NSTAGES) become foldable
    // before the main flattening pass runs.
    if (auto module = dyn_cast<ModuleOp>(op)) {
      SymbolTable symTable(module);
      bool changed = true;
      unsigned guard = 0, guardMax = 8; // avoid pathological growth
      while (changed && guard++ < guardMax) {
        changed = false;
        SmallVector<cal::InstantiateOp, 16> insts;
        module.walk([&](cal::InstantiateOp inst) {
          // Only consider instantiations nested within a cal.network.
          if (!inst->getParentOfType<cal::NetworkOp>()) return;
          // Require all operands to be arith.constant so we can specialize.
          bool allConst = llvm::all_of(inst.getOperands(), [](Value v){
            return v.getDefiningOp<arith::ConstantOp>() != nullptr;
          });
          if (!allConst) return;
          // Only inline when the target is a cal.network symbol.
          auto target = symTable.lookupNearestSymbolFrom<cal::NetworkOp>(inst, inst.getActorRefAttr());
          if (!target) return;
          insts.push_back(inst);
        });
        for (cal::InstantiateOp inst : insts) {
          auto parentNet = inst->getParentOfType<cal::NetworkOp>();
          if (!parentNet) continue;
          auto target = symTable.lookupNearestSymbolFrom<cal::NetworkOp>(inst, inst.getActorRefAttr());
          if (!target) continue;

          // Map formal block arguments to constant actuals.
          IRMapping map;
          auto formalArgs = target.getBody().getArguments();
          auto actuals = inst.getOperands();
          if (formalArgs.size() != actuals.size())
            continue; // arity mismatch – ignore, verified elsewhere
          for (auto it : llvm::zip(formalArgs, actuals))
            map.map(std::get<0>(it), std::get<1>(it));

          // Clone all non-symbol ops from the target body into the parent network.
          Block &body = target.getBody().front();
          IRRewriter rewriter(module.getContext());
          rewriter.setInsertionPoint(inst);
          for (Operation &inner : body.getOperations()) {
            // Skip nested symbol ops (networks/actors) – we only need the body content.
            if (isa<cal::NetworkOp>(&inner) || isa<cal::ActorOp>(&inner))
              continue;
            Operation *cloned = rewriter.clone(inner, map);
            // Maintain mapping for any subsequent ops.
            for (auto [oldRes, newRes] : llvm::zip(inner.getResults(), cloned->getResults()))
              map.map(oldRes, newRes);
          }
          inst.erase();
          changed = true;
        }

        if (changed) {
          // Clean up newly inlined regions (fold cmp/ifs, CSE etc.).
          PassManager pm3(op->getContext());
          pm3.enableVerifier(false);
          pm3.addPass(mlir::createCanonicalizerPass());
          if (failed(pm3.run(op))) {
            signalPassFailure();
            return;
          }
        }
      }
    }

    // Phase 3: Recognize and fold simple recursive pow-style helpers when
    // called with constant integer arguments. This makes array extents and
    // scf conditions fully static earlier.
    if (auto module = dyn_cast<ModuleOp>(op)) {
      SymbolTable symTable(module);
      SmallVector<func::CallOp, 16> calls;
      module.walk([&](func::CallOp call) {
        if (!call->getParentOfType<cal::NetworkOp>()) return; // only in networks
        if (call.getNumOperands() != 1) return;               // 1-arg helpers
        // Only if arg is an arith.constant integer.
        auto cst = call.getArgOperands()[0].getDefiningOp<arith::ConstantOp>();
        if (!cst) return;
        auto intAttr = dyn_cast_or_null<IntegerAttr>(cst.getValue());
        if (!intAttr) return;
        calls.push_back(call);
      });

      auto matchesPow2Recurrence = [](func::FuncOp callee) -> bool {
        // Heuristic: returns select(cmp eq %arg0, 0, muli(call @callee(subi %arg0, 1), 2))
        if (!callee || !callee.getBody().hasOneBlock()) return false;
        Block &body = callee.getBody().front();
        auto ret = dyn_cast_or_null<func::ReturnOp>(body.getTerminator());
        if (!ret || ret.getNumOperands() != 1) return false;
        auto sel = ret.getOperand(0).getDefiningOp<arith::SelectOp>();
        if (!sel) return false;
        auto cmp = sel.getCondition().getDefiningOp<arith::CmpIOp>();
        if (!cmp || cmp.getPredicate() != arith::CmpIPredicate::eq) return false;
        // cmp(%arg0, 0)
        auto arg0 = callee.getArgument(0);
        Value lhs = cmp.getLhs();
        Value rhs = cmp.getRhs();
        auto isZero = [&](Value v){
          if (auto kc = v.getDefiningOp<arith::ConstantOp>())
            if (auto ka = dyn_cast<IntegerAttr>(kc.getValue()))
              return ka.getValue().isZero();
          return false;
        };
        if (!((lhs == arg0 && isZero(rhs)) || (rhs == arg0 && isZero(lhs))))
          return false;
        // else-value should be muli(call @callee(subi %arg0, 1), 2)
        auto mul = sel.getFalseValue().getDefiningOp<arith::MulIOp>();
        if (!mul) return false;
        // Identify the recursive call and the constant multiplier (2)
        func::CallOp recCall = nullptr;
        IntegerAttr mulCst;
        auto pickCallAndConst = [&](Value a, Value b) -> bool {
          if (auto c = a.getDefiningOp<arith::ConstantOp>()) {
            if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) { mulCst = ia; }
          }
          if (auto c = b.getDefiningOp<arith::ConstantOp>()) {
            if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) { mulCst = ia; }
          }
          if (auto inner = a.getDefiningOp<func::CallOp>()) recCall = inner;
          if (auto inner = b.getDefiningOp<func::CallOp>()) recCall = inner;
          return recCall && mulCst && mulCst.getValue() == 2;
        };
        if (!pickCallAndConst(mul.getLhs(), mul.getRhs())) return false;
        if (recCall.getCallee() != callee.getSymName()) return false;
        // The recursive call arg should be subi(%arg0, 1)
        if (recCall.getNumOperands() != 1) return false;
        auto sub = recCall.getArgOperands()[0].getDefiningOp<arith::SubIOp>();
        if (!sub) return false;
        auto isOne = [&](Value v){
          if (auto kc = v.getDefiningOp<arith::ConstantOp>()) {
            if (auto ka = dyn_cast<IntegerAttr>(kc.getValue())) {
              auto bw = ka.getValue().getBitWidth();
              return ka.getValue() == llvm::APInt(bw, 1);
            }
          }
          return false;
        };
        if (!((sub.getLhs() == arg0 && isOne(sub.getRhs())) ||
              (sub.getRhs() == arg0 && isOne(sub.getLhs()))))
          return false;
        // then-value in select should be constant 1
        auto thenC = sel.getTrueValue().getDefiningOp<arith::ConstantOp>();
        if (!thenC) return false;
        auto thenIA = dyn_cast<IntegerAttr>(thenC.getValue());
        if (!thenIA) return false;
        {
          auto bw = thenIA.getValue().getBitWidth();
          if (!(thenIA.getValue() == llvm::APInt(bw, 1))) return false;
        }
        return true;
      };

      for (func::CallOp call : calls) {
        auto callee = symTable.lookup<func::FuncOp>(call.getCallee());
        if (!matchesPow2Recurrence(callee)) continue;
        // Evaluate 2^n in the result bitwidth.
        auto argC = dyn_cast<IntegerAttr>(call.getArgOperands()[0]
                        .getDefiningOp<arith::ConstantOp>().getValue());
        if (!argC) continue;
        int64_t n = argC.getInt();
        if (n < 0) continue; // ignore negative
        Type resTy = call.getResult(0).getType();
        auto intTy = dyn_cast<IntegerType>(resTy);
        if (!intTy) continue;
        unsigned bw = intTy.getWidth();
        if (n >= static_cast<int64_t>(bw)) {
          // Be conservative: don't fold shifts >= bitwidth.
          continue;
        }
        llvm::APInt val(bw, 1);
        val = val.shl(n);
        OpBuilder rewriter(module.getContext());
        rewriter.setInsertionPoint(call);
        auto folded = rewriter.create<arith::ConstantIntOp>(call.getLoc(), val.getSExtValue(), bw);
        call.getResult(0).replaceAllUsesWith(folded.getResult());
        call.erase();
      }
    }
  }
};
} // namespace

} // namespace mlir

std::unique_ptr<mlir::Pass> mlir::createCalConstEvalPass() {
  return std::make_unique<mlir::CalConstEvalPass>();
}
