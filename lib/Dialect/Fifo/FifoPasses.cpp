//===- FifoPasses.cpp - Fifo passes -----------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Rewrite/FrozenRewritePatternSet.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Transforms/DialectConversion.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "Dialect/Fifo/FifoPasses.h"
#include <iostream>

namespace mlir::fifo {
#define GEN_PASS_DEF_LOWERFIFOTOMEMREFPASS
#include "Dialect/Fifo/FifoPasses.h.inc"

class ConvertCreateOpToMemref
    : public OpConversionPattern<CreateOp> {
  using OpConversionPattern<CreateOp>::OpConversionPattern;

  LogicalResult matchAndRewrite(CreateOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    std::cout << "We got here" << std::endl;
    // if (op.getIsLegal())
    //   return failure();
    // rewriter.startOpModification(op);
    // Block *body = &op.getBody().front();
    // TypeConverter::SignatureConversion result(body->getNumArguments());
    // for (auto it : llvm::enumerate(body->getArgumentTypes()))
    //   result.addInputs(it.index(), {it.value(), it.value()});
    // rewriter.applySignatureConversion(body, result, getTypeConverter());
    // op.setIsLegal(true);
    // rewriter.finalizeOpModification(op);

    return success();
  }
};


class LowerFifoToMemrefPass
    : public impl::LowerFifoToMemrefPassBase<LowerFifoToMemrefPass> {
public:
  // using impl::LowerFifoToMemrefPassBase<
  //  LowerFifoToMemrefPass>::LowerFifoToMemrefPassBase;
  void runOnOperation() final {
    ConversionTarget target(getContext());


    RewritePatternSet patterns(&getContext());
    patterns.add<ConvertCreateOpToMemref>(&getContext());

    if (failed(applyPartialConversion(getOperation(), target, std::move(patterns))))
        signalPassFailure();
  }
};

} // namespace mlir::fifo
