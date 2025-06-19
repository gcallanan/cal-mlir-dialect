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

#include "Conversion/CalToFunc/CalToFunc.h"
#include "Conversion/Passes.h"

namespace mlir {
#define GEN_PASS_DEF_CONVERTCALTOFUNCWITHSTATICSCHEDULE
#include "Conversion/Passes.h.inc"

struct PredicateInfo {
  mlir::arith::CmpIPredicate predicate;
  mlir::Value stateVar;
  int64_t constant;
};

// Optional: Forward declare operator<<
llvm::raw_ostream &operator<<(llvm::raw_ostream &, const PredicateInfo &);

inline llvm::raw_ostream &operator<<(llvm::raw_ostream &os,
                                     const PredicateInfo &info) {
  std::string ssaName;
  llvm::raw_string_ostream ss(ssaName);
  info.stateVar.printAsOperand(ss, mlir::OpPrintingFlags().useLocalScope());
  ss.flush();

  os << "PredicateInfo(" << ssaName << " ";
  switch (info.predicate) {
  case mlir::arith::CmpIPredicate::eq:
    os << "==";
    break;
  case mlir::arith::CmpIPredicate::ne:
    os << "!=";
    break;
  case mlir::arith::CmpIPredicate::slt:
    os << "<";
    break;
  case mlir::arith::CmpIPredicate::sle:
    os << "<=";
    break;
  case mlir::arith::CmpIPredicate::sgt:
    os << ">";
    break;
  case mlir::arith::CmpIPredicate::sge:
    os << ">=";
    break;
  case mlir::arith::CmpIPredicate::ult:
    os << "<";
    break;
  case mlir::arith::CmpIPredicate::ule:
    os << "<=";
    break;
  case mlir::arith::CmpIPredicate::ugt:
    os << ">";
    break;
  case mlir::arith::CmpIPredicate::uge:
    os << ">=";
    break;
  }
  os << " " << info.constant << ")\n";
  return os;
}

struct CycloStaticDataflowAnalysis {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(CycloStaticDataflowAnalysis)

private:
  llvm::DenseMap<mlir::cal::Predicate, PredicateInfo> predicateStateVariables;

public:
  CycloStaticDataflowAnalysis(Operation *op) {
    llvm::outs() << "\n\n\nCycloStaticDataflowAnalysis: Analyzing operation: "
                 << op->getName() << "\n";

    op->walk([&](mlir::cal::Predicate predicateOp) {
      if (auto predicateInfo = validPredicate(predicateOp)) {
        predicateStateVariables[predicateOp] = *predicateInfo;
      }
    });

    for (const auto &entry : predicateStateVariables) {
      auto predicateOp = entry.first;
      auto predicateInfoOpt = validPredicate(predicateOp);
      if (predicateInfoOpt) {
        const auto &info = *predicateInfoOpt;
        llvm::outs() << "Predicate: " << predicateOp << "\n" << info << "\n";
      }
    }

    // op->walk([&](mlir::cal::ActorOp actorOp) {
    //   actorOp->walk([&](mlir::cal::ActionOp actionOp) {
    //     ActionInfo info;

    //     actionOp->walk([&](Operation *opsInAction) {
    //       if (llvm::isa<fifo::Pop>(opsInAction) ||
    //           llvm::isa<fifo::Push>(opsInAction)) {
    //         if (fifo::Pop popOp = llvm::dyn_cast<fifo::Pop>(opsInAction)) {
    //           info.consumptionRates[popOp.getOutputPort()] += 1;

    //         } else if (auto pushOp = llvm::dyn_cast<fifo::Push>(opsInAction))
    //         {
    //           info.productionRates[pushOp.getInputPort()] += 1;
    //         }
    //       }
    //     });

    //     actionMap[actionOp] = std::move(info);
    //   });
    // });
  }

private:
  std::optional<int64_t> tryGetConstantValue(Value val) {
    if (auto constantOp = val.getDefiningOp<mlir::arith::ConstantOp>()) {
      if (auto intAttr = llvm::dyn_cast<IntegerAttr>(constantOp.getValue())) {
        return intAttr.getValue().getSExtValue(); // or getZExtValue() if needed
      }
    }
    return std::nullopt;
  }

