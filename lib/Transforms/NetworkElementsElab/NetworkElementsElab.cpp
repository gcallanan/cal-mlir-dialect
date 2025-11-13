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

// Evaluate an SSA value to a constant 64-bit integer if it originates from a
// supported constant operation. Returns std::nullopt otherwise.
static std::optional<int64_t> evalConstIndex(Value v) {
  if (auto cst = v.getDefiningOp<arith::ConstantOp>()) {
    if (auto intAttr = dyn_cast<IntegerAttr>(cst.getValue()))
      return intAttr.getValue().getSExtValue();
  }
  if (auto cIdx = v.getDefiningOp<arith::ConstantIndexOp>())
    return cIdx.value();
  if (auto cInt = v.getDefiningOp<arith::ConstantIntOp>())
    return cInt.value();
  return std::nullopt;
}

// Unroll simple static-bound array-builder loops while preserving structural
// ops like cal.instance.array.set and any inner control flow.
// Constraints:
//  - One iter arg and one result, both the same cal.instance.array type.
//  - Loop bounds lb, ub, step are all constant and yield a modest trip count.
//  - Body contains exactly one cal.instance.array.set writing to the iter arg
//    at the loop IV index, and scf.yield returns that set result.
struct ForUnrollArrayBuilder : OpRewritePattern<scf::ForOp> {
  using OpRewritePattern<scf::ForOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(scf::ForOp forOp,
                                PatternRewriter &rewriter) const override {
    // Arity checks.
    if (forOp.getNumResults() != 1 || forOp.getInitArgs().size() != 1)
      return failure();

    // Result must be an instance array type.
    auto arrTy = dyn_cast<cal::InstanceArrayType>(forOp.getResult(0).getType());
    if (!arrTy)
      return failure();

    // Constant bounds.
    auto lbOpt = evalConstIndex(forOp.getLowerBound());
    auto ubOpt = evalConstIndex(forOp.getUpperBound());
    auto stOpt = evalConstIndex(forOp.getStep());
    if (!lbOpt || !ubOpt || !stOpt)
      return failure();
    int64_t lb = *lbOpt, ub = *ubOpt, st = *stOpt;
    if (st <= 0)
      return failure();
    int64_t tripCount = (ub - lb + st - 1) / st; // ceilDiv
    if (tripCount <= 0 || tripCount > 1024)
      return failure(); // keep it conservative

    // Ensure there is at least one array.set writing using IV, and that yield
    // returns the last set's result. Also validate sets form a chain starting
    // from the iter arg.
    SmallVector<cal::InstanceArraySetOp, 4> setOps;
    for (Operation &op : *forOp.getBody()) {
      if (auto s = dyn_cast<cal::InstanceArraySetOp>(&op))
        setOps.push_back(s);
    }
    if (setOps.empty())
      return failure();
    Value expectedArray = forOp.getRegionIterArg(0);
    for (cal::InstanceArraySetOp s : setOps) {
      if (s.getArray() != expectedArray)
        return failure();
      unsigned ivCount = 0;
      for (Value idx : s.getIndices())
        if (idx == forOp.getInductionVar())
          ++ivCount;
      if (ivCount != 1)
        return failure();
      expectedArray = s.getResult();
    }
    auto yieldOp = cast<scf::YieldOp>(forOp.getBody()->getTerminator());
    if (yieldOp.getResults().size() != 1 || yieldOp.getResults()[0] != setOps.back().getResult())
      return failure();

    // Start from the init arg; we intentionally keep the original array type
    // to avoid retyping cloned ops. The init value may come from an init op
    // or a previous loop; both are supported.
    Value running = forOp.getInitArgs()[0];

    rewriter.setInsertionPoint(forOp);
    // Clone the body tripCount times, mapping IV and iter arg each time.
    for (int64_t iter = 0; iter < tripCount; ++iter) {
      IRMapping map;
      auto iv = rewriter.create<arith::ConstantIndexOp>(forOp.getLoc(), lb + iter * st);
      map.map(forOp.getInductionVar(), iv);
      map.map(forOp.getRegionIterArg(0), running);

      Value producedArray = nullptr;
      for (Operation &op : forOp.getBody()->without_terminator()) {
        Operation *cloned = rewriter.clone(op, map);
        for (auto [orig, neu] : llvm::zip(op.getResults(), cloned->getResults()))
          map.map(orig, neu);
        if (auto as = dyn_cast<cal::InstanceArraySetOp>(cloned))
          producedArray = as.getResult();
      }
      if (!producedArray)
        return failure();
      running = producedArray;
    }

    rewriter.replaceOp(forOp, running);
    return success();
  }
};
//};

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
    // Temporarily disable FoldConstIfNoResult due to eraseOp assertion when nested uses remain.
    // patterns.add<FoldConstIfNoResult>(&getContext());
    patterns.add<ForUnrollArrayBuilder>(&getContext());
    (void)applyPatternsGreedily(module, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<mlir::Pass> mlir::createNetworkElementsElabPass() {
  return std::make_unique<NetworkElementsElabPass>();
}
