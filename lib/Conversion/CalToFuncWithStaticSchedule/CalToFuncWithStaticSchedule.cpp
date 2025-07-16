//===- CalPasses.cpp - Cal passes -----------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalPasses.h"
#include "Dialect/Cal/CalTypes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/ControlFlow/IR/ControlFlowOps.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Func/Transforms/FuncConversions.h"
#include "mlir/Dialect/Index/IR/IndexDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Rewrite/FrozenRewritePatternSet.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

#include "Conversion/CalToFuncWithStaticSchedule/CalToFuncWithStaticSchedule.h"
#include "Conversion/CalToFuncWithStaticSchedule/CycloStaticDataflowAnalysis.h"
#include "Conversion/Passes.h"

namespace mlir {
#define GEN_PASS_DEF_CONVERTCALTOFUNCWITHSTATICSCHEDULE
#include "Conversion/Passes.h.inc"

/// Converts a `cal.network` operation into a top-level `func.func @main`
/// function using a pre-computed static schedule.
///
/// This transformation differs from the basic CalToFunc conversion by using
/// cyclo-static dataflow (CSDF) analysis to generate a deterministic, static
/// schedule of actor actions. Instead of a dynamic while loop that executes
/// actors until no progress is made, this creates a control flow graph with
/// explicit basic blocks for each action firing in the static schedule.
///
/// The transformation process:
/// 1. **Initialization**: All network-level constants, FIFO creations, and
///    state variable declarations are copied into the main function entry
///    block.
/// 2. **Static Schedule Execution**: Each action in the pre-computed schedule
///    gets its own basic block containing a function call to the corresponding
///    actor action function.
/// 3. **Conditional Branching**: After each action call, the boolean result
///    determines the next control flow:
///    - If the action has predicates (can return false), a conditional branch
///      either continues to the next action or exits the loop
///    - If the action has no predicates (always returns true), control flows
///      directly to the next action
/// 4. **Loop Structure**: The schedule executes in an infinite loop, with
///    exit conditions based on action predicate failures.
///
/// Example Input:
/// ```
/// cal.network {
///     %inputPort, %outputPort = fifo.create<i32> (10) : !fifo.input_port<i32>,
///     !fifo.output_port<i32>
///     %inputPort_0, %outputPort_1 = fifo.create<i32> (10) :
///             !fifo.input_port<i32>, !fifo.output_port<i32>
///     cal.create_instance @source "source" ()
///         ports_out (%inputPort_0 : !fifo.input_port<i32>)
///     cal.create_instance @pass "pass" ()
///         ports_in (%outputPort_1 : !fifo.output_port<i32>)
///         ports_out (%inputPort : !fifo.input_port<i32>)
///     cal.create_instance @sink "sink" ()
///         ports_in (%outputPort : !fifo.output_port<i32>)
/// }
/// ```
///
/// Example Output:
/// ```
/// func.func @main() {
///     %c0_i32 = arith.constant 0 : i32
///     %inputPort, %outputPort = fifo.create<i32> (10) : !fifo.input_port<i32>,
///             !fifo.output_port<i32>
///     %inputPort_0, %outputPort_1 = fifo.create<i32> (10) :
///             !fifo.input_port<i32>, !fifo.output_port<i32> %0 =
///     cal.create_state_var<i32> : !cal.state_ref<i32> cal.set(%0 :
///             !cal.state_ref<i32>, %c0_i32 : i32)
///     cf.br ^bb2
///   ^bb1:  // exit block
///     return
///   ^bb2:  // first action in schedule
///     %1 = call @source_transmit(%inputPort_0, %0) :
///             (!fifo.input_port<i32>, !cal.state_ref<i32>) -> i1
///             i1
///     cf.cond_br %1, ^bb3, ^bb1
///   ^bb3:  // second action in schedule
///     %2 = call @source_transmit(%inputPort_0, %0) :
///             (!fifo.input_port<i32>, !cal.state_ref<i32>) -> i1
///     cf.cond_br %2, ^bb4, ^bb1
///   ^bb4:  // remaining actions in schedule
///     %3 = call @pass_passThrough(%outputPort_1, %inputPort) :
///             (!fifo.output_port<i32>, !fifo.input_port<i32>) -> i1
///     %4 = call @sink_receive(%outputPort) : (!fifo.output_port<i32>) -> i1
///     %5 = call @sink_receive(%outputPort) : (!fifo.output_port<i32>) -> i1
///     cf.cond_br %5, ^bb2, ^bb1
/// }
/// ```
///
/// This approach provides deterministic execution order and can be more
/// efficient than dynamic scheduling for streaming applications
/// with predictable dataflow patterns.
struct ConvertCalNetworkToMainFuncWithStaticSchedule
    : public OpRewritePattern<cal::NetworkOp> {

  ConvertCalNetworkToMainFuncWithStaticSchedule(
      MLIRContext *context, const std::vector<cal::ActionOp> &schedule)
      : OpRewritePattern(context), staticSchedule(schedule) {}

  LogicalResult matchAndRewrite(cal::NetworkOp op,
                                PatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    SymbolTableCollection symbolTable;

    // Step 1: Create the main function
    auto funcType = rewriter.getFunctionType({}, {});
    auto mainFunc = rewriter.create<func::FuncOp>(loc, "main", funcType);
    Block *entryBlock = mainFunc.addEntryBlock();
    rewriter.setInsertionPointToStart(entryBlock);

    // Step 2: In the body of the main function, copy all initialization code
    // from the network body, skipping CreateInstanceOp. However, we keep the
    // CreateInstanceOp to map actors to instances which we use later for
    // getting the correct argument into the newly created functions
    IRMapping mapping;
    llvm::MapVector<cal::ActorOp, cal::CreateInstanceOp> actorToInstanceMap;
    for (auto &bodyOp : op.getBody().front()) {
      if (auto createInstanceOp = dyn_cast<cal::CreateInstanceOp>(&bodyOp)) {
        auto actorOp = symbolTable.lookupNearestSymbolFrom<cal::ActorOp>(
            op.getOperation(), createInstanceOp.getActorRefAttr());
        if (actorOp)
          actorToInstanceMap[actorOp] = createInstanceOp;
        continue;
      }
      rewriter.clone(bodyOp, mapping);
    }

    // Step 3: Create the loop structure for static scheduling
    auto i1Type = rewriter.getI1Type();
    auto trueConst = rewriter.create<mlir::arith::ConstantOp>(
        loc, rewriter.getBoolAttr(true));

    Block *loopExitBlock =
        rewriter.createBlock(&mainFunc.getRegion(), mainFunc.getRegion().end());

    Block *loopHeaderBlock =
        rewriter.createBlock(&mainFunc.getRegion(), mainFunc.getRegion().end());

    rewriter.setInsertionPointToEnd(entryBlock);
    rewriter.create<mlir::cf::BranchOp>(loc, loopHeaderBlock);

    // Step 3: Populate the loop with actions from the static schedule
    Block *currentBlock = loopHeaderBlock;
    for (size_t i = 0; i < staticSchedule.size(); ++i) {
      // Step 3.1 Get the function name to be called
      auto actionOp = staticSchedule[i];
      SmallVector<Value, 4> args;
      auto actorOp = actionOp->getParentOfType<cal::ActorOp>();
      auto actorName = actorOp.getSymName();
      auto actionNameAttr = actionOp.getActionNameAttr();

      // Add null check here
      if (!actionNameAttr) {
        actionOp.emitError("ActionOp missing action name attribute. Actor: ")
            << actorName << ", Action: " << actionOp << "\n";
        return failure();
      }

      std::string funcName =
          (actorName + "_" + actionNameAttr.getValue()).str();

      // Step 3.2 Get the arguments to insert into the function call
      // These are the same arguments in the corresponding CreateInstanceOp
      // for the actor, which we stored in the mapping
      auto it = actorToInstanceMap.find(actorOp);
      if (it != actorToInstanceMap.end()) {
        auto createInstanceOp = it->second;
        for (auto operand : createInstanceOp.getOperands())
          args.push_back(mapping.lookupOrDefault(operand));
      } else {
        llvm::errs() << "Warning: No CreateInstanceOp found for actor "
                     << actorName << "\n";
      }

      rewriter.setInsertionPointToEnd(currentBlock);
      Value actionResult =
          rewriter.create<func::CallOp>(loc, funcName, i1Type, args)
              .getResult(0);

      // Step 3.3 Create the conditional branch to the next action or exit
      if (i == staticSchedule.size() - 1) {
        rewriter.create<mlir::cf::CondBranchOp>(loc, actionResult,
                                                loopHeaderBlock, loopExitBlock);
      } else {
        // Step 3.3.1: Some functions return values of either 0 or 1 and others
        // only return a value of 1. In the case where only 1 is returned we do
        // not need to check if it was 0 so we can skip branching. It is only
        // possible for zero to be returned if the action has predicates which
        // may evaluate to false. Thus we check if the action has predicates, if
        // it does we branch or else we do not branch
        bool hasPredicates = false;

        for (auto predicateOp : actionOp.getOps<cal::Predicate>()) {
          hasPredicates = true;
          break;
        }

        if (hasPredicates) {
          Block *nextActionBlock = rewriter.createBlock(
              &mainFunc.getRegion(), mainFunc.getRegion().end());
          rewriter.setInsertionPointToEnd(currentBlock);
          rewriter.create<mlir::cf::CondBranchOp>(
              loc, actionResult, nextActionBlock, loopExitBlock);
          rewriter.setInsertionPointToEnd(nextActionBlock);
          currentBlock = nextActionBlock;
        }
      }
    }

    // Step 4: Finish things off at the end
    rewriter.setInsertionPointToEnd(loopExitBlock);
    rewriter.create<func::ReturnOp>(loc);

    rewriter.eraseOp(op);
    return success();
  }

private:
  const std::vector<cal::ActionOp> &staticSchedule;
};

/// Converts a `cal.actor` operation into one or more `func.func` operations,
/// with each `cal.action` within the actor becoming a separate function.
///
/// This transformation differs from the basic CalToFunc conversion by handling
/// actors that contain multiple named actions rather than a single execution
/// body. Each action becomes an independent function that can be called
/// individually as part of a static schedule.
///
/// The transformation process for each action:
/// 1. **Function Creation**: A new function is created with the naming
/// convention
///    `{actorName}_{actionName}`, taking the actor's arguments as parameters
///    and returning an `i1` to indicate success/failure.
/// 2. **Actor Body Cloning**: All non-action operations from the actor body
///    (constants, state variables, etc.) are cloned into each action function.
/// 3. **Predicate Processing**: All `cal.predicate` blocks within the action
///    are processed and their results are combined using logical AND operations
///    to create a single condition.
/// 4. **Conditional Execution**: The action's body is wrapped in an `scf.if`
///    operation, executing only when all predicates evaluate to true:
///    - **Then branch**: Contains the action's execution logic and yields
///    `true`
///    - **Else branch**: Yields `false` to indicate the action did not fire
/// 5. **Return Value**: The function returns the result of the conditional
///    execution, indicating whether the action successfully executed.
///
/// If an actor contains multiple actions, multiple functions are generated,
/// one for each action. This enables fine-grained control over action execution
/// in static scheduling scenarios.
///
/// Example Input:
/// ```
/// cal.actor @source()
///     ports_out (%arg0: !fifo.input_port<i32>)
/// {
///     %c1_i32 = arith.constant 1 : i32
///     %c20_i32 = arith.constant 20 : i32
///     %c0_i32 = arith.constant 0 : i32
///     %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
///     cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
///     cal.action "transmit" priority=0
///     {
///         cal.predicate {
///             %4 = cal.get(%0 : !cal.state_ref<i32>) : i32
///             %5 = arith.cmpi slt, %4, %c20_i32 : i32
///             cal.predicate_result %5 : i1
///         }
///         %1 = cal.get(%0 : !cal.state_ref<i32>) : i32
///         fifo.print("Tx: %i\0A\00", %1) : (i32)
///         %2 = cal.get(%0 : !cal.state_ref<i32>) : i32
///         %3 = arith.addi %2, %c1_i32 : i32
///         cal.set(%0 : !cal.state_ref<i32>, %3 : i32)
///         fifo.push(%arg0 : !fifo.input_port<i32>, %1 : i32)
///     }
/// }
/// ```
///
/// Example Output:
/// ```
/// func.func @source_transmit(%arg0: !fifo.input_port<i32>,
///             %arg1: !cal.state_ref<i32>) -> i1 {
///     %true = arith.constant true
///     %false = arith.constant false
///     %c1_i32 = arith.constant 1 : i32
///     %c20_i32 = arith.constant 20 : i32
///     %0 = cal.get(%arg1 : !cal.state_ref<i32>) : i32
///     %1 = arith.cmpi slt, %0, %c20_i32 : i32
///     %2 = scf.if %1 -> (i1) {
///         %3 = cal.get(%arg1 : !cal.state_ref<i32>) : i32
///         fifo.print("Tx: %i\0A\00", %3) : (i32)
///         %4 = cal.get(%arg1 : !cal.state_ref<i32>) : i32
///         %5 = arith.addi %4, %c1_i32 : i32
///         cal.set(%arg1 : !cal.state_ref<i32>, %5 : i32)
///         fifo.push(%arg0 : !fifo.input_port<i32>, %3 : i32)
///         scf.yield %true : i1
///     } else {
///         scf.yield %false : i1
///     }
///     return %2 : i1
/// }
/// ```
///
/// This approach enables static scheduling systems to call specific actions
/// independently.
class ConvertCalActorToActionFuncs : public OpRewritePattern<cal::ActorOp> {
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(cal::ActorOp op,
                                PatternRewriter &rewriter) const override {
    mlir::Location loc = op.getLoc();
    auto actorName = op.getSymName();
    auto &actorBody = op.getBody();
    auto argumentTypes = actorBody.getArgumentTypes();

    for (auto actionOp : op.getOps<cal::ActionOp>()) {
      rewriter.setInsertionPoint(op);
      if (failed(createActionFunction(actionOp, actorName, argumentTypes,
                                      actorBody.front(), rewriter, loc))) {
        return failure();
      }
    }

    rewriter.eraseOp(op);
    return success();
  }

private:
  LogicalResult createActionFunction(cal::ActionOp actionOp,
                                     StringRef actorName,
                                     TypeRange argumentTypes, Block &actorBody,
                                     PatternRewriter &rewriter,
                                     Location loc) const {
    auto actionNameAttr = actionOp.getActionNameAttr();
    if (!actionNameAttr) {
      actionOp.emitError("ActionOp missing symbol name attribute");
      return failure();
    }

    std::string funcName = (actorName + "_" + actionNameAttr.getValue()).str();
    auto i1Type = rewriter.getI1Type();
    auto funcType = rewriter.getFunctionType(argumentTypes, {i1Type});
    auto funcOp = rewriter.create<func::FuncOp>(loc, funcName, funcType);

    Block *entryBlock = funcOp.addEntryBlock();
    IRMapping mapping;
    mapping.map(actorBody.getArguments(), entryBlock->getArguments());

    rewriter.setInsertionPointToStart(entryBlock);
    auto trueConst = rewriter.create<mlir::arith::ConstantOp>(
        loc, rewriter.getBoolAttr(true));
    auto falseConst = rewriter.create<mlir::arith::ConstantOp>(
        loc, rewriter.getBoolAttr(false));

    cloneActorBodyOps(actorBody, rewriter, mapping);

    if (actionOp.getBody().empty()) {
      funcOp.emitError("ActionOp has empty body");
      return failure();
    }

    Value combinedPredicate = processPredicates(actionOp, rewriter, mapping,
                                                trueConst.getResult(), loc);
    createConditionalExecution(actionOp, rewriter, mapping, combinedPredicate,
                               trueConst.getResult(), falseConst.getResult(),
                               entryBlock, i1Type, loc);
    return success();
  }

