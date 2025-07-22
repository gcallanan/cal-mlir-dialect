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
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Func/Transforms/FuncConversions.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/Index/IR/IndexDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Rewrite/FrozenRewritePatternSet.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

#include "Conversion/CalStateToMemref/CalStateToMemref.h"
#include "Conversion/Passes.h"

namespace mlir {

using namespace cal;

#define GEN_PASS_DEF_LOWERCALSTATETOMEMREF
#include "Conversion/Passes.h.inc"

// Converts the `cal.create_state_var` operation into a memref allocation.
// For scalar types, creates a memref allocation of size 1. For memref types,
// uses the type directly. For tensor types, converts to equivalent memref
// types. Deallocation can be handled by other MLIR passes
// (--buffer-deallocation)
//
// This transformation lowers a `cal.create_state_var` on a state reference of
// element type `T` to a `memref.alloc` of shape `<1 x T>` for scalars, or
// converts to equivalent memref types for tensors, or preserves memref types
// directly.
//
// Tensors can be allocated to different memory locations depending on the pass
// option `which-alloc`. By default, tensors are allocated in host memory, but
// if the option is set to `GPU`, tensor allocations use the GPU
// dialect's `gpu.alloc` operation.
//
// Input (scalar):
//   %ref0 = cal.create_state_var<i32> : !cal.state_ref<i32>
// Output (scalar):
//   %alloc = memref.alloc() : memref<1xi32>
//
// Input (tensor):
//   %ref0 = cal.create_state_var<tensor<4xi32>> : !cal.state_ref<tensor<4xi32>>
// Output (tensor):
//   %alloc = memref.alloc() : memref<4xi32>
//
// Input (memref):
//   %ref0 = cal.create_state_var<memref<4xi32>> : !cal.state_ref<memref<4xi32>>
// Output (memref):
//   %alloc = memref.alloc() : memref<4xi32>
class ConvertCalCreateStateVarOpToMemref
    : public OpConversionPattern<CreateStateVarOp> {
public:
  ConvertCalCreateStateVarOpToMemref(MLIRContext *context,
                                     AllocLocation allocLocation)
      : OpConversionPattern<CreateStateVarOp>(context),
        allocLocation(allocLocation) {}

private:
  AllocLocation allocLocation;

  LogicalResult
  matchAndRewrite(CreateStateVarOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    mlir::Location loc = op.getLoc();
    auto stateType = op.getStateType();
    bool isTensor = false;

    MemRefType memrefType;
    if (auto tensorType = stateType.dyn_cast<TensorType>()) {
      memrefType =
          MemRefType::get(tensorType.getShape(), tensorType.getElementType());
          // MemRefType::get(
          // tensorType.getShape(), tensorType.getElementType(), {},
          // mlir::gpu::AddressSpaceAttr::get(t.getContext(),
          //                                  mlir::gpu::AddressSpace::Global));
      isTensor = true;
    } else if (auto memrefTy = stateType.dyn_cast<MemRefType>()) {
      memrefType = memrefTy;
    } else {
      memrefType = MemRefType::get(1, stateType);
    }

    if (allocLocation == AllocLocation::HOST || !isTensor) {
      auto allocOp = rewriter.create<memref::AllocOp>(loc, memrefType);
      rewriter.replaceOp(op, allocOp.getResult());
    } else if (allocLocation == AllocLocation::GPU) {
      auto allocOp = rewriter.create<gpu::AllocOp>(
          loc, memrefType, /*asyncToken=*/Type(),
          /*asyncDependencies=*/ValueRange(),
          /*dynamicSizes=*/ValueRange(), /*symbolOperands=*/ValueRange(),
          /*hostShared=*/false);
      rewriter.replaceOp(op, allocOp.getResult(0));
    } else {
      return rewriter.notifyMatchFailure(op, "Unknown AllocLocation");
    }
    return success();
  }
};

/// Converts a `cal.get` operation (reading from a state reference) to a
/// `memref.load` operation. For memref types, the value is returned directly.
/// For tensor types, the value is retrieved from the buffer and converted to
/// tensor.
///
/// Input (scalar):
///   %val = cal.get(%ref0 : !cal.state_ref<i32>) : i32
///
/// Is rewritten into (scalar):
///   %c0 = arith.constant 0 : index
///   %0 = memref.load %ref0[%c0] : memref<1xi32>
///
/// Input (memref):
///   %val = cal.get(%ref0 : !cal.state_ref<memref<4xi32>>) : memref<4xi32>
///
/// Is rewritten into (memref):
///   // Returns %ref0 directly
///
/// Input (tensor):
///   %val = cal.get(%ref0 : !cal.state_ref<tensor<4xi32>>) : tensor<4xi32>
///
/// Is rewritten into (tensor):
///   %0 = bufferization.to_tensor %ref0 : memref<4xi32>
class ConvertCalStateGetOpToMemref : public OpConversionPattern<StateGetOp> {
  using OpConversionPattern<StateGetOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(StateGetOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    mlir::Location loc = op.getLoc();
    auto stateRef = adaptor.getStateRef();
    auto stateType = op.getStateValue().getType();

    if (mlir::isa<mlir::MemRefType>(stateType)) {
      rewriter.replaceOp(op, stateRef);
      return success();
    }

    if (auto tensorType = stateType.dyn_cast<TensorType>()) {
      auto toTensorOp =
          rewriter.create<bufferization::ToTensorOp>(loc, tensorType, stateRef);
      toTensorOp->setAttr("restrict", rewriter.getUnitAttr());
      rewriter.replaceOp(op, toTensorOp);
      return success();
    }

    Value readLocationIndex = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    auto readData =
        rewriter.create<memref::LoadOp>(loc, stateRef, readLocationIndex);
    rewriter.replaceOp(op, readData);

    return success();
  }
};

/// Converts a `cal.set` operation (writing to a state reference) to a
/// `memref.store` operation. For tensor types, converts the tensor to memref
/// and copies to the state reference. For memref types, copies directly.
///
/// Input (scalar):
///   %c32 = arith.constant 32 : i32
///   cal.set(%ref0 : !cal.state_ref<i32>, %c32 : i32)
///
/// Is rewritten into (scalar):
///   %c0 = arith.constant 0 : index
///   memref.store %c32, %ref0[%c0] : memref<1xi32>
///
/// Input (tensor):
///   %tensor = ... : tensor<4xi32>
///   cal.set(%ref0 : !cal.state_ref<tensor<4xi32>>, %tensor : tensor<4xi32>)
///
/// Is rewritten into (tensor):
///   %buffer = bufferization.to_memref %tensor : memref<4xi32>
///   memref.copy %buffer, %ref0 : memref<4xi32>, memref<4xi32>
///
/// Input (memref):
///   %memref = ... : memref<4xi32>
///   cal.set(%ref0 : !cal.state_ref<memref<4xi32>>, %memref : memref<4xi32>)
///
/// Is rewritten into (memref):
///   memref.copy %memref, %ref0 : memref<4xi32>, memref<4xi32>
class ConvertCalStateSetOpToMemref : public OpConversionPattern<StateSetOp> {
public:
  ConvertCalStateSetOpToMemref(MLIRContext *context,
                               AllocLocation allocLocation)
      : OpConversionPattern<StateSetOp>(context), allocLocation(allocLocation) {
  }

private:
  AllocLocation allocLocation;

