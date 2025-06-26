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
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(cal::NetworkOp op,
                                PatternRewriter &rewriter) const override {

    rewriter.eraseOp(op);

    return success();
  }
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
                                   TypeRange argumentTypes,
                                   Block &actorBody,
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
                                PatternRewriter &rewriter,
                                IRMapping &mapping, Value condition,
                                Value trueValue, Value falseValue,
                                Block *entryBlock, Type i1Type,
                                Location loc) const {
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

    auto &csdfAnalysis = getAnalysis<CycloStaticDataflowAnalysis>();

    bool printFsm = print_fsm_for_testing.getValue();
    if (printFsm) {
      getOperation()->walk([&](cal::ActorOp actorOp) {
        csdfAnalysis.printActorStateMachine(actorOp);
      });
    }

    bool printCSDFSchedule = print_csdf_schedule_for_testing.getValue();
    if (printCSDFSchedule) {
      getOperation()->walk(
          [&](cal::ActorOp actorOp) { csdfAnalysis.printCSDFPhases(actorOp); });
    }

    bool printBalanceEquations = print_balance_equations_for_testing.getValue();
    if (printBalanceEquations) {
      getOperation()->walk([&](cal::NetworkOp networkOp) {
        csdfAnalysis.printBalanceEquations(networkOp);
      });
    }

    bool printSolvedBalanceEquations =
        print_solved_balance_equations_for_testing.getValue();
    if (printSolvedBalanceEquations) {
      getOperation()->walk([&](cal::NetworkOp networkOp) {
        csdfAnalysis.printFiringsPerActorFromSolvedBalanceEquations(networkOp);
      });
    }

    bool printStaticSchedule = print_static_schedule_for_testing.getValue();
    if (printStaticSchedule) {
      getOperation()->walk([&](cal::NetworkOp networkOp) {
        csdfAnalysis.printStaticSchedule(networkOp);
      });
    }

    RewritePatternSet hoistPatterns(&getContext());
    cal::populateHoistCalStateOutOfActorPatterns(hoistPatterns);

    if (failed(
            applyPatternsGreedily(getOperation(), std::move(hoistPatterns)))) {
      signalPassFailure();
    }

    RewritePatternSet staticSchedulePatterns(&getContext());
    staticSchedulePatterns.add<ConvertCalActorToActionFuncs>(&getContext());
    staticSchedulePatterns.add<ConvertCalNetworkToMainFuncWithStaticSchedule>(
        &getContext(),
        /*benefit=*/0);
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