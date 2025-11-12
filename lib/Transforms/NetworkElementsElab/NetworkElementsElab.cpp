#include "mlir/Pass/Pass.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

#include "Dialect/Cal/CalOps.h"
#include "Transforms/Passes.h"

using namespace mlir;

namespace {
// Fold scf.if with constant condition when it has no results by inlining the
// taken branch and erasing the if. This is a conservative building block for
// structuralization; we avoid handling result values here to keep the logic
// simple and non-invasive.
struct FoldConstIfNoResult : OpRewritePattern<scf::IfOp> {
  using OpRewritePattern<scf::IfOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(scf::IfOp ifOp,
                                PatternRewriter &rewriter) const override {
    if (ifOp->getNumResults() != 0)
      return failure();
    auto cst = ifOp.getCondition().getDefiningOp<arith::ConstantOp>();
    if (!cst)
      return failure();
    auto boolAttr = dyn_cast_or_null<BoolAttr>(cst.getValue());
    if (!boolAttr)
      return failure();

    bool takeThen = boolAttr.getValue();
    // Inline selected branch operations before the if.
    rewriter.setInsertionPoint(ifOp);
    Region &reg = takeThen ? ifOp.getThenRegion() : ifOp.getElseRegion();
    // If the region is empty (possible for else), just erase the if.
    if (reg.empty()) {
      rewriter.eraseOp(ifOp);
      return success();
    }
    Block &blk = reg.front();
    for (Operation &op : llvm::make_early_inc_range(blk)) {
      if (isa<scf::YieldOp>(&op))
        continue;
      rewriter.clone(op);
    }
    rewriter.eraseOp(ifOp);
    return success();
  }
};

class NetworkElementsElabPass
    : public PassWrapper<NetworkElementsElabPass, OperationPass<ModuleOp>> {
public:
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(NetworkElementsElabPass)
  StringRef getArgument() const final { return "network-elements-elab"; }
  StringRef getDescription() const final {
    return "Elaborate entity/array elements (structural) without flattening";
  }
  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<arith::ArithDialect, scf::SCFDialect, cal::CalDialect>();
  }
  void runOnOperation() override {
    ModuleOp module = getOperation();
    RewritePatternSet patterns(&getContext());
    patterns.add<FoldConstIfNoResult>(&getContext());
    (void)applyPatternsGreedily(module, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<mlir::Pass> mlir::createNetworkElementsElabPass() {
  return std::make_unique<NetworkElementsElabPass>();
}