  LogicalResult
  matchAndRewrite(StateSetOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    mlir::Location loc = op.getLoc();
    auto stateRef = adaptor.getStateRef();
    auto stateValue = adaptor.getStateValue();

    if (mlir::isa<mlir::TensorType>(stateValue.getType())) {
      auto buffer = rewriter.create<bufferization::ToMemrefOp>(
          loc, stateRef.getType(), stateValue);
      if (allocLocation == AllocLocation::GPU) {
        rewriter.create<gpu::MemcpyOp>(loc,
                                       /*asyncToken=*/Type(),
                                       /*asyncDependencies=*/ValueRange(),
                                       /*dst=*/stateRef,
                                       /*src=*/buffer);
      } else {
        rewriter.create<memref::CopyOp>(loc, buffer, stateRef);
      }
      rewriter.eraseOp(op);
      return success();
    }

    if (mlir::isa<mlir::MemRefType>(stateValue.getType())) {
      rewriter.create<memref::CopyOp>(loc, stateValue, stateRef);
      rewriter.eraseOp(op);
      return success();
    }

    Value writeLocationIndex = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    auto storeOp = rewriter.create<memref::StoreOp>(loc, stateValue, stateRef,
                                                    writeLocationIndex);
    rewriter.replaceOp(op, storeOp);

    return success();
  }
};

// TODO: Merge this with the one in FifoPassesConvertFifoToMemref.cpp
// This class is a copy of the same class in FifoPassesConvertFifoToMemref.cpp
// This is bad practice and these classes should be defined in a common
// location. This is a temporary solution until we can refactor the code
class ConvertCalActorArguments : public ConversionPattern {
public:
  ConvertCalActorArguments(MLIRContext *ctx, const TypeConverter &converter)
      : ConversionPattern(converter, "cal.actor", /*benefit=*/1, ctx) {}

