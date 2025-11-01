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
  }
};
} // namespace

} // namespace mlir

std::unique_ptr<mlir::Pass> mlir::createCalConstEvalPass() {
  return std::make_unique<mlir::CalConstEvalPass>();
}
