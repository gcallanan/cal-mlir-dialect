#include <memory>
#include <utility>

#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalPasses.h"
#include "Dialect/Cal/CalTypes.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/Operation.h"
#include "mlir/IR/Types.h"
#include "mlir/IR/Value.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "llvm/ADT/TypeSwitch.h"

namespace mlir {
namespace cal {
#define GEN_PASS_DEF_CONVERTCALACTIONSTOEXECUTIONBODIES
#include "Dialect/Cal/CalPasses.h.inc"

/**
 * @brief Caches and reuses equivalent predicate-related operations in CAL and
 * FIFO dialects.
 *
 * This utility class tracks specific operation types—`cal::StateGetOp`,
 * `fifo::SpaceOp`, and `fifo::SizeOp`—and ensures that only one instance of
 * each semantically equivalent operation is emitted. It maintains small vectors
 * of previously seen ops, and when a new operation is encountered, it checks if
 * an equivalent one already exists:
 *
 * - If a match is found (based on operand equality), the cached result `Value`
 * is returned.
 * - If no match is found, the operation is stored for future comparisons, and
 * an empty `mlir::Value` is returned.
 *
 * This enables canonicalization and reuse of results, reducing redundant
 * computation and simplifying downstream IR.
 *
 * @note The caller is responsible for replacing the new operation with the
 * cached result and erasing the duplicate if needed.
 */
class StateAndFifoPredicateOpCache {
public:
  mlir::Value cacheOrFind(mlir::Operation *op) {
    return llvm::TypeSwitch<mlir::Operation *, mlir::Value>(op)
        .Case<cal::StateGetOp>(
            [&](cal::StateGetOp getOp) { return cacheOrFind(getOp); })
        .Case<fifo::SpaceOp>(
            [&](fifo::SpaceOp spaceOp) { return cacheOrFind(spaceOp); })
        .Case<fifo::SizeOp>(
            [&](fifo::SizeOp sizeOp) { return cacheOrFind(sizeOp); })
        .Default([](mlir::Operation *) {
          return mlir::Value(); // Return null value if not matched
        });
  }

  mlir::Value cacheOrFind(cal::StateGetOp op) {
    for (auto cached : cachedGetOps) {
      if (cached.getStateRef() == op.getStateRef()) {
        // llvm::outs() << "StateGetOp in cache!\n";
        return cached.getResult();
      }
    }
    // llvm::outs() << "StateGetOp not in cache!\n";
    cachedGetOps.push_back(op);
    return mlir::Value(); // Return null if not found
  }

  mlir::Value cacheOrFind(fifo::SpaceOp op) {
    for (auto cached : cachedSpaceOps) {
      if (cached.getInputPort() == op.getInputPort()) {
        // llvm::outs() << "SpaceOp in cache!\n";
        return cached.getResult();
      }
    }
    // llvm::outs() << "SpaceOp not in cache!\n";
    cachedSpaceOps.push_back(op);
    return mlir::Value(); // Return null if not found
  }

