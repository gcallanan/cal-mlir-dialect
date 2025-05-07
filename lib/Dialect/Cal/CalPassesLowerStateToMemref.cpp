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
#include "mlir/Dialect/Index/IR/IndexDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Rewrite/FrozenRewritePatternSet.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

#include "Dialect/Cal/CalPasses.h"

namespace mlir::cal {
#define GEN_PASS_DEF_LOWERCALSTATETOMEMREF
#include "Dialect/Cal/CalPasses.h.inc"

// Converts the `cal.create_state_var` operation into a memref allocation of size 1
//
// This transformation lowers a `cal.create_state_var` on a state reference of
// element type `T` to a `memref.alloc` of shape `<1 x T>`.
//
// Input:
//   %ref0 = cal.create_state_var<i32> : !cal.state_ref<i32>
//
// Output:
//   %alloc = memref.alloc() : memref<1xi32>
class ConvertCalCreateStateVarOpToMemref
    : public OpConversionPattern<CreateStateVarOp> {
  using OpConversionPattern<CreateStateVarOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(CreateStateVarOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    // llvm::outs() << "Hi\n";
    mlir::Location loc = op.getLoc();
    auto stateType = op.getStateType();
    auto memRefType_data = MemRefType::get(1, stateType);
    auto alloc_state = rewriter.create<memref::AllocOp>(loc, memRefType_data);
    rewriter.replaceOp(op, alloc_state);

    return success();
  }
};

/// Converts a `cal.get` operation (reading from a state reference) to a
/// `memref.load` operation.
///
/// Input:
///   %val = cal.get(%ref0 : !cal.state_ref<i32>) : i32
///
/// Is rewritten into:
///   %c0 = arith.constant 0 : index
///   %0 = memref.load %ref0[%c0] : memref<1xi32>
class ConvertCalStateGetOpToMemref : public OpConversionPattern<StateGetOp> {
  using OpConversionPattern<StateGetOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(StateGetOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    mlir::Location loc = op.getLoc();
    auto stateRef = adaptor.getStateRef();

    Value readLocationIndex = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    auto readData =
        rewriter.create<memref::LoadOp>(loc, stateRef, readLocationIndex);
    rewriter.replaceOp(op, readData);

    return success();
  }
};

/// Converts a `cal.set` operation (writing to a state reference) to a
/// `memref.store` operation.
///
/// Input:
///   %c32 = arith.constant 32 : i32
///   cal.set(%ref0 : !cal.state_ref<i32>, %c32 : i32)
///
/// Is rewritten into:
///   %c0 = arith.constant 0 : index
///   memref.store %c32, %ref0[%c0] : memref<1xi32>
class ConvertCalStateSetOpToMemref : public OpConversionPattern<StateSetOp> {
  using OpConversionPattern<StateSetOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(StateSetOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    mlir::Location loc = op.getLoc();
    auto stateRef = adaptor.getStateRef();
    auto stateValue = adaptor.getStateValue();

    Value writeLocationIndex = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    auto storeOp = rewriter.create<memref::StoreOp>(loc, stateValue, stateRef,
                                                    writeLocationIndex);
    rewriter.replaceOp(op, storeOp);

    return success();
  }
};

/// This pass lowers `cal.state`, `cal.get`, and `cal.set` operations to
/// standard MLIR `memref` operations.
///
/// Specifically:
/// - `cal.state` is replaced with an `memref.alloc` of size 1 to simulate a scalar state.
/// - `cal.get` is replaced with a `memref.load` from index 0.
/// - `cal.set` is replaced with a `memref.store` to index 0.
class LowerCalStateToMemrefPass
    : public impl::LowerCalStateToMemrefBase<LowerCalStateToMemrefPass> {
public:
  void runOnOperation() final {
    ConversionTarget target(getContext());

    RewritePatternSet patterns(&getContext());
    patterns.add<ConvertCalStateSetOpToMemref>(&getContext());
    patterns.add<ConvertCalStateGetOpToMemref>(&getContext());
    patterns.add<ConvertCalCreateStateVarOpToMemref>(&getContext());

    // // Set the legal and illegal dialects after this conversion
    // target.addIllegalDialect<cal::CalDialect>();
    // target.addLegalOp<fifo::MakeTuple, fifo::GetTupleElement,
    target.addLegalDialect<memref::MemRefDialect, index::IndexDialect,
                           arith::ArithDialect>();

    // Run the conversion
    if (failed(applyPartialConversion(getOperation(), target,
                                      std::move(patterns)))) {
      signalPassFailure();
    }
  }
};

} // namespace mlir::cal

/// Creates a pass that lowers CAL dialect state operations (`cal.state`,
/// `cal.get`, `cal.set`) to equivalent operations in the MemRef dialect.
std::unique_ptr<mlir::Pass> mlir::cal::lowerCalStateToMemref() {
  return std::make_unique<mlir::cal::LowerCalStateToMemrefPass>();
}