  void cloneActorBodyOps(Block &actorBody, PatternRewriter &rewriter,
                         IRMapping &mapping) const {
    for (auto &opToClone : actorBody) {
      if (mlir::isa<cal::ActionOp>(&opToClone) ||
          mlir::isa<cal::ExecutionBody>(&opToClone))
        continue;
      rewriter.clone(opToClone, mapping);
    }
  }

  Value processPredicates(cal::ActionOp actionOp, PatternRewriter &rewriter,
                          IRMapping &mapping, Value trueConst,
                          Location loc) const {
    SmallVector<Value, 4> predicateResults;

    for (auto &bodyOp : actionOp.getBody().front()) {
      if (auto predicateOp = dyn_cast<cal::Predicate>(&bodyOp)) {
        for (auto &predOp : predicateOp->getRegion(0).front()) {
          if (isa<cal::PredicateResultOp>(predOp)) {
            Value predResult = mapping.lookupOrDefault(predOp.getOperand(0));
            predicateResults.push_back(predResult);
          } else {
            rewriter.clone(predOp, mapping);
          }
        }
      }
    }

    Value combinedPredicate = trueConst;
    for (auto predResult : predicateResults) {
      combinedPredicate = rewriter.create<mlir::arith::AndIOp>(
          loc, combinedPredicate, predResult);
    }
    return combinedPredicate;
  }

