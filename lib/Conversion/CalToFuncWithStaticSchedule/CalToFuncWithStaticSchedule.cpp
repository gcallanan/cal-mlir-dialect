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

struct ConvertCalNetworkToMainFuncWithStaticSchedule
    : public OpRewritePattern<cal::NetworkOp> {

  ConvertCalNetworkToMainFuncWithStaticSchedule(
      MLIRContext *context, const std::vector<cal::ActionOp> &schedule)
      : OpRewritePattern(context), staticSchedule(schedule) {}

  LogicalResult matchAndRewrite(cal::NetworkOp op,
                                PatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    SymbolTableCollection symbolTable;

    // Insert main function before the network op
    rewriter.setInsertionPoint(op);
    auto funcType = rewriter.getFunctionType({}, {});
    auto mainFunc = rewriter.create<func::FuncOp>(loc, "main", funcType);
    Block *entryBlock = mainFunc.addEntryBlock();
    rewriter.setInsertionPointToStart(entryBlock);

    // Clone network body ops, skipping CreateInstanceOp, and map actors to instances
    IRMapping mapping;
    llvm::DenseMap<cal::ActorOp, cal::CreateInstanceOp> actorToInstanceMap;
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

    // Create infinite while loop (scf.WhileOp)
    auto i1Type = rewriter.getI1Type();
    auto trueConst = rewriter.create<mlir::arith::ConstantOp>(
        loc, rewriter.getBoolAttr(true));
    auto whileOp = rewriter.create<mlir::scf::WhileOp>(
        loc, TypeRange{}, ValueRange{trueConst});

    // Condition block: yields the i1 argument as condition
    Block *condBlock = rewriter.createBlock(
        &whileOp.getBefore(), whileOp.getBefore().end(), {i1Type}, {loc});
    rewriter.setInsertionPointToEnd(condBlock);
    rewriter.create<mlir::scf::ConditionOp>(loc, condBlock->getArgument(0), ValueRange{});

    // Body block: executes the static schedule, yields true to continue
    Block *bodyBlock = rewriter.createBlock(&whileOp.getAfter(), whileOp.getAfter().end());
    rewriter.setInsertionPointToEnd(bodyBlock);

    for (auto actionOp : staticSchedule) {
      SmallVector<Value, 4> args;
      auto actorOp = actionOp->getParentOfType<cal::ActorOp>();
      auto actorName = actorOp.getSymName();
      auto actionNameAttr = actionOp.getActionNameAttr();
      std::string funcName = (actorName + "_" + actionNameAttr.getValue()).str();

      // Find the corresponding CreateInstanceOp for this actor, from this we can get the operands
      // that need to be passed to the action function.
      auto it = actorToInstanceMap.find(actorOp);
      if (it != actorToInstanceMap.end()) {
        auto createInstanceOp = it->second;
        for (auto operand : createInstanceOp.getOperands())
          args.push_back(mapping.lookupOrDefault(operand));
      } else {
        llvm::errs() << "Warning: No CreateInstanceOp found for actor " << actorName << "\n";
      }

      rewriter.create<func::CallOp>(loc, funcName, i1Type, args);
    }

    rewriter.create<mlir::scf::YieldOp>(loc, ValueRange{trueConst});
    rewriter.setInsertionPointAfter(whileOp);
    rewriter.create<func::ReturnOp>(loc);

    rewriter.eraseOp(op);
    return success();
  }

private:
  const std::vector<cal::ActionOp> &staticSchedule;
};

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
      getOperation()->walk([&](cal::ActorOp actorOp) {
        csdfAnalysis.printActorStateMachine(actorOp);
      });
    }
    if (print_csdf_schedule_for_testing.getValue()) {
      getOperation()->walk(
          [&](cal::ActorOp actorOp) { csdfAnalysis.printCSDFPhases(actorOp); });
    }
    if (print_balance_equations_for_testing.getValue() && networkOp) {
      csdfAnalysis.printBalanceEquations(networkOp);
    }
    if (print_solved_balance_equations_for_testing.getValue() && networkOp) {
      csdfAnalysis.printFiringsPerActorFromSolvedBalanceEquations(networkOp);
    }
    if (print_static_schedule_for_testing.getValue() && networkOp) {
      csdfAnalysis.printStaticSchedule(networkOp);
    }

    // Step 3: Generate the static schedule
    std::vector<cal::ActionOp> schedule;
    if (networkOp) {
      schedule = csdfAnalysis.generateScheduleThroughSimulation(networkOp);
    }

    // Step 4: Hoist cal state variable declarations out of cal.actors into
    // cal.network ops So they are only declared once after the actors are
    // transformed into functions
    RewritePatternSet hoistPatterns(&getContext());
    cal::populateHoistCalStateOutOfActorPatterns(hoistPatterns);
    if (failed(
            applyPatternsGreedily(getOperation(), std::move(hoistPatterns)))) {
      signalPassFailure();
    }

    // Step 5: Convert cal.actor and cal.network ops into functions and
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