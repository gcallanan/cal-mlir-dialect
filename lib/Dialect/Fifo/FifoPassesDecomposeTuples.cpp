//===- FifoPasses.cpp - Fifo passes -----------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// NOTE from @Gareth Callanan
// This pass is copied almost exactly from:
//    llvm-project/mlir/test/lib/Conversion/OneToNTypeConversion/TestOneToNTypeConversionPass.cpp
// I needed 1:N argument conversions fo convert the fifo.input_port<> and
// fifo.output_port<> types to memref types. When I looked at it, MLIR had just
// been updated to change the way things were done and it was unclear how to
// make full use of this. Instead of trying to figure it out, I just copied to
// test and modified it.
//
// The ConvertCalActorTupleArguments pass is something I wrote with more
// experience and I am more convinced that it is correct.
//
// Disclaimer - I wrote the code myself but used ChatGPT to generate
// top level comments describing each class.
//===----------------------------------------------------------------------===//

#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoPasses.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Func/Transforms/OneToNFuncConversions.h"
#include "mlir/Dialect/Index/IR/IndexDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/Transforms/Patterns.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Rewrite/FrozenRewritePatternSet.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Transforms/OneToNTypeConversion.h"
#include <iostream>

namespace mlir::fifo {
#define GEN_PASS_DEF_DECOMPOSEFIFOTUPLES
#include "Dialect/Fifo/FifoPasses.h.inc"

class ConvertMakeTuple : public OneToNOpConversionPattern<MakeTuple> {
public:
  using OneToNOpConversionPattern<MakeTuple>::OneToNOpConversionPattern;

  LogicalResult
  matchAndRewrite(MakeTuple op, OpAdaptor adaptor,
                  OneToNPatternRewriter &rewriter) const override {
    // Simply replace the current op with the converted operands.
    rewriter.replaceOp(op, adaptor.getFlatOperands(),
                       adaptor.getResultMapping());
    return success();
  }
};

class ConvertGetTupleElement
    : public OneToNOpConversionPattern<GetTupleElement> {
  using OneToNOpConversionPattern<GetTupleElement>::OneToNOpConversionPattern;

public:
  LogicalResult
  matchAndRewrite(GetTupleElement op, OpAdaptor adaptor,
                  OneToNPatternRewriter &rewriter) const override {
    // Construct mapping for tuple element types.
    auto stateType = cast<TupleType>(op->getOperand(0).getType());
    TypeRange originalElementTypes = stateType.getTypes();
    OneToNTypeMapping elementMapping(originalElementTypes);
    if (failed(typeConverter->convertSignatureArgs(originalElementTypes,
                                                   elementMapping)))
      return failure();

    // Compute converted operands corresponding to original input tuple.
    assert(adaptor.getOperands().size() == 1 &&
           "expected 'get_tuple_element' to have one operand");
    ValueRange convertedTuple = adaptor.getOperands()[0];

    // Got those converted operands that correspond to the index-th element of
    // the original input tuple.
    size_t index = op.getIndex();
    ValueRange extractedElement =
        elementMapping.getConvertedValues(convertedTuple, index);

    rewriter.replaceOp(op, extractedElement, adaptor.getResultMapping());

    return success();
  }
};

/// Conversion pattern for `cal.actor` operations that decompose tuple-typed
/// block arguments into their individual elements.
///
///
/// The transformation proceeds as follows:
/// - **Detection**: The pattern first checks if any block arguments are of
///   `TupleType`. If none are found, the pattern does not apply.
/// - **Conversion**: For each tuple-typed argument, the `TypeConverter`
///   determines the corresponding flattened types.
/// - **Application**: The `applySignatureConversion` method is used to update
///   the block's signature, replacing tuple-typed arguments with their
///   flattened counterparts.
///
///
/// **Example Transformation**:
/// Input:
/// ```
/// cal.actor @my_actor3(%arg0: i32, %arg1: i32,
///     %arg2: tuple<memref<?xi32>, memref<2xi32>, i32>)
/// {
/// }
/// ```
///
/// Output:
/// ```
/// cal.actor @my_actor3(%arg0: i32, %arg1: i32,
///     %arg2: memref<?xi32>, %arg3: memref<2xi32>, %arg4: i32)
/// {
/// }
/// ```
///
/// Based on  "class ConvertTypesInSCFForOp" conversion pattern in
/// "llvm-project/mlir/lib/Dialect/SCF/Transforms/OneToNTypeConversion.cpp"
class ConvertCalActorTupleArguments : public OneToNConversionPattern {
public:
  ConvertCalActorTupleArguments(const TypeConverter &converter,
                                MLIRContext *ctx)
      : OneToNConversionPattern(converter, "cal.actor", /*benefit=*/1, ctx) {}

