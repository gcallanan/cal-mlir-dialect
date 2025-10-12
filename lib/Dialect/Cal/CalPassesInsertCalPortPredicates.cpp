#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalPasses.h"
#include "Dialect/Cal/CalTypes.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Pass/AnalysisManager.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

namespace mlir::cal {
#define GEN_PASS_DEF_INSERTCALPORTPREDICATES
#include "Dialect/Cal/CalPasses.h.inc"

// ActionInfo stores per-port token flow information for a single cal.action.
//
// - `consumptionRates` maps each output port (from which the action pops
// tokens)
//   to the number of tokens consumed from that port.
//
// - `productionRates` maps each input port (to which the action pushes tokens)
//   to the number of tokens produced to that port.
//
// This struct is populated by RateAnalysis and used to guide transformations
// that depend on the token flow behavior of actions.
struct ActionInfo {
  llvm::DenseMap<mlir::Value, int> consumptionRates;
  llvm::DenseMap<mlir::Value, int> productionRates;
};

// RateAnalysis is a simple analysis used to determine the token production
// and consumption rates of each cal.action operation within cal.actor
// operations.
//
// It traverses the IR to find fifo.pop and fifo.push operations inside each
// cal.action, and counts how many tokens each action consumes (from output
// ports) and produces (to input ports). The results are stored in a map from
// ActionOp to ActionInfo, which tracks port-wise rates.
//
// This analysis is used by transformation passes that need to reason about the
// token flow behavior of actions, such as inserting predicate checks based on
// port availability.
struct RateAnalysis {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(RateAnalysis)

  llvm::DenseMap<mlir::Operation *, ActionInfo> actionMap;

  RateAnalysis(Operation *op) {
    op->walk([&](mlir::cal::ActorOp actorOp) {
      actorOp->walk([&](mlir::cal::ActionOp actionOp) {
        ActionInfo info;

        // Helper to compute the multiplicative factor contributed by any
        // surrounding statically-bounded scf.for or affine.for loops. If bounds are not
        // compile-time constants, we conservatively return 1.
        auto getStaticLoopMultiplier = [&](Operation *innerOp) -> int64_t {
          int64_t multiplier = 1;
          Operation *parent = innerOp->getParentOp();
          while (parent && parent != actionOp.getOperation()) {
            if (auto forOp = llvm::dyn_cast<mlir::scf::ForOp>(parent)) {
              auto getConstIndex = [](Value v) -> std::optional<int64_t> {
                if (auto cst = v.getDefiningOp<mlir::arith::ConstantOp>()) {
                  if (cst.getType().isIndex()) {
                    if (auto ia = llvm::dyn_cast<IntegerAttr>(cst.getValue()))
                      return ia.getInt();
                  }
                }
                return std::nullopt;
              };

              auto lb = getConstIndex(forOp.getLowerBound());
              auto ub = getConstIndex(forOp.getUpperBound());
              auto step = getConstIndex(forOp.getStep());
              if (lb && ub && step && *step > 0) {
                int64_t span = *ub - *lb;
                if (span <= 0) {
                  // No iterations
                  // multiplier *= 0; but zero would zero-out rates and could
                  // disable predicates entirely. Use 0 to be exact here.
                  // However, actions with zero-trip loops will be dead anyway.
                  // Keep multiplier unchanged (1) to avoid surprising zeros.
                } else {
                  int64_t iters = (span + (*step - 1)) / *step; // ceilDiv
                  // Avoid overflow of int by clamping to INT_MAX if necessary.
                  if (iters > 0) {
                    // Best-effort overflow-safe multiply.
                    if (multiplier > 0 && iters > (std::numeric_limits<int64_t>::max() / multiplier))
                      multiplier = std::numeric_limits<int64_t>::max();
                    else
                      multiplier *= iters;
                  }
                }
              }
            } else if (auto affineForOp = llvm::dyn_cast<mlir::affine::AffineForOp>(parent)) {
              // Handle affine.for loops with constant bounds
              if (affineForOp.hasConstantBounds()) {
                int64_t lb = affineForOp.getConstantLowerBound();
                int64_t ub = affineForOp.getConstantUpperBound();
                int64_t step = affineForOp.getStep().getSExtValue();
                
                if (step > 0) {
                  int64_t span = ub - lb;
                  if (span <= 0) {
                    // No iterations - keep multiplier unchanged (1) to avoid surprising zeros
                  } else {
                    int64_t iters = (span + (step - 1)) / step; // ceilDiv
                    // Avoid overflow of int by clamping to INT_MAX if necessary.
                    if (iters > 0) {
                      // Best-effort overflow-safe multiply.
                      if (multiplier > 0 && iters > (std::numeric_limits<int64_t>::max() / multiplier))
                        multiplier = std::numeric_limits<int64_t>::max();
                      else
                        multiplier *= iters;
                    }
                  }
                }
              }
              // If bounds are not constant, we conservatively keep multiplier as-is
            }
            parent = parent->getParentOp();
          }
          return multiplier;
        };

        actionOp->walk([&](Operation *opsInAction) {
          if (llvm::isa<fifo::Pop>(opsInAction) ||
              llvm::isa<fifo::Push>(opsInAction)) {
            int64_t loopMult = getStaticLoopMultiplier(opsInAction);
            if (loopMult < 1)
              loopMult = 1; // Fallback safety
            if (fifo::Pop popOp = llvm::dyn_cast<fifo::Pop>(opsInAction)) {
              // Multiply by the number of static loop iterations surrounding
              // this pop to reflect per-fire consumption accurately.
              info.consumptionRates[popOp.getOutputPort()] += static_cast<int>(loopMult);

            } else if (auto pushOp = llvm::dyn_cast<fifo::Push>(opsInAction)) {
              info.productionRates[pushOp.getInputPort()] += static_cast<int>(loopMult);
            }
          }
        });

        actionMap[actionOp] = std::move(info);
      });
    });
  }

