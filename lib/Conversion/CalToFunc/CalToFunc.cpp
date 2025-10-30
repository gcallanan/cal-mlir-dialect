#include "mlir/Pass/Pass.h"
#include "Conversion/Passes.h"
//===- CalPasses.cpp - Cal passes -----------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#include "Dialect/Cal/CalOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Func/Transforms/FuncConversions.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Transforms/DialectConversion.h"

#include "Conversion/CalToFunc/CalToFunc.h"

namespace mlir {
#define GEN_PASS_DEF_CONVERTCALTOFUNC
#include "Conversion/Passes.h.inc"

/// Converts a `cal.network` operation into a top-level `func.func @main`
/// function.
///
/// In the CAL dialect, `cal.network` defines the top-level structure of the
/// actor-based computation, including actor instances, FIFO channels, and
/// initial constants. This transformation lowers the network into an executable
/// main function as follows:
///
/// - All top-level constant values are lowered to standard `arith.constant`
/// operations.
/// - FIFO channels created with `fifo.create` are preserved as-is, with
/// appropriate result SSA values.
/// - `fifo.print` operations are lowered directly to their runtime equivalents.
/// - Each `cal.create_instance` is replaced with a call to a function
/// representing the actor,
///   preserving operand and port associations. These calls are wrapped in an
///   `scf.while` loop, simulating the actor network's scheduling by re-invoking
///   the actor functions in each iteration. The boolean return flag from each
///   call indicates whether an action was successfully fired. These flags are
///   `OR`ed together to determine whether to continue the loop.
///
/// The loop continues as long as at least one actor reports progress,
/// effectively emulating a cooperative actor scheduler at runtime. Example
/// Input: cal.network {
///   %0 = arith.constant 11 : i32
///   %1 = arith.constant 12 : i32
///
///   %in0, %out0 = fifo.create<i32>(3) : !fifo.input_port<i32>,
///   !fifo.output_port<i32> %in1, %out1 = fifo.create<i32>(3) :
///   !fifo.input_port<i32>, !fifo.output_port<i32>
///
///   fifo.print("start\n\00")
///
///   cal.create_instance @src "srcA" (%0: i32)
///       ports_out(%in0 : !fifo.input_port<i32>)
///
///   cal.create_instance @src "srcB" (%1: i32)
///       ports_out(%in1 : !fifo.input_port<i32>)
/// }
///
/// Example Output:
/// func.func @main() {
///   %true = arith.constant true
///   %c11_i32 = arith.constant 11 : i32
///   %c12_i32 = arith.constant 12 : i32
///
///   %inputPort, %outputPort = fifo.create<i32>(3) : !fifo.input_port<i32>,
///   !fifo.output_port<i32> %inputPort_0, %outputPort_1 = fifo.create<i32>(3) :
///   !fifo.input_port<i32>, !fifo.output_port<i32>
///
///   fifo.print("start\0A\00")
///
///   scf.while (%arg0 = %true) : (i1) -> () {
///     scf.condition(%arg0)
///   } do {
///     %0 = func.call @src(%c11_i32, %inputPort) {from_create_instance} : (i32,
///     !fifo.input_port<i32>) -> i1 %1 = func.call @src(%c12_i32, %inputPort_0)
///     {from_create_instance} : (i32, !fifo.input_port<i32>) -> i1 %2 =
///     arith.ori %1, %0 : i1 scf.yield %2 : i1
///   }
///   return
/// }
struct ConvertCalNetworkToMainFunc : public OpRewritePattern<cal::NetworkOp> {
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(cal::NetworkOp op,
                                PatternRewriter &rewriter) const override {

    mlir::Location loc = op.getLoc();
    Region &netRegion = op.getBody();
    if (netRegion.empty()) {
      // If network has no body, create an empty main.
      auto functionType = rewriter.getFunctionType({}, {});
      auto function = rewriter.create<func::FuncOp>(loc, "main", functionType);
      Block *entryBlock = function.addEntryBlock();
      rewriter.setInsertionPointToStart(entryBlock);
      rewriter.create<func::ReturnOp>(function.getLoc());
      rewriter.replaceOp(op, function);
      return success();
    }

    Block &networkBody = netRegion.front();

  // Create the main function that mirrors the network region's arguments,
  // and returns i32 (0) to satisfy drivers expecting a conventional exit code.
  SmallVector<Type, 8> argTypes(networkBody.getArgumentTypes().begin(),
                  networkBody.getArgumentTypes().end());
  auto i32Ty = rewriter.getI32Type();
  auto functionType = rewriter.getFunctionType(argTypes, {i32Ty});
  auto function = rewriter.create<func::FuncOp>(loc, "main", functionType);
    Block *entryBlock = function.addEntryBlock();
    rewriter.setInsertionPointToStart(entryBlock);

    // Ensure the network op has a body with at least one block.
    // If not, create an empty main function.
    // (Handled above.)

    // Prepare a mapping from network region block arguments and cloned values
    // to function arguments and their clones.
    IRMapping netToFuncMap;
    netToFuncMap.map(networkBody.getArguments(), function.getArguments());

    // 1) Clone one-time ops (everything except the create_instance-derived
    // calls) into the entry block, recording result mappings so that later
    // clones in the loop body can reference them correctly.
    for (Operation &innerOp : llvm::make_early_inc_range(networkBody)) {
      if (auto callOp = dyn_cast<func::CallOp>(&innerOp)) {
        if (callOp->hasAttr("from_create_instance")) {
          // Defer calls created from create_instance to the while body.
          continue;
        }
      }
      Operation *cloned = rewriter.clone(innerOp, netToFuncMap);
      // Map results for downstream clones (e.g., loop body) to resolve uses.
      for (auto [origRes, newRes] : llvm::zip(innerOp.getResults(), cloned->getResults()))
        netToFuncMap.map(origRes, newRes);
    }

  // 2. Here we create a while loop that will execute all actors in a round
  // robin fashion until none of them performs any action.
    auto trueVal = rewriter.create<mlir::arith::ConstantOp>(
        loc, rewriter.getBoolAttr(true));

  // 2.1 Create the while loop with a single loop-carried i1 argument that
  // tracks whether progress was made in the previous iteration. The while
  // returns an i1 as well (unused), to satisfy the type invariants.
  SmallVector<Type, 1> carriedTypesVec{rewriter.getI1Type()};
  TypeRange carriedTypes(carriedTypesVec);
  auto whileOp = rewriter.create<mlir::scf::WhileOp>(loc, carriedTypes,
                                                     ValueRange{trueVal});

  // 2.2 Create the condition check block. It must accept the loop-carried
  // arguments and return the next iteration's carried values via
  // scf.condition.
  SmallVector<Location, 1> argLocs{loc};
  Block *condBlock =
    rewriter.createBlock(&whileOp.getBefore(), {}, carriedTypes, argLocs);
  rewriter.setInsertionPointToStart(condBlock);
  Value argToCheck = condBlock->getArgument(0);
  // Propagate the carried value to the condition (continue while true) and
  // forward the same carried values to the body region.
  rewriter.create<mlir::scf::ConditionOp>(loc, argToCheck, ValueRange{argToCheck});

  // 2.3 Now we can create the body of the while loop, which will contain the
  // logic to execute all actors. This block will be executed repeatedly
  // until no actor performs any action.
  Block *bodyBlockPtr =
    rewriter.createBlock(&whileOp.getAfter(), {}, carriedTypes, argLocs);
  Block &bodyBlock = *bodyBlockPtr;
    rewriter.setInsertionPointToStart(&bodyBlock);

    auto constFalse = rewriter.create<mlir::arith::ConstantOp>(
        loc, rewriter.getBoolAttr(false));
    Value actionPerformedFlag = constFalse.getResult();
    // Execute each actor at least once per outer iteration, and if marked
    // non-preemptive (or default enabled), drain it by repeatedly calling
    // while the last call fired. The outer progress flag is the OR of the
    // first-call results across all actors.
    for (Operation &innerOp : networkBody) {
      auto call = dyn_cast<func::CallOp>(&innerOp);
      if (!call)
        continue;
      if (!call->hasAttr("from_create_instance"))
        continue;

      // Always single-step once to seed progress and (for draining) the loop.
      Operation *firstStep = rewriter.clone(*call, netToFuncMap);
      Value firstResult = nullptr;
      if (auto firstOp = dyn_cast<func::CallOp>(firstStep)) {
        if (firstOp.getNumResults() == 1 &&
            firstOp.getResult(0).getType().isInteger(1))
          firstResult = firstOp.getResult(0);
      }
      if (firstResult) {
        auto newProgress = rewriter.create<mlir::arith::OrIOp>(
            loc, firstResult, actionPerformedFlag);
        actionPerformedFlag = newProgress.getResult();
      }

      // If this actor should be drained, keep invoking while the last call fired.
      bool drainByDefault = false;
      if (call->hasAttr("cal.non_preemptive"))
        drainByDefault = true;
      // If no attribute present, we conservatively keep drainByDefault=false here
      // because this custom pattern doesn't have access to the pass option. The
      // main pass below handles the global default. This avoids creating an
      // infinite loop when firstResult is false.
      if (drainByDefault && firstResult) {
        SmallVector<Type, 1> carried{rewriter.getI1Type()};
        auto drainWhile = rewriter.create<mlir::scf::WhileOp>(loc, TypeRange{carried},
                                                              ValueRange{firstResult});
        // Condition: continue while last call fired (carried is true).
        Block *drainCond = rewriter.createBlock(&drainWhile.getBefore(), {}, carried,
                                                SmallVector<Location, 1>{loc});
        rewriter.setInsertionPointToStart(drainCond);
        Value cont = drainCond->getArgument(0);
        rewriter.create<mlir::scf::ConditionOp>(loc, cont, ValueRange{cont});

        // Body: invoke once; yield its result to drive the next iteration.
        Block *drainBody = rewriter.createBlock(&drainWhile.getAfter(), {}, carried,
                                                SmallVector<Location, 1>{loc});
        rewriter.setInsertionPointToStart(drainBody);
        Operation *iterCall = rewriter.clone(*call, netToFuncMap);
        if (auto iterCallOp = dyn_cast<func::CallOp>(iterCall)) {
          if (iterCallOp.getNumResults() == 1 &&
              iterCallOp.getResult(0).getType().isInteger(1)) {
            rewriter.create<mlir::scf::YieldOp>(loc, ValueRange{iterCallOp.getResult(0)});
          } else {
            auto drainFalse = rewriter.create<mlir::arith::ConstantOp>(
                loc, rewriter.getBoolAttr(false));
            rewriter.create<mlir::scf::YieldOp>(loc, ValueRange{drainFalse.getResult()});
          }
        } else {
          auto drainFalse = rewriter.create<mlir::arith::ConstantOp>(
              loc, rewriter.getBoolAttr(false));
          rewriter.create<mlir::scf::YieldOp>(loc, ValueRange{drainFalse.getResult()});
        }
        // No need to modify outer progress here; it's already updated from firstResult.
        rewriter.setInsertionPointAfter(drainWhile);
      }
    }

  // Yield the progress flag as the next iteration's loop-carried value.
  rewriter.create<scf::YieldOp>(loc, ValueRange{actionPerformedFlag});

  // 3. Finally, we add the return operation to the main function (return 0).
  rewriter.setInsertionPointToEnd(entryBlock);
  auto c0 = rewriter.create<mlir::arith::ConstantIntOp>(loc, 0, 32);
  rewriter.create<func::ReturnOp>(function.getLoc(), ValueRange{c0.getResult()});

    rewriter.replaceOp(op, function);

    return success();
  }
};

/// Converts a `cal.actor` operation into a standard `func.func`. In this
/// conversion, the actor's execution body is lowered to the function body, and
/// all inputs (including state variables and ports) are passed as function
/// arguments.
///
/// The result of the `cal.action_done` is returned from the function as an
/// `i1`, preserving the actor's indication of whether an action fired (`true`)
/// or not (`false`).
///
/// Note: This conversion assumes that any state variable initializations have
/// already been hoisted out of the actor via the `hoistCalStateOutOfActor`
/// pass, so the actor contains only execution logic.
///
/// Example:
/// Input:
/// cal.actor @src(%max_tokens_to_send: i32)
///     ports_out(%out0: !fifo.input_port<i32>)
/// {
///     cal.execution_body {
///         fifo.print("Hi\0A\00")
///         %true = arith.constant 1 : i1
///         cal.action_done %true : i1
///     }
/// }
///
/// Output:
/// func.func @src(%arg0: i32, %arg1: !fifo.input_port<i32>) -> i1 {
///     %true = arith.constant true
///     fifo.print("Hi\0A\00")
///     return %true : i1
/// }
class ConvertCalActorToFunc : public OpRewritePattern<cal::ActorOp> {
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(cal::ActorOp op,
                                PatternRewriter &rewriter) const override {
    mlir::Location loc = op.getLoc();

    mlir::Region &actorBody = op.getBody();

    // 1. Generate the function signature for the actor.
    auto i1ReturnType = rewriter.getIntegerType(1);
    auto argumentTypes = actorBody.getArgumentTypes();
    auto functionType = rewriter.getFunctionType(argumentTypes, {i1ReturnType});
    auto function =
        rewriter.create<func::FuncOp>(loc, op.getSymName(), functionType);

    // 2. Create and populate the entry block of the function.
    Block *entryBlock = function.addEntryBlock();

    rewriter.setInsertionPointToStart(entryBlock);

    // 2.1 We need to map the original actor body arguments to the
    // function arguments. This is necessary to ensure that the cloned
    // operations in the actor body can refer to the correct function arguments.
    IRMapping originalToClonedOperandsMap;
    originalToClonedOperandsMap.map(actorBody.getArguments(),
                                    function.getBody().getArguments());

    // 2.2 Iterate through the operations in the actor body and clone them
    // into the function body, using the mapping created above.
    auto beginIt = actorBody.op_begin();
    auto endIt = actorBody.op_end();
    bool hasExecutionBody = false;
    for (auto it = beginIt; it != endIt; ++it) {
      Operation &opToClone = *it; // reference to the operation

      // Clone non-execution-body ops directly into the function and record
      // result mappings so later clones can reference them.
      if (!mlir::isa<cal::ExecutionBody>(opToClone)) {
        Operation *cloned = rewriter.clone(opToClone, originalToClonedOperandsMap);
        for (auto [origRes, newRes] : llvm::zip(opToClone.getResults(), cloned->getResults()))
          originalToClonedOperandsMap.map(origRes, newRes);
        continue;
      }

      hasExecutionBody = true;
      // Inline the execution body region into the function entry block.
      auto execBodyOp = mlir::cast<cal::ExecutionBody>(opToClone);
      auto beginExecBodyIt = execBodyOp.getBody().op_begin();
      auto endExecBodyIt = execBodyOp.getBody().op_end();
      for (auto itExecBody = beginExecBodyIt; itExecBody != endExecBodyIt;
           ++itExecBody) {
        Operation &innerOp = *itExecBody;
        // Convert cal.action_done directly to func.return to avoid relying on
        // a separate pattern ordering during greedy application.
        if (auto done = dyn_cast<cal::ActionDoneOp>(&innerOp)) {
          Value ret = originalToClonedOperandsMap.lookupOrDefault(done.getHasExecuted());
          rewriter.create<func::ReturnOp>(done.getLoc(), ret);
          continue;
        }
        Operation *clonedInner = rewriter.clone(innerOp, originalToClonedOperandsMap);
        for (auto [origRes, newRes] : llvm::zip(innerOp.getResults(), clonedInner->getResults()))
          originalToClonedOperandsMap.map(origRes, newRes);
      }
    }

    // 3.3 If there is no execution body, we need to create a terminator for the
    // function
    if (!hasExecutionBody) {
      auto falseVal = rewriter.create<mlir::arith::ConstantOp>(
          loc, rewriter.getBoolAttr(false));
      rewriter.create<func::ReturnOp>(loc, falseVal.getResult());
    }

    rewriter.replaceOp(op, function);

    return success();
  }
}; // namespace mlir

/// Converts a `cal.action_done` terminator into a `func.return` terminator.
///
/// In the CAL dialect, `cal.action_done` marks the completion of an action and
/// must return a single boolean value. This flag indicates whether the action
/// successfully fired (`true`) or not (`false`). When lowering CAL actors to
/// standard MLIR functions, this operation is translated into a `func.return`,
/// returning the flag from the function.
///
/// Example:
///   Input:
///     %true = arith.constant 1 : i1
///     cal.action_done %true : i1
///
///   Output:
///     %true = arith.constant 1 : i1
///     return %true : i1
class ConvertCalTerminatorToFuncTerminator
    : public OpRewritePattern<cal::ActionDoneOp> {
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(cal::ActionDoneOp op,
                                PatternRewriter &rewriter) const override {
    auto funcTerminator =
        rewriter.create<func::ReturnOp>(op.getLoc(), op.getOperand());
    rewriter.replaceOp(op, funcTerminator);

    return success();
  }
};

/// Converts a `cal.create_instance` operation into a direct `func.call`.
///
/// A `cal.create_instance` op is used in CAL to create an instance
/// of an actor function, passing initial arguments and port bindings. This
/// conversion lowers it to a simple `func.call` to the actor function.
///
/// Example:
///   Input:
///     cal.create_instance @src "srcA" (%0: i32)
///         ports_out(%in0 : !fifo.input_port<i32>)
///
///   Output:
///     %0 = func.call @src(%c11_i32, %inputPort) {from_create_instance}
///           : (i32, !fifo.input_port<i32>) -> i1
///
/// This transformation preserves the original argument ordering and annotations
/// any generated call with the `{from_create_instance}` attribute to trace
/// provenance during further lowering or analysis.
///
/// Note: Port direction (`ports_out`, `ports_in`, etc.) is flattened here and
/// all port values are passed directly to the function call.
class ConvertCalCreateInstanceToFuncCall
    : public OpRewritePattern<cal::CreateInstanceOp> {
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(cal::CreateInstanceOp op,
                                PatternRewriter &rewriter) const override {
    Type i1ReturnType = rewriter.getI1Type();
    SmallVector<Type, 1> resultTypes{i1ReturnType};

    auto funcCall = rewriter.create<func::CallOp>(
        op.getLoc(), op.getActorRef(), resultTypes, op.getOperands());

    funcCall->setAttr("from_create_instance", rewriter.getUnitAttr());

    // Propagate non-preemptive scheduling hint from the actor definition, if any,
    // onto the call so network lowering can decide whether to drain this actor.
    if (auto actorOp = op.getActor()) {
      if (actorOp->hasAttr("nonPreemptive")) {
        funcCall->setAttr("cal.non_preemptive", rewriter.getUnitAttr());
      }
    }

    rewriter.eraseOp(op);
    return success();
  }
};

/// This pass defines the `ConvertCalToFuncPass`, which lowers the CAL dialect
/// to the Func dialect to enable further lowering to LLVM.
///
/// Specifically, this pass performs the following rewrites:
///   - `cal.actor` ops are converted to `func.func` functions. The actor's
///     state and initialization logic are encoded as function arguments and
///     instructions within the function body.
///   - `cal.create_instance` ops are replaced with `func.call` ops, invoking
///     the corresponding actor function. An attribute is added to mark these
///     calls as originating from actor instantiation.
///   - `cal.action_done` ops are converted to `func.return` ops, returning a
///     boolean flag that indicates whether the actor performed any action.
///   - The top-level `cal.network` op is rewritten into a `func.func` named
///     "main". This function executes any one-time initialization logic and
///     contains a `scf.while` loop that invokes each actor in a round-robin
///     fashion until no actor reports progress.
///
/// The rewrite patterns are applied greedily. While the ordering of patterns
/// is not strictly enforced, the `ConvertCalNetworkToMainFunc` pattern is
/// assigned the lowest benefit to suggest it should be applied last, after all
/// actors and terminators have been lowered.
///
/// This pass enables the transformation of a CAL program into a purely
/// `func`-based representation, which is directly compatible with downstream
/// LLVM-based code generation.
class ConvertCalToFuncPass
    : public impl::ConvertCalToFuncBase<ConvertCalToFuncPass> {
public:
  ConvertCalToFuncPass() = default;
  explicit ConvertCalToFuncPass(bool nonPreemptiveDefault) {
    this->non_preemptive_default = nonPreemptiveDefault;
  }

  void runOnOperation() final {
    Operation *module = getOperation();

    // 1) Early validation: no legacy cal.action allowed.
    bool hasUnsupportedActions = false;
    module->walk([&](cal::ActorOp actor) {
      for (Block &block : actor.getBody()) {
        for (Operation &op : block) {
          if (isa<cal::ActionOp>(op)) {
            actor.emitError("cal.actor contains cal.action - cannot convert to "
                            "func dialect. Only actors with cal.execution_body "
                            "are valid in this pass");
            hasUnsupportedActions = true;
            return WalkResult::interrupt();
          }
        }
      }
      return WalkResult::advance();
    });
    if (hasUnsupportedActions) {
      signalPassFailure();
      return;
    }

    // Helper lambda to lower a single actor op to a func.func.
    auto lowerActor = [&](cal::ActorOp op) -> LogicalResult {
      mlir::Location loc = op.getLoc();
      mlir::Region &actorBody = op.getBody();

      // Signature: same args as actor body, return i1.
      auto i1ReturnType = IntegerType::get(&getContext(), 1);
      auto argumentTypes = actorBody.getArgumentTypes();
      auto functionType = FunctionType::get(&getContext(), argumentTypes,
                                            TypeRange{i1ReturnType});

      IRRewriter rewriter(&getContext());
      rewriter.setInsertionPoint(op);
      auto function = rewriter.create<func::FuncOp>(loc, op.getSymName(), functionType);
      Block *entryBlock = function.addEntryBlock();
      rewriter.setInsertionPointToStart(entryBlock);

      // Map block args and clone operations. Inline execution_body content.
      IRMapping map;
      map.map(actorBody.getArguments(), function.getBody().getArguments());

      bool hasExecutionBody = false;
      for (Operation &topLevelOp : actorBody.front()) {
        if (!isa<cal::ExecutionBody>(topLevelOp)) {
          Operation *cloned = rewriter.clone(topLevelOp, map);
          for (auto [orig, neu] : llvm::zip(topLevelOp.getResults(), cloned->getResults()))
            map.map(orig, neu);
          continue;
        }

        hasExecutionBody = true;
        auto exec = cast<cal::ExecutionBody>(topLevelOp);
        for (Operation &inner : exec.getBody().front()) {
          if (auto done = dyn_cast<cal::ActionDoneOp>(&inner)) {
            Value ret = map.lookup(done.getHasExecuted());
            rewriter.create<func::ReturnOp>(done.getLoc(), ret);
            continue;
          }
          Operation *clonedInner = rewriter.clone(inner, map);
          for (auto [orig, neu] : llvm::zip(inner.getResults(), clonedInner->getResults()))
            map.map(orig, neu);
        }
      }

      if (!hasExecutionBody) {
        auto falseVal = rewriter.create<arith::ConstantOp>(loc, rewriter.getBoolAttr(false));
        rewriter.create<func::ReturnOp>(loc, falseVal.getResult());
      }

      // Copy the nonPreemptive attribute from actor to function if it exists
      if (op->hasAttr("nonPreemptive")) {
        function->setAttr("nonPreemptive", rewriter.getUnitAttr());
      }

      rewriter.replaceOp(op, function);
      return success();
    };

    // 2) Lower all actors to functions.
    {
      SmallVector<cal::ActorOp, 8> actors;
      module->walk([&](cal::ActorOp actor) { actors.push_back(actor); });
      for (cal::ActorOp actor : actors) {
        if (failed(lowerActor(actor))) {
          signalPassFailure();
          return;
        }
      }
    }

    // 3) Lower all create_instance ops to func.call ops.
    {
      IRRewriter rewriter(&getContext());
      SmallVector<cal::CreateInstanceOp, 8> instances;
      module->walk([&](cal::CreateInstanceOp inst) { instances.push_back(inst); });
      for (cal::CreateInstanceOp inst : instances) {
        rewriter.setInsertionPoint(inst);
        auto i1Ty = rewriter.getI1Type();
        SmallVector<Type, 1> resultTypes{i1Ty};
        auto call = rewriter.create<func::CallOp>(inst.getLoc(), inst.getActorRef(),
                                                  resultTypes, inst.getOperands());
        call->setAttr("from_create_instance", rewriter.getUnitAttr());

        // Copy per-actor non-preemptive scheduling hint onto the call.
        // Note: We look up by symbol name since the actor may have been converted to a function
        SymbolTableCollection symbolTable;
        auto funcOp = symbolTable.lookupNearestSymbolFrom<func::FuncOp>(inst, inst.getActorRefAttr());
        if (funcOp && funcOp->hasAttr("nonPreemptive")) {
          call->setAttr("cal.non_preemptive", rewriter.getUnitAttr());
        }
        rewriter.eraseOp(inst);
      }
    }

    // 4) Lower each network to a main-like func with a cooperative loop.
    {
      IRRewriter rewriter(&getContext());
      SmallVector<cal::NetworkOp, 4> networks;
      module->walk([&](cal::NetworkOp net) { networks.push_back(net); });
      for (cal::NetworkOp net : networks) {
        Location loc = net.getLoc();
        Region &netRegion = net.getBody();
        if (netRegion.empty()) {
          rewriter.setInsertionPoint(net);
          auto i32Ty = rewriter.getI32Type();
          auto fnTy = rewriter.getFunctionType({}, {i32Ty});
          auto fn = rewriter.create<func::FuncOp>(loc, "main", fnTy);
          Block *entry = fn.addEntryBlock();
          rewriter.setInsertionPointToStart(entry);
          auto c0 = rewriter.create<arith::ConstantIntOp>(loc, 0, 32);
          rewriter.create<func::ReturnOp>(loc, ValueRange{c0.getResult()});
          rewriter.replaceOp(net, fn);
          continue;
        }

        Block &networkBody = netRegion.front();
        SmallVector<Type, 8> argTypes(networkBody.getArgumentTypes().begin(),
                                      networkBody.getArgumentTypes().end());
        rewriter.setInsertionPoint(net);
  auto i32Ty2 = rewriter.getI32Type();
  auto fnTy = rewriter.getFunctionType(argTypes, {i32Ty2});
        auto fn = rewriter.create<func::FuncOp>(loc, "main", fnTy);
        Block *entry = fn.addEntryBlock();
        rewriter.setInsertionPointToStart(entry);

        IRMapping map;
        map.map(networkBody.getArguments(), fn.getArguments());

        // Clone one-time ops into entry, skip calls from create_instance.
        for (Operation &inner : llvm::make_early_inc_range(networkBody)) {
          if (auto call = dyn_cast<func::CallOp>(&inner)) {
            if (call->hasAttr("from_create_instance"))
              continue;
          }
          Operation *cloned = rewriter.clone(inner, map);
          for (auto [orig, neu] : llvm::zip(inner.getResults(), cloned->getResults()))
            map.map(orig, neu);
        }

        // Build while loop skeleton with i1 carried flag.
        auto trueVal = rewriter.create<arith::ConstantOp>(loc, rewriter.getBoolAttr(true));
        SmallVector<Type, 1> carriedTypes{rewriter.getI1Type()};
        auto whileOp = rewriter.create<scf::WhileOp>(loc, TypeRange{carriedTypes},
                                                     ValueRange{trueVal});

        // Condition block: continue while carried flag true.
        Block *cond = rewriter.createBlock(&whileOp.getBefore(), {}, carriedTypes, SmallVector<Location, 1>{loc});
        rewriter.setInsertionPointToStart(cond);
        Value condArg = cond->getArgument(0);
        rewriter.create<scf::ConditionOp>(loc, condArg, ValueRange{condArg});

        // Body block: call actor functions and OR their results.
        Block *body = rewriter.createBlock(&whileOp.getAfter(), {}, carriedTypes, SmallVector<Location, 1>{loc});
        rewriter.setInsertionPointToStart(body);
        auto falseVal = rewriter.create<arith::ConstantOp>(loc, rewriter.getBoolAttr(false));
        Value progress = falseVal.getResult();
        for (Operation &inner : networkBody) {
          auto call = dyn_cast<func::CallOp>(&inner);
          if (!call)
            continue;
          if (!call->hasAttr("from_create_instance"))
            continue;

          // Always single-step once per outer iteration to seed both
          // progress computation and (for draining) the inner loop.
          Operation *firstStep = rewriter.clone(*call, map);
          Value firstResult = nullptr;
          if (auto firstOp = dyn_cast<func::CallOp>(firstStep)) {
            if (firstOp.getNumResults() == 1 &&
                firstOp.getResult(0).getType().isInteger(1))
              firstResult = firstOp.getResult(0);
          }
          if (firstResult) {
            auto newProg = rewriter.create<arith::OrIOp>(loc, firstResult, progress);
            progress = newProg.getResult();
          }

          // If marked non-preemptive or globally enabled, keep invoking while last call fired.
          bool drainByDefault = this->non_preemptive_default;
          if (call->hasAttr("cal.non_preemptive") || drainByDefault) {
            if (firstResult) {
              SmallVector<Type, 1> drainCarried{rewriter.getI1Type()};
              auto drainWhile = rewriter.create<scf::WhileOp>(loc, TypeRange{drainCarried}, ValueRange{firstResult});

              // Condition region: continue while carried flag is true.
              Block *drainCond = rewriter.createBlock(&drainWhile.getBefore(), {}, drainCarried, SmallVector<Location, 1>{loc});
              rewriter.setInsertionPointToStart(drainCond);
              Value drainArg = drainCond->getArgument(0);
              rewriter.create<scf::ConditionOp>(loc, drainArg, ValueRange{drainArg});

              // Body region: call actor once; yield result as next condition (continue if fired).
              Block *drainBody = rewriter.createBlock(&drainWhile.getAfter(), {}, drainCarried, SmallVector<Location, 1>{loc});
              rewriter.setInsertionPointToStart(drainBody);
              Operation *drainCall = rewriter.clone(*call, map);
              if (auto drainCallOp = dyn_cast<func::CallOp>(drainCall)) {
                if (drainCallOp.getNumResults() == 1 && drainCallOp.getResult(0).getType().isInteger(1)) {
                  Value fired = drainCallOp.getResult(0);
                  rewriter.create<scf::YieldOp>(loc, ValueRange{fired});
                } else {
                  auto drainFalse = rewriter.create<arith::ConstantOp>(loc, rewriter.getBoolAttr(false));
                  rewriter.create<scf::YieldOp>(loc, ValueRange{drainFalse.getResult()});
                }
              } else {
                auto drainFalse = rewriter.create<arith::ConstantOp>(loc, rewriter.getBoolAttr(false));
                rewriter.create<scf::YieldOp>(loc, ValueRange{drainFalse.getResult()});
              }
              // No need to adjust `progress` here; it already accounts for firstResult.
              rewriter.setInsertionPointAfter(drainWhile);
            }
          }
        }
        rewriter.create<scf::YieldOp>(loc, ValueRange{progress});

  // Return from main (0).
  rewriter.setInsertionPointToEnd(entry);
  auto c0b = rewriter.create<arith::ConstantIntOp>(loc, 0, 32);
  rewriter.create<func::ReturnOp>(loc, ValueRange{c0b.getResult()});

        rewriter.replaceOp(net, fn);
      }
    }
  }
};

} // namespace mlir

/// Creates a pass to lower cal.network and cal.actor ops into functions and
/// function calls.
std::unique_ptr<mlir::Pass> mlir::createConvertCalToFuncPass() {
  return std::make_unique<mlir::ConvertCalToFuncPass>();
}

std::unique_ptr<mlir::Pass> mlir::createConvertCalToFuncPass(bool nonPreemptiveDefault) {
  return std::make_unique<mlir::ConvertCalToFuncPass>(nonPreemptiveDefault);
}