  mlir::Value cacheOrFind(fifo::SizeOp op) {
    for (auto cached : cachedSizeOps) {
      if (cached.getOutputPort() == op.getOutputPort()) {
        // llvm::outs() << "SpaceOp in cache!\n";
        return cached.getResult();
      }
    }
    // llvm::outs() << "SpaceOp not in cache!\n";
    cachedSizeOps.push_back(op);
    return mlir::Value(); // Return null if not found
  }

private:
  llvm::SmallVector<cal::StateGetOp, 4> cachedGetOps;
  llvm::SmallVector<fifo::SpaceOp, 4> cachedSpaceOps;
  llvm::SmallVector<fifo::SizeOp, 4> cachedSizeOps;
};

// This transformation rewrites each `cal.actor` by lowering its `cal.action`
// operations into a single `cal.execution_body` region. Each action's execution
// is conditionally guarded by an SCF `if` operation, based on the evaluation
// of its associated predicates.
//
// Input: A `cal.actor` containing one or more `cal.action` operations. Each
// action may include one or more `cal.predicate` operations that determine
// whether the action should execute based on runtime conditions (e.g. FIFO
// readiness).
//
// Output: The `cal.actor` has a `cal.execution_body` that replaces the original
// actions. All predicate operations are moved into the execution body, and
// each action is wrapped in an `scf.if` block. These blocks are nested in
// priority order, so that only the highest-priority enabled action executes.
// The final result of the nested conditionals is passed to `cal.action_done`,
// indicating whether any action was executed.
//
// Transformation Details:
//   1. Collect all `cal.action` operations from the actor.
//   2. Create a new `cal.execution_body` at the end of the actor.
//   3. Sort actions by `priority` attribute (higher priority first).
//   4. Wrap each action body in a nested `scf.if` region controlled by its
//      predicate condition. Only the first true condition will result in
//      action execution, yielding `true`; all others fall through.
//   6. Yield the result of the conditional chain to `cal.action_done`.
//   7. Erase the original `cal.action` operations.
//
// Example Input:
//   cal.actor @sink() {
//     cal.action {
//       cal.predicate {
//         %1 = fifo.size(%arg0) : index
//         %2 = arith.index_cast %1 : i32
//         %3 = arith.cmpi sge, %2, %c1_i32 : i32
//         cal.predicate_result %3 : i1
//       }
//       %0 = fifo.pop(%arg0)
//       fifo.print("token = %d", %0)
//     }
//   }
//
// Example Output:
//   cal.actor @sink() {
//     cal.execution_body {
//       %0 = fifo.size(%arg0) : index
//       %1 = arith.index_cast %0 : i32
//       %2 = arith.cmpi sge, %1, %c1_i32 : i32
//       %3 = scf.if %2 -> (i1) {
//         %4 = fifo.pop(%arg0)
//         fifo.print("token = %d", %4)
//         scf.yield %true : i1
//       } else {
//         scf.yield %false : i1
//       }
//       cal.action_done %3 : i1
//     }
//   }
struct ActionToExecBodyPattern : public OpRewritePattern<cal::ActorOp> {
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(cal::ActorOp actor,
                                PatternRewriter &rewriter) const override {

    // 1. Collect all action operations, if none exist we terminate
    llvm::SmallVector<cal::ActionOp> actionOps;
    actor->walk([&](cal::ActionOp actionOp) {
      if (!actionOp.getRegion().empty() &&
          !actionOp.getRegion().front().empty()) {
        actionOps.push_back(actionOp);
      }else{
        rewriter.eraseOp(actionOp); // Remove empty actions
      }
    });

    if (actionOps.empty()) {
      return failure(); // No actions to convert
    }

    // 2.  Create a new execution body operation
    rewriter.setInsertionPointToEnd(&actor.getBody().back());
    auto execBodyOp = rewriter.create<cal::ExecutionBody>(actor.getLoc());
    auto *execBlock = new mlir::Block();
    execBodyOp.getBody().push_back(execBlock);

    // 3. Move all action bodies to the execution body. Only one action may
    // fire per execution body invocation, so we will nest these actions in
    // SCF if statements. (These nestings are ordered by the action priority)
    // Within each nest we will check, the predicate conditions to see if an
    // actor can fire.

    // 3.1 Sort actions by priority
    std::sort(actionOps.begin(), actionOps.end(),
              [](const cal::ActionOp &a, const cal::ActionOp &b) {
                auto aAttr = a->getAttrOfType<mlir::IntegerAttr>("priority");
                auto bAttr = b->getAttrOfType<mlir::IntegerAttr>("priority");
                int64_t aPriority = aAttr ? aAttr.getInt() : 0;
                int64_t bPriority = bAttr ? bAttr.getInt() : 0;
                return aPriority > bPriority; // Descending order
              });

    rewriter.setInsertionPointToStart(execBlock);

    // 3.2 Construct nested SCF if statements for each action
    StateAndFifoPredicateOpCache cache;
    Value result = constructNestedSCFIfStatements(0, actionOps, rewriter,
                                                  execBodyOp.getLoc(), cache);

    // 4. After all actions have been processed, we need to yield the result of
    // the last action's firing condition. This will be used to determine if
    // the actor performed any action during this execution.
    rewriter.setInsertionPointToEnd(execBlock);
    rewriter.create<cal::ActionDoneOp>(actor.getLoc(), result);

    // 5. Finally, we need to erase the original action operations, as they have
    // been moved to the execution body and are no longer needed.
    for (auto actionOp : actionOps) {
      rewriter.eraseOp(actionOp);
    }

    return success();
  }

