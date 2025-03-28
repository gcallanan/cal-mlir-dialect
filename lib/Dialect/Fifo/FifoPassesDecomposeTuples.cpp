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
//===----------------------------------------------------------------------===//

#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoPasses.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Index/IR/IndexDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
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

class DecomposeFifoTuplesPass
    : public impl::DecomposeFifoTuplesBase<DecomposeFifoTuplesPass> {
public:
  void runOnOperation() final {
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
    RewritePatternSet patterns(context);
    patterns.add<ConvertMakeTuple, ConvertGetTupleElement>(
        typeConverter, patterns.getContext());

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