  void createConditionalExecution(cal::ActionOp actionOp,
                                  PatternRewriter &rewriter, IRMapping &mapping,
                                  Value condition, Value trueValue,
                                  Value falseValue, Block *entryBlock,
                                  Type i1Type, Location loc) const {
    auto ifOp = rewriter.create<mlir::scf::IfOp>(loc, i1Type, condition, true);

    rewriter.setInsertionPointToStart(&ifOp.getThenRegion().front());
    for (auto &opToClone : actionOp.getBody().front()) {
      if (mlir::isa<cal::Predicate>(opToClone)) {
        continue;
      }
      rewriter.clone(opToClone, mapping);
    }
    rewriter.create<mlir::scf::YieldOp>(loc, trueValue);

    rewriter.setInsertionPointToStart(&ifOp.getElseRegion().front());
    rewriter.create<mlir::scf::YieldOp>(loc, falseValue);

    rewriter.setInsertionPointToEnd(entryBlock);
    rewriter.create<mlir::func::ReturnOp>(loc, ifOp.getResult(0));
  }
}; // namespace mlir

/// This pass converts CAL dialect operations to standard MLIR function calls
/// using cyclo-static dataflow (CSDF) analysis to generate deterministic static
/// schedules.
///
/// Unlike the basic `ConvertCalToFuncPass` which uses dynamic scheduling with
/// while loops, this pass leverages static analysis to pre-compute an optimal
/// execution order for actor actions. This approach is particularly beneficial
/// for streaming applications with predictable dataflow patterns, as it
/// eliminates runtime scheduling overhead and provides deterministic execution.
///
/// **Pass Execution Flow:**
/// 1. **CSDF Analysis**: Runs cyclo-static dataflow analysis to determine
///    firing patterns, balance equations, and static schedules for all actors
///    in the network. This analysis ensures that all actors are schedulable
///    (either SDF or CSDF actors) before proceeding.
///
/// 2. **Debug Output** (optional): Based on command-line flags, the pass can
///    print various analysis results including finite state machines, CSDF
///    schedules, balance equations, and the final static schedule.
///
/// 3. **Schedulability Check**: Verifies that all actors in the network are
///    either synchronous dataflow (SDF) or cyclo-static dataflow (CSDF) actors.
///    Non-schedulable actors cause the pass to fail with an error.
///
/// 4. **State Variable Hoisting**: Uses existing patterns to hoist state
///    variable declarations from actor bodies to the network level, ensuring
///    they are declared only once when actors become functions.
///
/// 5. **Static Schedule Generation**: Generates a static schedule through
///    simulation of the dataflow network, producing a deterministic sequence
///    of action firings.
///
/// 6. **Code Generation**: Applies rewrite patterns to convert:
///    - `cal.actor` operations into individual `func.func` operations for each
///      action within the actor
///    - `cal.network` operations into a main function with explicit control
///      flow based on the static schedule
///
/// **Key Differences from Dynamic Scheduling:**
/// - **Deterministic Execution**: The static schedule ensures predictable
///   execution order, making the system suitable for real-time applications.
/// - **Performance**: Eliminates runtime scheduling decisions and loop overhead
///   present in dynamic scheduling approaches.
/// - **Limitations**: Only works with SDF/CSDF actors that have predictable
///   token production/consumption patterns.
///
/// **Required Analysis:**
/// This pass depends on the `CycloStaticDataflowAnalysis` to provide:
/// - Actor finite state machines and firing patterns
/// - Balance equations for token flow analysis
/// - Static schedule generation through network simulation
/// - Schedulability verification for all actors
class ConvertCalToFuncWithStaticSchedulePass
    : public impl::ConvertCalToFuncWithStaticScheduleBase<
          ConvertCalToFuncWithStaticSchedulePass> {
public:
  void runOnOperation() final {

    // Step 1: Generate the analysis object
    auto &csdfAnalysis = getAnalysis<CycloStaticDataflowAnalysis>();

    // Get the singular cal::NetworkOp in the module (if any)
    cal::NetworkOp networkOp = nullptr;
    auto networkOpsRange =
        getOperation()->getRegion(0).front().getOps<cal::NetworkOp>();
    if (!networkOpsRange.empty()) {
      networkOp = *networkOpsRange.begin();
    }

    // Step 2: Print various analysis results based on flags
    if (print_fsm_for_testing.getValue()) {
      for (auto actorOp :
           getOperation()->getRegion(0).front().getOps<cal::ActorOp>()) {
        csdfAnalysis.printActorStateMachine(actorOp);
      }
    }
    if (print_csdf_schedule_for_testing.getValue()) {
      for (auto actorOp :
           getOperation()->getRegion(0).front().getOps<cal::ActorOp>()) {
        csdfAnalysis.printCSDFPhases(actorOp);
      }
    }
    if (print_balance_equations_for_testing.getValue() && networkOp) {
      csdfAnalysis.printBalanceEquations(networkOp);
    }
    if (print_solved_balance_equations_for_testing.getValue() && networkOp) {
      csdfAnalysis.printFiringsPerActorFromSolvedBalanceEquations(networkOp);
    }

    // Step 3: Confirm that all actors are CSDF or SDF actors or else we bail
    // out
    if (networkOp) {
      auto schedulableActors = csdfAnalysis.getNonSchedulableActors(networkOp);
      if (!schedulableActors.empty()) {
        llvm::errs() << "Actors than cannot be scheduled found:\n";
        for (auto actorOp : schedulableActors) {
          llvm::errs() << "  " << actorOp.getSymName() << "\n";
        }
        mlir::emitError(
            networkOp.getLoc(),
            "Not all actors are CSDF or SDF actors. Pass cannot proceed.");
        signalPassFailure();
        return;
      }
    }

    if (print_static_schedule_for_testing.getValue() && networkOp) {
      csdfAnalysis.printStaticSchedule(networkOp);
    }

    // Step 4: Generate the static schedule
    std::vector<cal::ActionOp> schedule;
    if (networkOp) {
      schedule = csdfAnalysis.generateScheduleThroughSimulation(networkOp);
    }

    // Step 5: Hoist cal state variable declarations out of cal.actors into
    // cal.network ops So they are only declared once after the actors are
    // transformed into functions
    RewritePatternSet hoistPatterns(&getContext());
    cal::populateHoistCalStateOutOfActorPatterns(hoistPatterns);
    if (failed(
            applyPatternsGreedily(getOperation(), std::move(hoistPatterns)))) {
      signalPassFailure();
    }

    // Step 6: Convert cal.actor and cal.network ops into functions and
    // function calls using the static schedule
    RewritePatternSet staticSchedulePatterns(&getContext());
    staticSchedulePatterns.add<ConvertCalActorToActionFuncs>(&getContext());
    staticSchedulePatterns.add<ConvertCalNetworkToMainFuncWithStaticSchedule>(
        &getContext(), schedule);
    if (failed(applyPatternsGreedily(getOperation(),
                                     std::move(staticSchedulePatterns)))) {
      signalPassFailure();
    }
  }
};

} // namespace mlir

/// Creates a pass to lower cal.network and cal.actor ops into functions and
/// function calls.
std::unique_ptr<mlir::Pass>
mlir::createConvertCalToFuncWithStaticSchedulePass() {
  return std::make_unique<mlir::ConvertCalToFuncWithStaticSchedulePass>();
}