  /**
   * @brief Moves predicate operations from a CAL action into an execution block
   * and combines their results into a single boolean condition.
   *
   * This function processes all `cal::Predicate` regions associated with the
   * given `cal::ActionOp`. It moves each predicate's internal operations
   * (except for `cal::PredicateResultOp`) into the specified execution block.
   * The results of all `PredicateResultOp`s are collected and combined using a
   * chain of `arith::AndIOp`, starting from a constant `true` value.
   *
   * After relocation, the original predicate operations and result ops are
   * erased. The final combined predicate value represents the overall firing
   * condition for the action.
   *
   * @param actionOp The `cal::ActionOp` whose predicates are being processed.
   * @param execBlock The block into which predicate operations are moved.
   * @param rewriter The `PatternRewriter` used to manipulate the IR.
   *
   * @return A `Value` representing the logical AND of all predicate results.
   */
  Value managePredicateConditions(mlir::cal::ActionOp actionOp,
                                  mlir::Block *execBlock,
                                  mlir::PatternRewriter &rewriter,
                                  StateAndFifoPredicateOpCache &cache) const {

    llvm::SmallVector<mlir::Value, 4> predicateResults;

    rewriter.setInsertionPointToEnd(execBlock);

    // Collect and move all predicate operations into execBlock
    llvm::SmallVector<mlir::Operation *> opsToErase;
    actionOp->walk([&](mlir::cal::Predicate predicate) {
      auto &region = predicate.getRegion();
      if (region.empty())
        return;

      auto &block = region.front();
      while (!block.empty()) {
        auto *op = &block.front();
        if (auto resultOp = llvm::dyn_cast<mlir::cal::PredicateResultOp>(op)) {
          predicateResults.push_back(resultOp.getEvaluationResult());
          rewriter.eraseOp(op);
        } else {
          if (mlir::Value cached = cache.cacheOrFind(op)) {
            op->getResult(0).replaceAllUsesWith(cached);
            rewriter.eraseOp(op);
          } else {
            op->moveBefore(execBlock, execBlock->end());
          }
        }
      }
      opsToErase.push_back(predicate);
    });

    // Erase old predicate operations
    for (auto *op : opsToErase)
      rewriter.eraseOp(op);

    // Combine predicate results using a chain of AndIOps
    auto trueVal = rewriter.create<mlir::arith::ConstantOp>(
        actionOp.getLoc(), rewriter.getI1Type(), rewriter.getBoolAttr(true));
    mlir::Value combinedResult = trueVal;
    for (auto predResult : predicateResults) {
      combinedResult = rewriter
                           .create<mlir::arith::AndIOp>(
                               actionOp.getLoc(), predResult, combinedResult)
                           .getResult();
    }

    // Store final condition associated with the action
    return combinedResult;
  }

  /**
   * @brief Moves predicate operations from a CAL action into an execution block
   * and combines their results into a single boolean condition. This function
   * is differnt to managePredicateConditions as it checks one condition and
   * skips over the others for the same action if it is false. This resulted
   * in decreased performance in my tests
   *
   * @param actionOp The `cal::ActionOp` whose predicates are being processed.
   * @param execBlock The block into which predicate operations are moved.
   * @param rewriter The `PatternRewriter` used to manipulate the IR.
   *
   * @return A `Value` representing the logical AND of all predicate results.
   */
  Value managePredicateConditionsSingleCheck(
      mlir::cal::ActionOp actionOp, mlir::Block *execBlock,
      mlir::PatternRewriter &rewriter,
      StateAndFifoPredicateOpCache &cache) const {

    llvm::SmallVector<mlir::Value, 4> predicateResults;

    rewriter.setInsertionPointToEnd(execBlock);

    auto falseVal = rewriter.create<mlir::arith::ConstantOp>(
        actionOp.getLoc(), rewriter.getI1Type(), rewriter.getBoolAttr(false));
    auto trueVal = rewriter.create<mlir::arith::ConstantOp>(
        actionOp.getLoc(), rewriter.getI1Type(), rewriter.getBoolAttr(true));

    bool firstCond = true;
    mlir::Value toReturn;

    // Collect and move all predicate operations into execBlock
    llvm::SmallVector<mlir::Operation *> opsToErase;
    actionOp->walk([&](mlir::cal::Predicate predicate) {
      mlir::Value predicateResult;

      auto &region = predicate.getRegion();
      if (region.empty())
        return;

      auto &block = region.front();
      while (!block.empty()) {
        // Step 1: Insert all predicate operations to current location
        auto *op = &block.front();
        if (auto resultOp = llvm::dyn_cast<mlir::cal::PredicateResultOp>(op)) {
          predicateResult = resultOp.getEvaluationResult();
          rewriter.eraseOp(op);
        } else {
          // if (mlir::Value cached = cache.cacheOrFind(op)) {
          //   op->getResult(0).replaceAllUsesWith(cached);
          //   rewriter.eraseOp(op);
          // } else {
          op->moveBefore(rewriter.getInsertionBlock(),
                         rewriter.getInsertionPoint());
          //}
        }
      }

      // Step 2: Insert a scf if, if the result is true, evaluate the next
      // predicate, if its false, return false
      auto ifOp = rewriter.create<mlir::scf::IfOp>(
          actionOp.getLoc(), rewriter.getI1Type(), predicateResult,
          /*withElseRegion=*/true);

      if (firstCond == true) {
        firstCond = false;
        toReturn = ifOp.getResult(0);
      } else {
        rewriter.create<mlir::scf::YieldOp>(actionOp.getLoc(),
                                            ifOp.getResult(0));
      }

      rewriter.setInsertionPointToEnd(&ifOp.getElseRegion().back());
      rewriter.create<mlir::scf::YieldOp>(actionOp.getLoc(),
                                          falseVal.getResult());

      rewriter.setInsertionPointToEnd(&ifOp.getThenRegion().back());

      opsToErase.push_back(predicate);
    });

    // We need a final true value for the innermost block:
    rewriter.create<mlir::scf::YieldOp>(actionOp.getLoc(), trueVal.getResult());

    // Erase old predicate operations
    for (auto *op : opsToErase)
      rewriter.eraseOp(op);

    rewriter.setInsertionPointToEnd(execBlock);

    // Store final condition associated with the action
    return toReturn;
  }

