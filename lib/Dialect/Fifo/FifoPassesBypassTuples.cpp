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
#define GEN_PASS_DEF_BYPASSFIFOTUPLES
#include "Dialect/Fifo/FifoPasses.h.inc"

class BypassFifoTuplesPass
    : public impl::BypassFifoTuplesBase<BypassFifoTuplesPass> {
public:
//    using impl::BypassFifoTuplesBase<
//    BypassFifoTuplesBase>::BypassFifoTuplesBase;
  void runOnOperation() final {
    ConversionTarget target(getContext());

    // Something about this being a stack
    RewritePatternSet patterns(&getContext());
    // patterns.add<ConvertFifoPullToMemref>(&getContext());
    // patterns.add<ConvertFifoPushToMemref>(&getContext());
    // patterns.add<ConvertFifoCreateOpToMemref>(&getContext());

    // // Set the legal and illegal dialects after this conversion
    // target.addIllegalDialect<fifo::FifoDialect>();
    // target.addLegalOp<fifo::MakeTuple, fifo::GetTupleElement>();
    // target.addLegalDialect<memref::MemRefDialect, index::IndexDialect,
    //                        arith::ArithDialect>();

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

std::unique_ptr<mlir::Pass> mlir::fifo::bypassFifoTuples() {
  return std::make_unique<mlir::fifo::BypassFifoTuplesPass>();
}