  std::optional<int64_t> evaluateConstantValue(Value val) {
    if (!val)
      return std::nullopt;

    // Base case: constant
    if (auto constant = tryGetConstantValue(val))
      return constant;

    Operation *defOp = val.getDefiningOp();
    if (!defOp)
      return std::nullopt;

    if (auto extui = llvm::dyn_cast<mlir::arith::ExtUIOp>(defOp)) {
      auto inner = evaluateConstantValue(extui.getIn());
      if (!inner)
        return std::nullopt;

      unsigned targetWidth = extui.getType().cast<IntegerType>().getWidth();
      unsigned sourceWidth =
          extui.getIn().getType().cast<IntegerType>().getWidth();
      return static_cast<uint64_t>(*inner) &
             ((1ULL << sourceWidth) - 1); // Zero-extend manually
    }

    if (auto extsi = llvm::dyn_cast<mlir::arith::ExtSIOp>(defOp)) {
      auto inner = evaluateConstantValue(extsi.getIn());
      if (!inner)
        return std::nullopt;

      unsigned sourceWidth =
          extsi.getIn().getType().cast<IntegerType>().getWidth();
      int64_t mask = (1ULL << (sourceWidth - 1));
      int64_t val = *inner;
      if (val & mask)                        // negative
        val |= ~((1ULL << sourceWidth) - 1); // Sign-extend
      return val;
    }

    if (auto addOp = llvm::dyn_cast<mlir::arith::AddIOp>(defOp)) {
      auto lhs = evaluateConstantValue(addOp.getLhs());
      auto rhs = evaluateConstantValue(addOp.getRhs());
      if (lhs && rhs)
        return *lhs + *rhs;
      return std::nullopt;
    }

    if (auto subOp = llvm::dyn_cast<mlir::arith::SubIOp>(defOp)) {
      auto lhs = evaluateConstantValue(subOp.getLhs());
      auto rhs = evaluateConstantValue(subOp.getRhs());
      if (lhs && rhs)
        return *lhs - *rhs;
      return std::nullopt;
    }

    if (auto mulOp = llvm::dyn_cast<mlir::arith::MulIOp>(defOp)) {
      auto lhs = evaluateConstantValue(mulOp.getLhs());
      auto rhs = evaluateConstantValue(mulOp.getRhs());
      if (lhs && rhs)
        return *lhs * *rhs;
      return std::nullopt;
    }

    return std::nullopt;
  }

