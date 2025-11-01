#include "mlir/Pass/Pass.h"
// Dependent dialects referenced in the generated registration for this pass.
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "Dialect/Cal/CalOps.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PatternMatch.h"
#include "Transforms/Passes.h"

//===- ElaborateScfStructures.cpp - Elaborate scf.if/for for CAL -------===//
// Skeleton pass for elaborating structural scf.if/scf.for when predicates and
// trip counts are constant, cloning CAL structural ops into the parent network.
// Currently a no-op placeholder to anchor the pass pipeline.
//===----------------------------------------------------------------------===//

using namespace mlir;

namespace mlir {
#define GEN_PASS_DEF_ELABORATESCFSTRUCTURESPASS
#include "Transforms/Passes.h.inc"

namespace {
struct ElaborateScfStructuresPass : public impl::ElaborateScfStructuresPassBase<ElaborateScfStructuresPass> {
  void runOnOperation() override {
    ModuleOp module = getOperation();

    auto hasNetworkAncestor = [](Operation *op) {
      Operation *cur = op->getParentOp();
      while (cur) {
        if (isa<cal::NetworkOp>(cur)) return true;
        cur = cur->getParentOp();
      }
      return false;
    };

    // 1) Fold constant scf.if (no-result only) by inlining the taken branch.
    SmallVector<scf::IfOp, 16> ifsToProcess;
    module.walk([&](scf::IfOp ifOp){ ifsToProcess.push_back(ifOp); });
    for (scf::IfOp ifOp : ifsToProcess) {
      if (ifOp.getNumResults() != 0)
        continue; // Only handle structural, no-result conditionals.
      if (!hasNetworkAncestor(ifOp))
        continue;
      auto cst = ifOp.getCondition().getDefiningOp<arith::ConstantOp>();
      if (!cst)
        continue;
      auto boolAttr = dyn_cast_or_null<BoolAttr>(cst.getValue());
      if (!boolAttr)
        continue;

      IRRewriter rewriter(&getContext());
      rewriter.setInsertionPoint(ifOp);
      Region &chosen = boolAttr.getValue() ? ifOp.getThenRegion() : ifOp.getElseRegion();
      // Inline all ops from the chosen region's single block (if present).
      if (!chosen.empty()) {
        Block &blk = chosen.front();
        for (Operation &inner : llvm::make_early_inc_range(blk)) {
          if (isa<scf::YieldOp>(&inner))
            continue;
          rewriter.clone(inner);
        }
      }
      rewriter.eraseOp(ifOp);
    }

    // 2) Fully unroll small static scf.for (no-iter-args, no-results) by cloning body.
    SmallVector<scf::ForOp, 16> forsToProcess;
    module.walk([&](scf::ForOp forOp){ forsToProcess.push_back(forOp); });
    for (scf::ForOp forOp : forsToProcess) {
      if (forOp.getNumResults() != 0 || forOp.getInitArgs().size() != 0)
        continue; // Only structural loops without carried args/results.
      if (!hasNetworkAncestor(forOp))
        continue;

      auto lbC = forOp.getLowerBound().getDefiningOp<arith::ConstantOp>();
      auto ubC = forOp.getUpperBound().getDefiningOp<arith::ConstantOp>();
      auto stC = forOp.getStep().getDefiningOp<arith::ConstantOp>();
      if (!lbC || !ubC || !stC)
        continue;
      auto lbIdx = dyn_cast_or_null<IntegerAttr>(lbC.getValue());
      auto ubIdx = dyn_cast_or_null<IntegerAttr>(ubC.getValue());
      auto stIdx = dyn_cast_or_null<IntegerAttr>(stC.getValue());
      if (!lbIdx || !ubIdx || !stIdx)
        continue;
      int64_t lb = lbIdx.getInt();
      int64_t ub = ubIdx.getInt();
      int64_t st = stIdx.getInt();
      if (st <= 0)
        continue;
      int64_t tripCount = (ub <= lb) ? 0 : ((ub - lb + st - 1) / st);
      if (tripCount < 0 || tripCount > 8)
        continue; // Be conservative for now.

      IRRewriter rewriter(&getContext());
      rewriter.setInsertionPoint(forOp);
      // Clone body tripCount times, ignoring the induction variable for now.
      if (!forOp.getBody()->empty()) {
        Block &body = *forOp.getBody();
        for (int64_t i = 0; i < tripCount; ++i) {
          for (Operation &inner : llvm::make_early_inc_range(body)) {
            if (isa<scf::YieldOp>(&inner))
              continue;
            rewriter.clone(inner);
          }
        }
      }
      rewriter.eraseOp(forOp);
    }
  }
};
} // namespace

} // namespace mlir

std::unique_ptr<mlir::Pass> mlir::createElaborateScfStructuresPass() {
  return std::make_unique<mlir::ElaborateScfStructuresPass>();
}