  LogicalResult
  matchAndRewrite(Operation *op, ArrayRef<Value> /*operands*/,
                  ConversionPatternRewriter &rewriter) const override {
    cal::ActorOp actorOp = cast<cal::ActorOp>(op);

    if (failed(rewriter.convertRegionTypes(&actorOp.getBody(), *typeConverter,
                                           nullptr))) {
      return failure();
    }

    return success();
  }
};

// TODO: Merge this with the one in FifoPassesConvertFifoToMemref.cpp
// This class is a copy of the same class in FifoPassesConvertFifoToMemref.cpp
// This is bad practice and these classes should be defined in a common
// location. This is a temporary solution until we can refactor the code
class ConvertCalCreateInstanceOperands : public ConversionPattern {
public:
  ConvertCalCreateInstanceOperands(MLIRContext *ctx,
                                   const TypeConverter &converter)
      : ConversionPattern(converter, "cal.create_instance", /*benefit=*/1,
                          ctx) {}

  LogicalResult
  matchAndRewrite(Operation *op, ArrayRef<Value> operands,
                  ConversionPatternRewriter &rewriter) const override {
    cal::CreateInstanceOp createInstanceOp = cast<cal::CreateInstanceOp>(op);

    // Create a new operation with all the same attributes, just pass the
    // new transformed operands into it
    auto newOp = rewriter.create<cal::CreateInstanceOp>(
        createInstanceOp.getLoc(), createInstanceOp->getResultTypes(), operands,
        createInstanceOp->getAttrs());

    // Replace the old operation with the new one
    rewriter.replaceOp(op, newOp);

    return success();
  }
};

/// Build a converter that changes `cal.state_ref<T>` types into `memref<1xT>`
static void populateCalStateTypeConverterDynamic(mlir::TypeConverter &converter,
                                                 MLIRContext *context) {

  // 1) The identity conversion for all other types
  converter.addConversion([&](Type type) { return type; });
  // 2) The conversion for `cal.state` to `memref`
  converter.addConversion([&](cal::StateVarRefType type) {
    Type elemType = type.getStateType();
    if (auto memrefType = elemType.dyn_cast<MemRefType>())
      return memrefType;
    if (auto tensorType = elemType.dyn_cast<TensorType>()) {
      auto memrefType =
          MemRefType::get(tensorType.getShape(), tensorType.getElementType());
      return memrefType;
    }
    return MemRefType::get(1, elemType);
  });
}

/// This pass lowers `cal.create_state_var`, `cal.get`, and `cal.set` operations
/// to standard MLIR `memref` operations.
///
/// Specifically:
/// - `cal.create_state_var` is replaced with a `memref.alloc` of size 1 for
///   scalars, or equivalent memref types for tensors, or preserved directly for
///   memrefs.
/// - `cal.get` is replaced with a `memref.load` from index 0 for scalars,
///   returns memref directly for memref types, or converts buffer to tensor for
///   tensor types.
/// - `cal.set` is replaced with a `memref.store` to index 0 for scalars,
///   uses `memref.copy` for memref types, or converts tensor to memref and
///   copies for tensor types.
///
/// A type converter is declared that changes all occurences of cal.state_ref
/// types to memref types. This occurs for func.func and func.call as
/// well as the cal.actor and cal.create_instance.
class LowerCalStateToMemrefPass
    : public impl::LowerCalStateToMemrefBase<LowerCalStateToMemrefPass> {
public:
  LowerCalStateToMemrefPass(const LowerCalStateToMemrefOptions &options)
      : impl::LowerCalStateToMemrefBase<LowerCalStateToMemrefPass>(options) {}

  LowerCalStateToMemrefPass() {}

  void runOnOperation() final {
    ConversionTarget target(getContext());

    AllocLocation allocLocation;
    if (which_alloc == "HOST") {
      allocLocation = AllocLocation::HOST;
    } else if (which_alloc == "GPU") {
      allocLocation = AllocLocation::GPU;
    } else {
      mlir::emitError(mlir::UnknownLoc::get(&getContext()))
          << "Invalid allocation location: " << which_alloc
          << ". Valid options are: HOST, GPU";
      signalPassFailure();
      return;
    }

    TypeConverter typeConverter;
    populateCalStateTypeConverterDynamic(typeConverter, &getContext());

    RewritePatternSet patterns(&getContext());
    patterns.add<ConvertCalStateSetOpToMemref>(&getContext(), allocLocation);
    patterns.add<ConvertCalStateGetOpToMemref>(&getContext());
    patterns.add<ConvertCalCreateStateVarOpToMemref>(&getContext(),
                                                     allocLocation);
    patterns.add<ConvertCalActorArguments>(&getContext(), typeConverter);
    patterns.add<ConvertCalCreateInstanceOperands>(&getContext(),
                                                   typeConverter);

    mlir::populateFunctionOpInterfaceTypeConversionPattern<mlir::func::FuncOp>(
        patterns, typeConverter);
    mlir::populateCallOpTypeConversionPattern(patterns, typeConverter);

    // // Set the legal and illegal dialects after this conversion
    target.addLegalDialect<memref::MemRefDialect, index::IndexDialect,
                           arith::ArithDialect, tensor::TensorDialect,
                           gpu::GPUDialect,
                           bufferization::BufferizationDialect>();

    // Provide checks to ensure that the following operations
    // have correctly applied the typeConverter
    target.addDynamicallyLegalOp<func::FuncOp>([&](func::FuncOp fn) {
      return typeConverter.isSignatureLegal(fn.getFunctionType());
    });
    target.addDynamicallyLegalOp<func::CallOp>([&](func::CallOp op) {
      return typeConverter.isSignatureLegal(op.getCalleeType());
    });
    target.addDynamicallyLegalOp<cal::ActorOp>([&](cal::ActorOp op) {
      Region &body = op.getBody();
      Block &block = body.front();
      auto blockArguments = block.getArguments();
      for (auto arg : blockArguments) {
        if (mlir::isa<cal::StateVarRefType>(arg.getType())) {
          return false;
        }
      }
      return true;
    });
    target.addDynamicallyLegalOp<cal::CreateInstanceOp>(
        [&](cal::CreateInstanceOp op) {
          return llvm::all_of(op.getOperandTypes(), [&](Type opType) {
            return typeConverter.isLegal(opType);
          });
        });

    // Run the conversion
    if (failed(applyPartialConversion(getOperation(), target,
                                      std::move(patterns)))) {
      signalPassFailure();
    }
  }
};

} // namespace mlir