  std::optional<PredicateInfo> validPredicate(cal::Predicate predicateOp) {
    mlir::Value lhs, rhs;
    mlir::arith::CmpIPredicate pred;
    bool inValid = false;

    predicateOp->walk([&](mlir::cal::PredicateResultOp resultOp) {
      if (auto cmpOp = resultOp.getEvaluationResult()
                           .getDefiningOp<mlir::arith::CmpIOp>()) {
        lhs = cmpOp.getLhs();
        rhs = cmpOp.getRhs();
        pred = cmpOp.getPredicate();
      } else {
        inValid = true;
      }
    });

    if (inValid || !lhs || !rhs)
      return std::nullopt;

    auto *lhsOp = lhs.getDefiningOp();
    auto *rhsOp = rhs.getDefiningOp();

    bool lhsIsState = llvm::isa<mlir::cal::StateGetOp>(lhsOp);
    bool rhsIsState = llvm::isa<mlir::cal::StateGetOp>(rhsOp);

    if (lhsIsState == rhsIsState)
      return std::nullopt;

    mlir::Value stateVar =
        lhsIsState ? lhsOp->getOperand(0) : rhsOp->getOperand(0);
    mlir::Value otherVar = lhsIsState ? rhs : lhs;

    if (auto constVal = evaluateConstantValue(otherVar)) {
      return PredicateInfo{pred, stateVar, *constVal};
    }

    return std::nullopt;
  }
};

/// Converts a `cal.network` operation into a top-level `func.func @main`
/// function.
///
/// In the CAL dialect, `cal.network` defines the top-level structure of the
/// actor-based computation, including actor instances, FIFO channels, and
/// initial constants. This transformation lowers the network into an
/// executable main function as follows:
///
/// - All top-level constant values are lowered to standard `arith.constant`
/// operations.
/// - FIFO channels created with `fifo.create` are preserved as-is, with
/// appropriate result SSA values.
/// - `fifo.print` operations are lowered directly to their runtime
/// equivalents.
/// - Each `cal.create_instance` is replaced with a call to a function
/// representing the actor,
///   preserving operand and port associations. These calls are wrapped in an
///   `scf.while` loop, simulating the actor network's scheduling by
///   re-invoking the actor functions in each iteration. The boolean return
///   flag from each call indicates whether an action was successfully fired.
///   These flags are `OR`ed together to determine whether to continue the
///   loop.
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
///   !fifo.output_port<i32> %inputPort_0, %outputPort_1 = fifo.create<i32>(3)
///   : !fifo.input_port<i32>, !fifo.output_port<i32>
///
///   fifo.print("start\0A\00")
///
///   scf.while (%arg0 = %true) : (i1) -> () {
///     scf.condition(%arg0)
///   } do {
///     %0 = func.call @src(%c11_i32, %inputPort) {from_create_instance} :
///     (i32, !fifo.input_port<i32>) -> i1 %1 = func.call @src(%c12_i32,
///     %inputPort_0) {from_create_instance} : (i32, !fifo.input_port<i32>) ->
///     i1 %2 = arith.ori %1, %0 : i1 scf.yield %2 : i1
///   }
///   return
/// }
// struct ConvertCalNetworkToMainFunc : public
// OpRewritePattern<cal::NetworkOp>
// {
//   using OpRewritePattern::OpRewritePattern;

//   LogicalResult matchAndRewrite(cal::NetworkOp op,
//                                 PatternRewriter &rewriter) const override {

//     mlir::Location loc = op.getLoc();
//     Block &networkBody = op.getBody().front();

//     auto functionType = rewriter.getFunctionType({}, {});
//     auto function = rewriter.create<func::FuncOp>(loc, "main",
//     functionType); Block *entryBlock = function.addEntryBlock();

//     rewriter.setInsertionPointToStart(entryBlock);

//     // 1. Here we put all instructions that need to be executed once before
//     the
//     // while loop starts.

//     auto beginIt = networkBody.begin();
//     auto endIt = networkBody.end();

//     for (auto it = beginIt; it != endIt;) {
//       Operation &opToMove = *it; // reference to the operation
//       ++it; // increment iterator before moving the operation

//       if (auto callOp = llvm::dyn_cast<func::CallOp>(opToMove)) {
//         if (callOp->hasAttr("from_create_instance")) {
//           continue; // Skip operations that are from CreateInstance
//         }
//       }

//       if (mlir::isa<cal::CreateInstanceOp>(opToMove)) {
//         // Output an error if CreateInstanceOp is found outside expected
//         context llvm::outs() << "Error: CreateInstanceOp found outside of
//         expected "
//                         "context in NetworkOp\n";
//         op.emitError(
//             "CreateInstanceOp found outside of expected context in
//             NetworkOp");
//         return failure();
//       }

//       // llvm::outs() << "Moving operation: " << opToMove << "\n";
//       opToMove.moveBefore(entryBlock, entryBlock->end());
//     }

//     // 2. Here we create a while loop that will execute all actors in a
//     round
//     // robin fashion until none of them performs any action.
//     auto trueVal = rewriter.create<mlir::arith::ConstantOp>(
//         loc, rewriter.getBoolAttr(true));

//     // 2.1 Create the while loop (do not fill in its body/condition blocks
//     yet).
//     // This loop executes all actors in a round robin fahsion until none of
//     them
//     // performs any action.
//     auto whileOp = rewriter.create<mlir::scf::WhileOp>(loc, TypeRange{},
//                                                        ValueRange{trueVal});

//     // 2.2 Create the condition check block, basically just check that a
//     // condition representing progress was made in the previous iteration.
//     If no
//     // progress was made, the loop terminates.
//     rewriter.createBlock(&whileOp.getBefore());
//     Block &condBlock = whileOp.getBefore().front();
//     condBlock.addArgument(rewriter.getI1Type(), loc);
//     rewriter.setInsertionPointToStart(&condBlock);
//     Value argToCheck = condBlock.getArgument(0);
//     rewriter.create<mlir::scf::ConditionOp>(loc, argToCheck, ValueRange{});

//     // 2.3 Now we can create the body of the while loop, which will contain
//     the
//     // logic to execute all actors. This block will be executed repeatedly
//     // until no actor performs any action.

//     rewriter.createBlock(&whileOp.getAfter());
//     Block &bodyBlock = whileOp.getAfter().front();
//     rewriter.setInsertionPointToStart(&bodyBlock);

//     auto constFalse = rewriter.create<mlir::arith::ConstantOp>(
//         loc, rewriter.getBoolAttr(false));
//     Value actionPerformedFlag = constFalse.getResult();
//     while (!networkBody.empty()) {
//       Operation &opToMove = networkBody.front();
//       opToMove.moveBefore(&bodyBlock, bodyBlock.end());
//       Value result = opToMove.getResult(0);
//       auto newActionPerformedFlag =
//           rewriter.create<mlir::arith::OrIOp>(loc, result,
//           actionPerformedFlag);
//       actionPerformedFlag = newActionPerformedFlag.getResult();
//     }

//     rewriter.create<scf::YieldOp>(loc, ValueRange{actionPerformedFlag});

//     // 3. Finally, we add the return operation to the main function.
//     rewriter.setInsertionPointToEnd(entryBlock);
//     rewriter.create<func::ReturnOp>(function.getLoc());

//     rewriter.replaceOp(op, function);

//     return success();
//   }
// };

/// Converts a `cal.actor` operation into a standard `func.func`. In this
/// conversion, the actor's execution body is lowered to the function body,
/// and all inputs (including state variables and ports) are passed as
/// function arguments.
///
/// The result of the `cal.action_done` is returned from the function as an
/// `i1`, preserving the actor's indication of whether an action fired
/// (`true`) or not (`false`).
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
// class ConvertCalActorToFunc : public OpRewritePattern<cal::ActorOp> {
//   using OpRewritePattern::OpRewritePattern;

//   LogicalResult matchAndRewrite(cal::ActorOp op,
//                                 PatternRewriter &rewriter) const override {
//     mlir::Location loc = op.getLoc();

//     mlir::Region &actorBody = op.getBody();

//     // 1. Generate the function signature for the actor.
//     auto i1ReturnType = rewriter.getIntegerType(1);
//     auto argumentTypes = actorBody.getArgumentTypes();
//     auto functionType = rewriter.getFunctionType(argumentTypes,
//     {i1ReturnType}); auto function =
//         rewriter.create<func::FuncOp>(loc, op.getSymName(), functionType);

//     // 2. Create and populate the entry block of the function.
//     Block *entryBlock = function.addEntryBlock();

//     rewriter.setInsertionPointToStart(entryBlock);

//     // 2.1 We need to map the original actor body arguments to the
//     // function arguments. This is necessary to ensure that the cloned
//     // operations in the actor body can refer to the correct function
//     arguments. IRMapping originalToClonedOperandsMap;
//     originalToClonedOperandsMap.map(actorBody.getArguments(),
//                                     function.getBody().getArguments());

//     // 2.2 Iterate through the operations in the actor body and clone them
//     // into the function body, using the mapping created above.
//     auto beginIt = actorBody.op_begin();
//     auto endIt = actorBody.op_end();
//     for (auto it = beginIt; it != endIt; ++it) {
//       Operation &opToClone = *it; // reference to the operation

//       // Most operations can be cloned directly
//       if (!mlir::isa<cal::ExecutionBody>(opToClone)) {
//         rewriter.clone(opToClone, originalToClonedOperandsMap);
//       } else {
//         // The last operation in the body can be an ExecutionBody it
//         contains
//         // a region with the actual execution logic. We need to clone all
//         the
//         // instructions in this region into the function body. We do not
//         auto execBodyOp = mlir::cast<cal::ExecutionBody>(opToClone);
//         auto beginExecBodyIt = execBodyOp.getBody().op_begin();
//         auto endExecBodyIt = execBodyOp.getBody().op_end();
//         for (auto itExecBody = beginExecBodyIt; itExecBody !=
//         endExecBodyIt;
//              ++itExecBody) {
//           Operation &opToCloneInExecBody =
//               *itExecBody; // reference to the operation
//           rewriter.clone(opToCloneInExecBody, originalToClonedOperandsMap);
//         }
//       }
//     }

//     rewriter.replaceOp(op, function);

//     return success();
//   }
// }; // namespace mlir

/// Converts a `cal.action_done` terminator into a `func.return` terminator.
///
/// In the CAL dialect, `cal.action_done` marks the completion of an action
/// and must return a single boolean value. This flag indicates whether the
/// action successfully fired (`true`) or not (`false`). When lowering CAL
/// actors to standard MLIR functions, this operation is translated into a
/// `func.return`, returning the flag from the function.
///
/// Example:
///   Input:
///     %true = arith.constant 1 : i1
///     cal.action_done %true : i1
///
///   Output:
///     %true = arith.constant 1 : i1
///     return %true : i1
// class ConvertCalTerminatorToFuncTerminator
//     : public OpRewritePattern<cal::ActionDoneOp> {
//   using OpRewritePattern::OpRewritePattern;

//   LogicalResult matchAndRewrite(cal::ActionDoneOp op,
//                                 PatternRewriter &rewriter) const override {
//     auto funcTerminator =
//         rewriter.create<func::ReturnOp>(op.getLoc(), op.getOperand());
//     rewriter.replaceOp(op, funcTerminator);

//     return success();
//   }
// };

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
/// This transformation preserves the original argument ordering and
/// annotations any generated call with the `{from_create_instance}` attribute
/// to trace provenance during further lowering or analysis.
///
/// Note: Port direction (`ports_out`, `ports_in`, etc.) is flattened here and
/// all port values are passed directly to the function call.
// class ConvertCalCreateInstanceToFuncCall
//     : public OpRewritePattern<cal::CreateInstanceOp> {
//   using OpRewritePattern::OpRewritePattern;

//   LogicalResult matchAndRewrite(cal::CreateInstanceOp op,
//                                 PatternRewriter &rewriter) const override {
//     Type i1ReturnType = rewriter.getI1Type();
//     SmallVector<Type, 1> resultTypes{i1ReturnType};

//     auto funcCall = rewriter.create<func::CallOp>(
//         op.getLoc(), op.getActorRef(), resultTypes, op.getOperands());

//     funcCall->setAttr("from_create_instance", rewriter.getUnitAttr());

//     rewriter.eraseOp(op);
//     return success();
//   }
// };

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
/// assigned the lowest benefit to suggest it should be applied last, after
/// all actors and terminators have been lowered.
///
/// This pass enables the transformation of a CAL program into a purely
/// `func`-based representation, which is directly compatible with downstream
/// LLVM-based code generation.
class ConvertCalToFuncWithStaticSchedulePass
    : public impl::ConvertCalToFuncWithStaticScheduleBase<
          ConvertCalToFuncWithStaticSchedulePass> {
public:
  void runOnOperation() final {

    auto &csdfAnalysis = getAnalysis<CycloStaticDataflowAnalysis>();

    RewritePatternSet patterns(&getContext());
    // patterns.add<ConvertCalActorToFunc>(&getContext());
    // patterns.add<ConvertCalTerminatorToFuncTerminator>(&getContext());
    // patterns.add<ConvertCalCreateInstanceToFuncCall>(&getContext());
    // We set the benefit to 0 for the ConvertCalNetworkToMainFunc pattern
    // to ensure it is applied last, after all other patterns.
    // This is because it relies on the fact that all actors have been
    // converted to functions. I am not actually sure if this works properly,
    // changing the benefit did not change the behaviour. So we just watch
    // this space for future errors.
    // patterns.add<ConvertCalNetworkToMainFunc>(&getContext(),
    // /*benefit=*/0);

    // if (failed(applyPatternsGreedily(getOperation(), std::move(patterns))))
    // {
    //   signalPassFailure();
    // }
  }
};

} // namespace mlir

/// Creates a pass to lower cal.network and cal.actor ops into functions and
/// function calls.
std::unique_ptr<mlir::Pass>
mlir::createConvertCalToFuncWithStaticSchedulePass() {
  return std::make_unique<mlir::ConvertCalToFuncWithStaticSchedulePass>();
}