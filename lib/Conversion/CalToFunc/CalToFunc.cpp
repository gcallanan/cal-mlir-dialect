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

#include "Conversion/Passes.h"
#include "Conversion/CalToFunc/CalToFunc.h"

namespace mlir::cal {
#define GEN_PASS_DEF_CONVERTCALTOFUNC
#include "Conversion/Passes.h.inc"

class ConvertCalToFuncPass
    : public impl::ConvertCalToFuncBase<ConvertCalToFuncPass> {
public:
  void runOnOperation() final {
    ConversionTarget target(getContext());
    RewritePatternSet patterns(&getContext());


    llvm::outs() << "Running ConvertCalToFuncPass\n";

    // patterns.add<MoveInitOperationsToArguments>(&getContext());
    // patterns.add<AddStateAboveCreateInstance>(&getContext());

    if (failed(applyPatternsGreedily(getOperation(),
                                            std::move(patterns)))) {
      signalPassFailure();
    }
  }
};

} // namespace mlir::cal

/// Creates a pass to hoist cal.state operations out of actor bodies.
std::unique_ptr<mlir::Pass> mlir::cal::createConvertCalToFuncPass() {
  return std::make_unique<mlir::cal::ConvertCalToFuncPass>();
}