  // Returns the ActionInfo for a given cal.action operation.
  const ActionInfo &lookup(mlir::Operation *op) { return actionMap[op]; }
};

// This transformation inserts a `cal.predicate` operation for each FIFO port
// accessed by a `cal.action`. The predicates ensure that runtime conditions
// (such as token availability or buffer space) are checked before the action
// executes.
//
// Input: A `cal.action` that performs FIFO operations like `fifo.pop` and
// `fifo.push`, consuming from or producing to FIFO ports. These ports require
// runtime guards (predicates) to prevent underflow or overflow.
//
// Output: A transformed `cal.action` where each accessed port is guarded by a
// `cal.predicate`. These predicates are inserted at the beginning of the action
// body and evaluate whether the necessary conditions (sufficient tokens for
// pops or available space for pushes) are satisfied.
//
// For each port:
//   - For input (consumption): use `fifo.size` to check token availability
//   - For output (production): use `fifo.space` to check buffer space
//   - The result is compared against the expected rate using `arith.cmpi`
//   - The final result is returned via `cal.predicate_result`
//
// Example Input:
//   cal.action {
//     %token = fifo.pop(%in1: !fifo.output_port<i32>) : i32
//     fifo.push(%out0: !fifo.input_port<i32>, %token: i32)
//   }
//
// Example Output:
//   cal.action {
//     cal.predicate {
//       %1 = fifo.size(%arg1 : !fifo.output_port<i32>) : index
//       %2 = arith.index_cast %1 : index to i32
//       %3 = arith.cmpi sge, %2, %c1_i32 : i32
//       cal.predicate_result %3 : i1
//     } {inserted_by_pass}
//     cal.predicate {
//       %1 = fifo.space(%arg2 : !fifo.input_port<i32>) : index
//       %2 = arith.index_cast %1 : index to i32
//       %3 = arith.cmpi sge, %2, %c1_i32 : i32
//       cal.predicate_result %3 : i1
//     } {inserted_by_pass}
//     %0 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
//     fifo.push(%arg2 : !fifo.input_port<i32>, %0 : i32)
//   }
//
// This pass avoids inserting duplicate predicates by checking whether they were
// already inserted (marked via the `inserted_by_pass` attribute). If all
// necessary predicates already exist, the pattern is skipped.
struct InsertPredicateInActionOps : public OpRewritePattern<cal::ActionOp> {
  InsertPredicateInActionOps(MLIRContext *ctx, RateAnalysis &rateAnalysis)
      : OpRewritePattern<cal::ActionOp>(ctx), rateAnalysis(rateAnalysis) {}

