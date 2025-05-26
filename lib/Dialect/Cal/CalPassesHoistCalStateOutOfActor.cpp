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
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Rewrite/FrozenRewritePatternSet.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

#include "Dialect/Cal/CalPasses.h"

namespace mlir::cal {
#define GEN_PASS_DEF_HOISTCALSTATEOUTOFACTOR
#include "Dialect/Cal/CalPasses.h.inc"

// This class defines a rewrite pattern for the cal.actor operation. Its goal is
// to lift all initialization-only operations (i.e., those outside the
// cal.execution_body region) into explicit block arguments of the actor’s entry
// block, then remove the original ops. After this pass, those values are
// supplied as incoming arguments rather than being computed inside the actor
// definition.
//
// NOTE: constant ops are not removed and transformed into arguments. This
// is because leaving them in leaves the door open for optimizations further
// in the pipeline. If they were arguments the compiler would not know that they
// are constants and would not be able to optimize them away.
//
// Input example:
// cal.actor @src(%arg0: i32)
//     ports_out (
//       %arg1: !fifo.input_port<i32>
//     )
//   {
//     %true = arith.constant true
//     %c0_i32 = arith.constant 0 : i32
//     %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
//     cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
//     cal.execution_body {
//       cal.action_done %true : i1
//     }
//   }
//
//  Transformed output:
//   cal.actor @src(%arg0: i32, %arg2: !cal.state_ref<i32>)
//     ports_out (
//       %arg1: !fifo.input_port<i32>
//     )
//   {
//     %true = arith.constant true
//     cal.execution_body {
//       cal.action_done %true : i1
//     }
//   }
//
struct MoveInitOperationsToArguments : public OpRewritePattern<cal::ActorOp> {
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(cal::ActorOp actorOp,
                                PatternRewriter &rewriter) const override {

    Block &entryBlock = actorOp.getBody().front();
    auto beginIt = actorOp.getBody().op_begin();
    auto endIt = actorOp.getBody().op_end();
    bool variableHoisted = false;
    SmallVector<Operation *, 4> opsToErase;

    // 1. We need to find every operation in the entry block, add it to the
    // blocks argument list and then remove the operation.
    for (auto it = beginIt; it != endIt; ++it) {
      Operation &op = *it; // reference to the operation
      if (!mlir::isa<cal::ExecutionBody>(op) &&
          !op.hasTrait<mlir::OpTrait::ConstantLike>()) {
        variableHoisted = true;

        // 1.1 Add an argument to the actorOp for each result in the entry block
        SmallVector<BlockArgument, 4> newArgs;
        for (Value result : op.getResults()) {
          Type resultType = result.getType();
          BlockArgument newArg =
              entryBlock.addArgument(resultType, actorOp.getLoc());
          newArgs.push_back(newArg);
        }

        // 1.2 Remove these operations and replace their uses with the arguments
        // instead
        opsToErase.push_back(&op);
        op.replaceAllUsesWith(newArgs);
      }
    }

    // 2 Finish off by erasing all replaced operations
    for (Operation *op : opsToErase) {
      rewriter.eraseOp(op);
    }

    if (variableHoisted)
      return success();
    else
      return failure();
  }
};

// This class defines a rewrite pattern for the cal.create_instance operation.
// Its goal is to duplicate all of the actor’s initialization-only instructions
// (those outside any cal.execution_body) directly above each CreateInstanceOp
// site, then extend that CreateInstanceOp’s operand list to include the values
// produced by those cloned initialization ops. After this pass, each
// cal.create_instance op has all of the state‐setup values inlined as explicit
// arguments, and the original initialization logic remains in the network body.
//
// NOTE: constant ops are hoisted, but not passed into the
// CreateInstanceOp as an argument. This is because the constants are also kept
// in the actrorOp to ensure that they are optimised correctly.
//
// Input example:
//     cal.network {
//       %c10_i32 = arith.constant 10 : i32
//       %inputPort, %outputPort = fifo.create<i32> (3)
//               : !fifo.input_port<i32>, !fifo.output_port<i32>
//       cal.create_instance @src "srcA" (%c10_i32 : i32)
//           ports_out (%inputPort : !fifo.input_port<i32>)
//     }
//
// Transformed output:
//     cal.network {
//       %c0_i32 = arith.constant 0 : i32
//       %c10_i32 = arith.constant 10 : i32
//       %inputPort, %outputPort = fifo.create<i32> (3):
//               !fifo.input_port<i32>, !fifo.output_port<i32>
//       %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
//       cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
//       cal.create_instance @src "srcA" (%c10_i32, %0:
//               i32, !cal.state_ref<i32>)
//           ports_out (%inputPort : !fifo.input_port<i32>)
//     }

struct AddStateAboveCreateInstance
    : public OpRewritePattern<cal::CreateInstanceOp> {
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(cal::CreateInstanceOp instanceOp,
                                PatternRewriter &rewriter) const override {

    SymbolTableCollection symbolTable;
    FlatSymbolRefAttr actorRef = instanceOp.getActorRefAttr();

    cal::ActorOp actorOp =
        symbolTable.lookupNearestSymbolFrom<cal::ActorOp>(instanceOp, actorRef);
    if (!actorOp)
      failure();

    mlir::Region &actorBody = actorOp.getBody();

    // This pattern creates a new CreateInstanceOp which will in turn result
    // in this pattern running again which can result in an infinite loop. We
    // need a termination condition. This occurs when the number of operands
    // of the CreateInstanceOp is greater than the number of arguments in the
    // actorOp. This means a new CreateInstanceOp has already been
    // updated and as such we can skip processing them.
    if (instanceOp.getNumOperands() > actorBody.getArguments().size()) {
      return failure();
    }

    // An additional termination condition occurs if there are no operations in
    // the actor body that are not cal.execution_body or arith.constant. This
    // means that there are no operations to hoist and as such we can skip
    // processing them.
    auto beginIt = actorBody.op_begin();
    auto endIt = actorBody.op_end();
    bool nonConstantsToHoist = false;
    for (auto it = beginIt; it != endIt; ++it) {
      Operation &op = *it; // reference to the operation
      if (!mlir::isa<cal::ExecutionBody>(op) &&
          !op.hasTrait<mlir::OpTrait::ConstantLike>()) {
        nonConstantsToHoist = true;
      }
    }

    if (!nonConstantsToHoist) {
      return failure();
    }

    mlir::SmallVector<mlir::Value, 4> operands(instanceOp.getOperands().begin(),
                                               instanceOp.getOperands().end());
    // 1. Initialise a map mapping the original operands to the the operands
    // of the cloned equivalent. We need this as when we clone an operation, the
    // operands it has are the same as in the original operation which are not
    // in the same scope. We need to replace these operands with the operands
    // produced by other cloned operations and to do this we need to keep track
    // of which cloned operands map to which original operands.
    //
    // The cloned operations can also use operands from the arguments list of
    // the actor. When they are cloned above the CreateInstanceOp, they can
    // instead use the operands that are passed to the CreateInstanceOp.
    // So we populate the map with the operands from the CreateInstanceOp and
    // the arguments of the actor body to capture this.
    IRMapping originalToClonedOperandsMap;
    originalToClonedOperandsMap.map(actorBody.getArguments(),
                                    instanceOp.getOperands());

    // 2. Iterate through the operations in the actor body that execute during
    // initiaisation and clone them to the new instance above the
    // CreateInstanceOp.
    beginIt = actorBody.op_begin();
    endIt = actorBody.op_end();
    bool variableHoisted = false;

    for (auto it = beginIt; it != endIt; ++it) {
      Operation &op = *it; // reference to the operation
      if (!mlir::isa<cal::ExecutionBody>(op)) {
        variableHoisted = true;

        // 2.1 Clone the operation and replace the operands of the cloned
        // operation if they are in the map
        Operation *clonedOp = rewriter.clone(op, originalToClonedOperandsMap);

        // 2.2 These operands now need to be passed into
        // the actor as operands. We add them to the list of operands here.
        for (size_t i = 0; i < op.getResults().size(); i++) {
          Value resultDst = clonedOp->getResult(i);

          // Remember that we do not pass ConstantOps as parameters to the
          // CreateInstanceOp.
          if (!op.hasTrait<mlir::OpTrait::ConstantLike>())
            operands.push_back(resultDst);
        }
      }
    }

    if (variableHoisted) {
      // 3. Now all these results from the cloned operations need to be passed
      // as operands to the CreateInstanceOp. We create a new CreateInstanceOp
      // with the same attributes as the original CreateInstanceOp but with the
      // operands list extended with the new operands from the cloned
      // operations.
      auto newOp = rewriter.create<cal::CreateInstanceOp>(
          instanceOp.getLoc(), instanceOp->getResultTypes(), operands,
          instanceOp->getAttrs());
      rewriter.replaceOp(instanceOp, newOp);
      return success();
    }
    return failure();
  }
};

class HoistCalStateOutOfActorPass
    : public impl::HoistCalStateOutOfActorBase<HoistCalStateOutOfActorPass> {
public:
  void runOnOperation() final {
    RewritePatternSet patterns(&getContext());

    patterns.add<MoveInitOperationsToArguments>(&getContext());
    patterns.add<AddStateAboveCreateInstance>(&getContext());

    if (failed(applyPatternsGreedily(getOperation(), std::move(patterns)))) {
      signalPassFailure();
    }
  }
};

} // namespace mlir::cal

/// Creates a pass to hoist cal.state operations out of actor bodies.
std::unique_ptr<mlir::Pass> mlir::cal::hoistCalStateOutOfActor() {
  return std::make_unique<mlir::cal::HoistCalStateOutOfActorPass>();
}