  /**
   * @brief Recursively constructs a nested chain of `scf.if` operations for a
   * list of CAL actions.
   *
   * Each `scf.if` checks the firing condition of an action and, if true,
   * executes the action's region and yields `true`. If the condition is false,
   * the function recursively generates the next `scf.if` for the remaining
   * actions. If no actions remain, the chain yields `false`.
   *
   * @param listIndex The index of the current action to process in the
   * `actions` list.
   * @param actions The list of `cal::ActionOp`s to process.
   * @param rewriter The `PatternRewriter` used to create and manipulate
   * operations.
   * @param loc The MLIR location used for newly created operations.
   *
   * @return The `Value` result of the top-level `scf.if` chain, indicating
   * whether any action fired.
   */
  Value
  constructNestedSCFIfStatements(size_t listIndex,
                                 llvm::SmallVector<cal::ActionOp> &actions,
                                 PatternRewriter &rewriter, mlir::Location loc,
                                 StateAndFifoPredicateOpCache &cache) const {

    auto actionOp = actions[listIndex];
    auto condition = managePredicateConditions(
        actionOp, rewriter.getInsertionBlock(), rewriter, cache);

    auto ifOp = rewriter.create<mlir::scf::IfOp>(
        loc, rewriter.getI1Type(), condition, /*withElseRegion=*/true);

    // Move the action body into the `then` region
    ifOp.getThenRegion().takeBody(actionOp.getRegion());

    // Yield `true` at the end of the `then` block
    rewriter.setInsertionPointToEnd(&ifOp.getThenRegion().back());
    Value trueVal = rewriter.create<mlir::arith::ConstantOp>(
        loc, rewriter.getI1Type(), rewriter.getBoolAttr(true));
    rewriter.create<mlir::scf::YieldOp>(loc, trueVal);

    // Else: either yield `false` or recurse
    rewriter.setInsertionPointToEnd(&ifOp.getElseRegion().back());

    Value elseResult;
    if (listIndex + 1 < actions.size()) {
      elseResult = constructNestedSCFIfStatements(listIndex + 1, actions,
                                                  rewriter, loc, cache);
      rewriter.setInsertionPointToEnd(&ifOp.getElseRegion().back());
    } else {
      elseResult = rewriter.create<mlir::arith::ConstantOp>(
          loc, rewriter.getI1Type(), rewriter.getBoolAttr(false));
    }

    rewriter.create<mlir::scf::YieldOp>(loc, elseResult);
    return ifOp.getResult(0);
  }
};

class ConvertCalActionsToExecutionBodiesPass
    : public impl::ConvertCalActionsToExecutionBodiesBase<
          ConvertCalActionsToExecutionBodiesPass> {
public:
  void runOnOperation() final {
    RewritePatternSet patterns(&getContext());
    patterns.add<ActionToExecBodyPattern>(&getContext());

    // Run the conversion
    if (failed(applyPatternsGreedily(getOperation(), std::move(patterns)))) {
      signalPassFailure();
    }
  }
};

} // namespace cal
} // namespace mlir

// Creates and returns a new instance of the
// ConvertCalActionsToExecutionBodiesPass. This pass is responsible for
// converting `cal.action` operations into a single `cal.execution_body` region
// within a `cal.actor`,
std::unique_ptr<mlir::Pass> mlir::cal::convertCalActionsToExecutionBodies() {
  return std::make_unique<mlir::cal::ConvertCalActionsToExecutionBodiesPass>();
}