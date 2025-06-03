#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalPasses.h"
#include "Dialect/Cal/CalTypes.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

namespace mlir::cal {
#define GEN_PASS_DEF_CONVERTCALACTIONSTOEXECUTIONBODIES
#include "Dialect/Cal/CalPasses.h.inc"

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
//   3. Move each action's `cal.predicate` operations into the execution body,
//      capturing their results and combining them using `cmpi eq` to produce a
//      firing condition.
//   4. Sort actions by `priority` attribute (higher priority first).
//   5. Wrap each action body in a nested `scf.if` region controlled by its
//      predicate condition. Only the first true condition will result in
//      execution, yielding `true`; all others fall through.
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
    actor->walk(
        [&](mlir::cal::ActionOp actionOp) { actionOps.push_back(actionOp); });

    if (actionOps.empty()) {
      return failure(); // No actions to convert
    }

    // 2.  Create a new execution body operation
    rewriter.setInsertionPointToEnd(&actor.getBody().back());
    auto execBodyOp = rewriter.create<cal::ExecutionBody>(actor.getLoc());
    auto *execBlock = new mlir::Block();
    execBodyOp.getBody().push_back(execBlock);

    // Going to need a true value in many places, insert it here
    rewriter.setInsertionPointToEnd(execBlock);
    auto trueVal = rewriter.create<mlir::arith::ConstantOp>(
        actor.getLoc(), rewriter.getI1Type(), rewriter.getBoolAttr(true));

    // 3. Move all the predicate operations from the action ops to the
    // execution body. The results from each predicate will be ORed together
    // per action, and the result will be used to determine if the action
    // should be executed. This result will be stored in the
    // actionFiringConditions map, which maps each action to its firing
    // condition.
    llvm::DenseMap<cal::ActionOp, Value> actionFiringConditions;
    for (auto actionOp : actionOps) {
      llvm::SmallVector<mlir::Value, 4> predicateResults;

      rewriter.setInsertionPointToEnd(execBlock);

      // 3.1 Extract and move predicate ops from the action to the execution
      // body. Once moved, we will erase the original predicate ops.
      llvm::SmallVector<mlir::Operation *> opsToErase;
      actionOp->walk([&](mlir::cal::Predicate predicate) {
        auto &region = predicate.getRegion();
        if (region.empty())
          return;

        auto &block = region.front();
        while (!block.empty()) {
          auto *op = &block.front();
          if (auto resultOp = llvm::dyn_cast<cal::PredicateResultOp>(op)) {
            predicateResults.push_back(resultOp.getEvaluationResult());
            rewriter.eraseOp(op);
          } else {
            op->moveBefore(execBlock, execBlock->end());
          }
        }
        opsToErase.push_back(predicate);
      });

      for (auto *op : opsToErase)
        rewriter.eraseOp(op);

      // 3.2 Combine predicate results using equality comparisons
      Value combinedResult = trueVal;
      for (auto predResult : predicateResults) {
        combinedResult = rewriter
                             .create<mlir::arith::CmpIOp>(
                                 actor.getLoc(), mlir::arith::CmpIPredicate::eq,
                                 predResult, combinedResult)
                             .getResult();
      }
      actionFiringConditions[actionOp] = combinedResult;
    }

    // 4. Move all action bodies to the execution body. Only one action may
    // fire per execution body invocation, so we will nest these actions in
    // SCF if statements. (These nestings are ordered by the action priority)

    // 4.1 Sort actions by priority
    std::sort(actionOps.begin(), actionOps.end(),
              [](const cal::ActionOp &a, const cal::ActionOp &b) {
                auto aAttr = a->getAttrOfType<mlir::IntegerAttr>("priority");
                auto bAttr = b->getAttrOfType<mlir::IntegerAttr>("priority");
                int64_t aPriority = aAttr ? aAttr.getInt() : 0;
                int64_t bPriority = bAttr ? bAttr.getInt() : 0;
                return aPriority > bPriority; // Descending order
              });

    // 4.2 Construct nested SCF if statements for each action
    Value result = constructNestedSCFIfStatements(
        0, actionOps, actionFiringConditions, rewriter, execBlock,
        execBodyOp.getLoc());


    // 5. After all actions have been processed, we need to yield the result of
    // the last action's firing condition. This will be used to determine if
    // the actor performed any action during this execution.
    rewriter.setInsertionPointToEnd(execBlock);
    rewriter.create<cal::ActionDoneOp>(actor.getLoc(), result);

    // 6. Finally, we need to erase the original action operations, as they have
    // been moved to the execution body and are no longer needed.
    for (auto actionOp : actionOps) {
      rewriter.eraseOp(actionOp);
    }

    return success();
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
   * @param actionFiringConditions A map from `cal::ActionOp` to the
   * corresponding condition `Value` used to decide whether the action should
   * fire.
   * @param rewriter The `PatternRewriter` used to create and manipulate
   * operations.
   * @param execBlock A pointer to the execution block where this SCF logic is
   * being inserted.
   * @param loc The MLIR location used for newly created operations.
   *
   * @return The `Value` result of the top-level `scf.if` chain, indicating
   * whether any action fired.
   */
  Value constructNestedSCFIfStatements(
      size_t listIndex, llvm::SmallVector<cal::ActionOp> &actions,
      llvm::DenseMap<cal::ActionOp, Value> &actionFiringConditions,
      PatternRewriter &rewriter, mlir::Block *execBlock,
      mlir::Location loc) const {

    auto actionOp = actions[listIndex];
    auto condition = actionFiringConditions[actionOp];

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
                                                  actionFiringConditions,
                                                  rewriter, execBlock, loc);
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

} // namespace mlir::cal

// Creates and returns a new instance of the ConvertCalActionsToExecutionBodiesPass.
// This pass is responsible for converting `cal.action` operations into a
// single `cal.execution_body` region within a `cal.actor`,
std::unique_ptr<mlir::Pass> mlir::cal::convertCalActionsToExecutionBodies() {
  return std::make_unique<mlir::cal::ConvertCalActionsToExecutionBodiesPass>();
}