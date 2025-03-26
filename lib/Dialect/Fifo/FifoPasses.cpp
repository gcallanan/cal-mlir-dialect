//===- FifoPasses.cpp - Fifo passes -----------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#include "Dialect/Fifo/FifoPasses.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Index/IR/IndexDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Rewrite/FrozenRewritePatternSet.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include <iostream>

namespace mlir::fifo {
#define GEN_PASS_DEF_LOWERFIFOTOMEMREFPASS
#include "Dialect/Fifo/FifoPasses.h.inc"

class ConvertCreateOpToMemref : public OpConversionPattern<CreateOp> {
  using OpConversionPattern<CreateOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(CreateOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    mlir::Location loc = op.getLoc();

    // Type tokenType = op.getElementType().getType();
    auto bufferSize = op.getBufferSize();
    auto elementType = op.getElementType();

    llvm::outs() << loc << " Element: " << elementType
                 << " Size: " << bufferSize << "\n";
    llvm::outs() << "\tInputPort: " << op.getInputPort().getType() << "\n";
    llvm::outs() << "\tOutputPort: " << op.getOutputPort().getType() << "\n";
    // llvm::outs() << "\tNumOps: " << op.getNumOperands() << "\n";
    llvm::outs() << "\tNumResults: " << op.getNumResults() << "\n";

    // We want to create a memref of the given type, this requires two steps
    // 1. Define the memref type
    // 2. Create the alloc operation from the memref type

    auto memRefType_data = MemRefType::get(bufferSize, elementType);
    auto alloc_data = rewriter.create<memref::AllocOp>(loc, memRefType_data);

    auto memRefType_metadata = MemRefType::get(3, elementType);
    auto alloc_metadata =
        rewriter.create<memref::AllocOp>(loc, memRefType_metadata);

    rewriter.replaceOp(op, {alloc_data.getResult(), alloc_data.getResult()});
    // rewriter.eraseOp(op);

    return success();
  }
};

class ConvertFifoPullToMemref : public OpConversionPattern<Pull> {
  using OpConversionPattern<Pull>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(Pull op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    mlir::Location loc = op.getLoc();

    llvm::outs() << loc << "\n";
    llvm::outs() << "\tOutputPort: " << op.getOutputPort().getType() << "\n";
    llvm::outs() << "\tAdapter: " << adaptor.getOutputPort().getType() << "\n";

    Value index0 =
        rewriter.create<arith::ConstantIndexOp>(loc, 5); // random index
    auto memref_load_op =
        rewriter.create<memref::LoadOp>(loc, adaptor.getOutputPort(), index0);
    rewriter.replaceOp(op, memref_load_op);

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

    // Something about this being a stack
    RewritePatternSet patterns(&getContext());
    patterns.add<ConvertFifoPullToMemref>(&getContext());
    patterns.add<ConvertCreateOpToMemref>(&getContext());

    // Set the legal and illegal dialects after this conversion
    target.addLegalDialect<memref::MemRefDialect, index::IndexDialect,
                           arith::ArithDialect>();

    // Run the conversion
    if (failed(applyPartialConversion(getOperation(), target,
                                      std::move(patterns)))) {
      std::cout << "Failed!!!" << std::endl;
      signalPassFailure();
    } else {
      std::cout << "Success!!!" << std::endl;
    }
  }
};

} // namespace mlir::fifo

std::unique_ptr<mlir::Pass> mlir::fifo::createLowerFifoToMemrefPass() {
  return std::make_unique<mlir::fifo::LowerFifoToMemrefPass>();
}