  LogicalResult matchAndRewrite(cal::ActionOp action,
                                PatternRewriter &rewriter) const override {

    // 1. Check if the predicates have already been inserted

    // 1.1 Count the number of predicates that have been inserted
    int modifiedCount = 0;
    action->walk([&](cal::Predicate predOp) {
      if (predOp->hasAttr("inserted_by_pass")) {
        ++modifiedCount;
      }
    });

    // 1.2 Look up the number of ports that the action produces/consumes
    // tokens from/to. Each of these will require a predicate.
    const auto &info = rateAnalysis.lookup(action.getOperation());
    int numConsumptionPorts = info.consumptionRates.size();
    int numProductionPorts = info.productionRates.size();
    int totalPorts = numConsumptionPorts + numProductionPorts;

    // 1.3 If the number of predicates already inserted is equal to the number
    // of ports, then we can skip inserting new predicates.
    if (modifiedCount >= totalPorts) {
      return failure();
    }

    // 2. Insert predicates for each port that the action produces/consumes
    auto loc = action.getLoc();
    for (const auto &entry : info.productionRates) {
      insertPredicate(action, rewriter, loc, entry.first, entry.second,
                      /*isProduction=*/true);
    }

    for (const auto &entry : info.consumptionRates) {
      insertPredicate(action, rewriter, loc, entry.first, entry.second,
                      /*isProduction=*/false);
    }

    // 3. Return success.
    return success();
  }

private:
  RateAnalysis &rateAnalysis;

  /// Inserts a `cal::Predicate` operation into the beginning of the given
  /// `cal::ActionOp`'s body. The predicate checks whether there are enough
  /// tokens available on a port (for consumption) or enough space available
  /// (for production), based on the provided `rate`.
  ///
  /// The inserted predicate consists of:
  /// - A comparison between the available tokens/space and the required rate
  /// - A `cal::PredicateResultOp` that yields the result of this comparison
  /// - An `inserted_by_pass` unit attribute to mark it as added by the pass
  ///
  /// @param action The ActionOp being modified.
  /// @param rewriter The PatternRewriter used to insert new operations.
  /// @param loc The location to associate with the new operations.
  /// @param port The FIFO port being analyzed (input or output).
  /// @param rate The required number of tokens or space units.
  /// @param isProduction True if the port is an output (production),
  ///                     false if it's an input (consumption).
  void insertPredicate(cal::ActionOp action, PatternRewriter &rewriter,
                       Location loc, Value port, int rate,
                       bool isProduction) const {
    auto &body = action.getBody();
    rewriter.setInsertionPointToStart(&body.front());

    auto predicate = rewriter.create<cal::Predicate>(loc);
    predicate->setAttr("inserted_by_pass", rewriter.getUnitAttr());

    auto &region = predicate->getRegion(0);
    auto *block = new Block();
    region.push_back(block);
    rewriter.setInsertionPointToStart(block);

    auto requiredTokens = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getI32IntegerAttr(rate));

    // Depending on whether this is a production or consumption port, we
    // create either a fifo.space or fifo.size operation to check the
    // availability of tokens or space.
    Operation *countOp;
    if (isProduction) {
      countOp =
          rewriter.create<fifo::SpaceOp>(loc, rewriter.getIndexType(), port);
    } else {
      countOp =
          rewriter.create<fifo::SizeOp>(loc, rewriter.getIndexType(), port);
    }

    Value tokenCount = rewriter.create<arith::IndexCastOp>(
        loc, rewriter.getI32Type(), countOp->getResult(0));

    auto cmp = rewriter.create<arith::CmpIOp>(loc, arith::CmpIPredicate::sge,
                                              tokenCount, requiredTokens);

    rewriter.create<cal::PredicateResultOp>(loc, cmp.getResult());
  }
};

// A transformation pass that inserts predicate checks for FIFO ports in
// cal.action ops based on rate analysis.
class InsertCalPortPredicatesPass
    : public impl::InsertCalPortPredicatesBase<InsertCalPortPredicatesPass> {
public:
  void runOnOperation() final {
    auto &rateAnalysis = getAnalysis<RateAnalysis>();

    RewritePatternSet patterns(&getContext());

    patterns.add<InsertPredicateInActionOps>(&getContext(), rateAnalysis);

    if (failed(applyPatternsGreedily(getOperation(), std::move(patterns)))) {
      signalPassFailure();
    }
  }
};

} // namespace mlir::cal

// Creates and returns an instance of the InsertCalPortPredicates pass.
std::unique_ptr<mlir::Pass> mlir::cal::insertCalPortPredicates() {
  return std::make_unique<mlir::cal::InsertCalPortPredicatesPass>();
}