#include "mlir/Pass/Pass.h"
#include "Transforms/Passes.h"

//===- ResolveInstanceIf.cpp - Fold cal.instance_if ----------------------===//
//
// This pass resolves (constant-folds) cal.instance_if ops by replacing them
// with the yielded value from the selected region when the condition is a
// compile-time constant. It relies on the canonicalization patterns registered
// on the op, applying them greedily across the module.
//
//===----------------------------------------------------------------------===//

#include "Dialect/Cal/CalOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

using namespace mlir;
using namespace mlir::cal;

namespace mlir {
#define GEN_PASS_DEF_RESOLVEINSTANCEIFPASS
#include "Transforms/Passes.h.inc"

namespace {
struct ResolveInstanceIfPass : public impl::ResolveInstanceIfPassBase<ResolveInstanceIfPass> {
  void runOnOperation() override {
    Operation *op = getOperation();

    RewritePatternSet patterns(&getContext());
    // Pull in the canonicalization pattern(s) for cal.instance_if.
    cal::InstanceIfOp::getCanonicalizationPatterns(patterns, &getContext());

    GreedyRewriteConfig config;
    config.maxIterations = GreedyRewriteConfig::kNoLimit;
    config.useTopDownTraversal = true;
    if (failed(applyPatternsAndFoldGreedily(op, std::move(patterns), config))) {
      signalPassFailure();
      return;
    }
  }
};
} // namespace

} // namespace mlir

std::unique_ptr<mlir::Pass> mlir::createResolveInstanceIfPass() {
  return std::make_unique<mlir::ResolveInstanceIfPass>();
}
