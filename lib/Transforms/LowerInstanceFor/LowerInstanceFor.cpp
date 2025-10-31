#include "Transforms/Passes.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Fifo/FifoOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/Pass/Pass.h"

using namespace mlir;
using namespace mlir::cal;

namespace {
struct LowerInstanceFor : public PassWrapper<LowerInstanceFor, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(LowerInstanceFor)
  StringRef getArgument() const final { return "lower-instance-for"; }
  StringRef getDescription() const final {
    return "Lower cal.instance_for with static bounds to tuple literals";
  }
  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<cal::CalDialect, arith::ArithDialect, fifo::FifoDialect>();
  }
  void runOnOperation() override {
    ModuleOp module = getOperation();
    IRRewriter rewriter(&getContext());
    SmallVector<Operation*> worklist;
    module.walk([&](Operation *op){
      if (isa<InstanceForOp>(op)) worklist.push_back(op);
    });

    for (Operation *op : worklist) {
      auto forOp = cast<InstanceForOp>(op);
      // Simple static check: require lb, ub, step to be arith.constant index.
      auto getConstIndex = [&](Value v, int64_t &out) -> bool {
        if (auto c = v.getDefiningOp<arith::ConstantIndexOp>()) { out = c.value(); return true; }
        if (auto c2 = v.getDefiningOp<arith::ConstantOp>()) {
          if (auto ia = dyn_cast<IntegerAttr>(c2.getValue())) { out = ia.getInt(); return true; }
        }
        return false;
      };
      int64_t lb, ub, step;
      if (!getConstIndex(forOp.getLb(), lb) || !getConstIndex(forOp.getUb(), ub) || !getConstIndex(forOp.getStep(), step) || step <= 0) {
        // Leave dynamic bounds untouched.
        continue;
      }
      // Compute trip count; handle zero-trip by producing an empty tuple.
      int64_t N = (ub - lb + step - 1) / step;
      rewriter.setInsertionPoint(forOp);

      SmallVector<Value> collected;
      collected.reserve(static_cast<size_t>(std::max<int64_t>(N, 0)));

      auto &region = forOp.getBody();
      if (region.empty() || region.getBlocks().size() != 1) {
        // Malformed: expect single-block region.
        // Leave as-is.
        continue;
      }
      Block &body = region.front();

      // For zero-trip, build an empty tuple result matching fifo.make_tuple semantics.
      if (N <= 0) {
        auto emptyTupleTy = TupleType::get(&getContext(), {});
  auto tupleOp = rewriter.create<fifo::MakeTuple>(forOp.getLoc(), emptyTupleTy, ValueRange{});
        forOp.getResult().replaceAllUsesWith(tupleOp.getResult());
        rewriter.eraseOp(forOp);
        continue;
      }

      // For each iteration, clone the body and capture the yielded value.
      for (int64_t iter = 0; iter < N; ++iter) {
        IRMapping map;
        // Map an optional induction variable if present.
        if (body.getNumArguments() == 1 && body.getArgument(0).getType().isIndex()) {
          int64_t ivVal = lb + iter * step;
          auto ivConst = rewriter.create<arith::ConstantIndexOp>(forOp.getLoc(), ivVal);
          map.map(body.getArgument(0), ivConst.getResult());
        }
        // Clone all but the terminator.
        for (Operation &inner : body.without_terminator()) {
          Operation *cloned = rewriter.clone(inner, map);
          // Map results for downstream clones within this iteration.
          for (auto [orig, neu] : llvm::zip(inner.getResults(), cloned->getResults()))
            map.map(orig, neu);
        }
        // Expect a cal.instance_yield terminator with one operand.
        Operation *term = body.getTerminator();
        if (auto y = dyn_cast<cal::InstanceYieldOp>(term)) {
          Value yielded = map.lookupOrNull(y.getValue());
          if (!yielded)
            yielded = y.getValue(); // Fallback if value defined outside body.
          collected.push_back(yielded);
        } else {
          // Malformed region; bail out and leave op unchanged.
          collected.clear();
          break;
        }
      }

      if (collected.empty() && N > 0)
        continue; // bail if malformed

      // Build the tuple result from collected values.
      SmallVector<Type> elemTypes;
      elemTypes.reserve(collected.size());
      for (Value v : collected)
        elemTypes.push_back(v.getType());
      auto tupleTy = TupleType::get(&getContext(), elemTypes);
  auto tupleOp = rewriter.create<fifo::MakeTuple>(forOp.getLoc(), tupleTy, ValueRange{collected});
      forOp.getResult().replaceAllUsesWith(tupleOp.getResult());
      rewriter.eraseOp(forOp);
    }
  }
};
} // namespace

std::unique_ptr<Pass> mlir::createLowerInstanceForPass() {
  return std::make_unique<LowerInstanceFor>();
}
