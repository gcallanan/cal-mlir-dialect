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

    // Get the actor name
    auto actorName = op.getSymName();

    // Get the argument types from the actor's entry block
    auto &actorBody = op.getBody();
    auto argumentTypes = actorBody.getArgumentTypes();

    // Iterate through all cal::ActionOp in the actor
    for (auto actionOp : op.getOps<cal::ActionOp>()) {
      // Get the action name
      auto actionNameAttr = actionOp.getActionNameAttr();
      if (!actionNameAttr) {
        op.emitError("ActionOp missing symbol name attribute");
        return failure();
      }
      auto actionName = actionNameAttr.getValue();

      // Compose the function name: actorName_actionName
      std::string funcName = (actorName + "_" + actionName).str();
      llvm::outs() << "Creating function: " << funcName << "\n";

      // Function type: same arguments as actor, returns i1
      auto i1Type = rewriter.getI1Type();
      auto funcType = rewriter.getFunctionType(argumentTypes, {i1Type});

      // Create the function op
      auto funcOp = rewriter.create<func::FuncOp>(loc, funcName, funcType);

      // Add entry block and map arguments
      Block *entryBlock = funcOp.addEntryBlock();
      IRMapping mapping;
      mapping.map(actorBody.getArguments(), entryBlock->getArguments());

      rewriter.setInsertionPointToStart(entryBlock);

      for (auto &opToClone : actorBody.front()) {
        // Skip ActionOps and ExecutionBody ops
        if (mlir::isa<cal::ActionOp>(&opToClone) ||
            mlir::isa<cal::ExecutionBody>(&opToClone))
          continue;
        rewriter.clone(opToClone, mapping);
      }

      // Clone the action's body into the function
      if (actionOp.getBody().empty()) {
        funcOp.emitError("ActionOp has empty body");
        return failure();
      }
      for (auto &opToClone : actionOp.getBody().front()) {
        if (mlir::isa<cal::Predicate>(opToClone)) {
          continue;
        }
        rewriter.clone(opToClone, mapping);
      }

      rewriter.setInsertionPointToEnd(entryBlock);
      auto trueConst = rewriter.create<mlir::arith::ConstantOp>(
          loc, rewriter.getBoolAttr(true));
      rewriter.create<mlir::func::ReturnOp>(loc, trueConst.getResult());

      llvm::outs() << "Created function: " << funcOp << "\n";
    }

    rewriter.eraseOp(op);

    return success();
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