  LogicalResult matchAndRewrite(Operation *op, OneToNPatternRewriter &rewriter,
                                const OneToNTypeMapping &operandMapping,
                                const OneToNTypeMapping &resultMapping,
                                ValueRange convertedOperands) const override {

    cal::ActorOp actorOp = cast<cal::ActorOp>(op);
    Location loc = op->getLoc();
    Region *region = &actorOp.getBody();
    Block *block = &region->front();

    // 1. Check termination condition
    // We need a termination condition or else the fixed point computation will
    // never terminate. We do this by checking if the block has any tuple types
    // in its arguments. If it does, we can convert the block signature.
    // If it doesn't, we can skip the conversion.
    bool hasTupleTypes = false;
    for (auto arg : block->getArguments()) {
      if (mlir::isa<TupleType>(arg.getType())) {
        hasTupleTypes = true;
        break;
      }
    }

    if (!hasTupleTypes) {
      return failure();
    }

    // 2. Convert the signature of the body region.
    OneToNTypeMapping bodyTypeMapping(block->getArgumentTypes());
    if (failed(typeConverter->convertSignatureArgs(block->getArgumentTypes(),
                                                   bodyTypeMapping)))
      return failure();
    rewriter.applySignatureConversion(block, bodyTypeMapping);

    return success();
  }
};

class DecomposeFifoTuplesPass
    : public impl::DecomposeFifoTuplesBase<DecomposeFifoTuplesPass> {
public:
  void runOnOperation() final {
    ConversionTarget target(getContext());
    auto *context = &getContext();

    // Assemble type converter.
    //  - when a TupleType is encountered, it is converted to a list of its
    //    internal element types
    TypeConverter typeConverter;
    typeConverter.addConversion([](Type type) { return type; }); // Default
    typeConverter.addConversion(
        [](TupleType tupleType, SmallVectorImpl<Type> &types) {
          tupleType.getFlattenedTypes(types);
          return success();
        });

    // Assemble patterns - when a MakeTuple or GetTupleElement operation is
    // encountered, the corresponding conversion pattern is applied
    // When a tuple type is encountered in cal.actor ops, the
    // ConvertCalActorTupleArguments pattern is applied which converts the
    // tuple arguments of the cal.actor op to a list of its internal element
    // types
    RewritePatternSet patterns(context);
    patterns.add<ConvertMakeTuple, ConvertGetTupleElement,
                 ConvertCalActorTupleArguments>(typeConverter,
                                                patterns.getContext());

    // These are patterns existing in MLIR that take in tuple arguments
    // in ops within the func and scf dialects and decompose them into
    // their individual elements.
    populateFuncTypeConversionPatterns(typeConverter, patterns);
    mlir::scf::populateSCFStructuralOneToNTypeConversions(typeConverter,
                                                          patterns);

    // Run conversion.
    if (failed(applyPartialOneToNConversion(getOperation(), typeConverter,
                                            std::move(patterns))))
      return signalPassFailure();
  }
};

} // namespace mlir::fifo

std::unique_ptr<mlir::Pass> mlir::fifo::decomposeFifoTuples() {
  return std::make_unique<mlir::fifo::DecomposeFifoTuplesPass>();
}
