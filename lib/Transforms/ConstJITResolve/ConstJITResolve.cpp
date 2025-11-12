#include "Transforms/Passes.h"
#include "Dialect/Cal/CalDialect.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/UB/IR/UBOps.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/Passes.h"

namespace mlir {

namespace {
/// Thin wrapper pass while we extract a dedicated always-JIT constant resolver.
/// For now, delegate to CalConstEval with default options and follow with a
/// canonicalizer to propagate constants.
struct ConstJITResolvePass
    : public PassWrapper<ConstJITResolvePass, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(ConstJITResolvePass)

  StringRef getArgument() const final { return "const-jit-resolve"; }
  StringRef getDescription() const final {
    return "Resolve pure helpers via JIT and fold constants (wrapper).";
  }

  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<arith::ArithDialect, func::FuncDialect, scf::SCFDialect,
                    cal::CalDialect, ub::UBDialect>();
  }

  void runOnOperation() override {
    ModuleOp module = getOperation();
  // Build a small inner pass manager and parse a textual pipeline that
  // forces JIT-only const eval while disabling inliner, network inlining,
  // and pruning.
    PassManager pm(module.getContext());
    std::string pipeline =
    "cal-const-eval{enable-jit-const-eval=true enable-global-inliner=false "
        "enable-network-inline=false prune-unused=false},canonicalize";
    if (failed(parsePassPipeline(pipeline, pm))) {
      module.emitError("Failed to parse ConstJITResolve inner pipeline");
      signalPassFailure();
      return;
    }
    if (failed(pm.run(module)))
      signalPassFailure();
  }
};
} // end anonymous namespace

std::unique_ptr<Pass> createConstJITResolvePass() {
  return std::make_unique<ConstJITResolvePass>();
}

} // namespace mlir
