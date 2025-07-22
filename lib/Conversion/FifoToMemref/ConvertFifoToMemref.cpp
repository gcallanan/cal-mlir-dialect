//===- FifoPasses.cpp - Fifo passes -----------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// @author Gareth Callanan
// Disclaimer - I have wrote the code myself but used ChatGPT to generate
// top level comments describing each class with the hope that it will make
// the code easier to understand.
#include "Conversion/FifoToMemref/ConvertFifoToMemref.h"

#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoPasses.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Func/Transforms/FuncConversions.h"
#include "mlir/Dialect/Index/IR/IndexDialect.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Rewrite/FrozenRewritePatternSet.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include <iostream>

namespace mlir {
#define GEN_PASS_DEF_LOWERFIFOTOMEMREFPASS
#include "Conversion/Passes.h.inc"

using namespace fifo;

/// Creates a MemRef type for FIFO data storage by prepending a buffer size
/// dimension to the element type. Handles MemRef, Tensor, and scalar element
/// types.
/// @param elementType The element type that the FIFO will store (MemRef,
/// Tensor, or scalar)
/// @param fifoSize The FIFO buffer size for the first dimension
static MemRefType createFifoDataMemRefType(mlir::Type elementType,
                                           int64_t fifoSize) {
  if (auto memrefType = mlir::dyn_cast<mlir::MemRefType>(elementType)) {
    llvm::SmallVector<int64_t, 4> newShape;
    newShape.push_back(fifoSize);
    auto origShape = memrefType.getShape();
    newShape.append(origShape.begin(), origShape.end());
    return mlir::MemRefType::get(newShape, memrefType.getElementType(),
                                 mlir::MemRefLayoutAttrInterface{},
                                 memrefType.getMemorySpace());
  }

  if (auto tensorType = mlir::dyn_cast<mlir::TensorType>(elementType)) {
    llvm::SmallVector<int64_t, 4> newShape;
    newShape.push_back(fifoSize);
    auto origShape = tensorType.getShape();
    newShape.append(origShape.begin(), origShape.end());
    return mlir::MemRefType::get(newShape, tensorType.getElementType());
  }

  return MemRefType::get(fifoSize, elementType);
}

// This transformation converts the `fifo.create` operation into a sequence of
// operations that allocate memory for the data and metadata and store the
// initial values. The process involves the following steps:
//
// Note: Tensors and memrefs are handled slightly differently when allocating
// the data buffer. For memrefs the buffer size is prepended as the first
// dimension, while for tensors are cast to memrefs and the buffer size
// is added as a new dimension.
//
// NOTE: This fifo has one element more than the specified size, this allows
// for checking the number of elements and free space on the buffer without
// even if the bufer size is 1.
//
// Input:
// %in0, %out0 = fifo.create<i32>(10) : !fifo.input_port<i32>,
// !fifo.output_port<i32>
//
// 1. Allocate memory for the data (`memref<10xi32>`) and the metadata
// (`memref<2xi32>`).
//    - `%alloc` allocates a memory buffer for storing 10 `i32` elements.
//    - `%alloc_0` allocates a memory buffer for storing metadata (with 2 `i32`
//    elements). Position 0 stores the read index and position 1 stores the
//    write index in this metadata memory buffer.
//    - Deallocation can be handled by a different pass (--buffer-deallocation).
//
// 2. Create a tuple to hold both memory buffers (`%alloc`, `%alloc_0`) and the
// size `11`.
//    - The tuple is created using `fifo.make_tuple` with the following types:
//      - `memref<11xi32>` for the data buffer.
//      - `memref<2xi32>` for the metadata buffer.
//      - `i32` for the buffer size (constant `10`).
//
// 3. Store the initial value (0) into the metadata buffer (`%alloc_0`), at
// index positions 0 and 1.
//    - This is done using `memref.store` operations to initialize the metadata
//    elements.
//
// Output:
//     %alloc = memref.alloc() : memref<10xi32>
//     %alloc_0 = memref.alloc() : memref<2xi32>
//     %c10_i32 = arith.constant 10 : i32
//     %0 = fifo.make_tuple(%alloc, %alloc_0, %c10_i32) : memref<10xi32>,
//         memref<2xi32>, i32 -> tuple<memref<10xi32>, memref<2xi32>, i32>
//     %c0_i32 = arith.constant 0 : i32
//     %c0 = arith.constant 0 : index
//     %c1 = arith.constant 1 : index
//     memref.store %c0_i32, %alloc_0[%c0] : memref<2xi32>
//     memref.store %c0_i32, %alloc_0[%c1] : memref<2xi32>
class ConvertFifoCreateOpToMemref : public OpConversionPattern<CreateOp> {
  using OpConversionPattern<CreateOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(CreateOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    mlir::Location loc = op.getLoc();

    auto bufferSize = op.getBufferSize() + 1; // +1 so we can get the size
    auto elementType = op.getElementType();

    // 1. Allocate the data memref
    auto memRefType_data = createFifoDataMemRefType(elementType, bufferSize);
    auto alloc_data = rewriter.create<memref::AllocOp>(loc, memRefType_data);

    // 2. Allocate the metadata memref and zero its elements
    auto memRefType_metadata = MemRefType::get(2, rewriter.getI32Type());
    auto alloc_metadata =
        rewriter.create<memref::AllocOp>(loc, memRefType_metadata);

    // 3. Store the size of the buffer in a constant
    auto i32Type = rewriter.getIntegerType(32);
    auto bufferSizeConstant = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getI32IntegerAttr(bufferSize));

    // 4. Initialize the metadata memref
    auto tupleType = TupleType::get(
        getContext(), {memRefType_data, memRefType_metadata, i32Type});
    auto make_tuple_op = rewriter.create<fifo::MakeTuple>(
        loc, tupleType,
        ValueRange{alloc_data.getResult(), alloc_metadata.getResult(),
                   bufferSizeConstant.getResult()});

    // 5. Create a tuple type to hold the data and metadata memrefs as well as
    // the buffer size
    auto zeroI32 = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(0));
    Value index0 = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    Value index1 = rewriter.create<arith::ConstantIndexOp>(loc, 1);
    rewriter.create<memref::StoreOp>(loc, zeroI32, alloc_metadata, index0);
    rewriter.create<memref::StoreOp>(loc, zeroI32, alloc_metadata, index1);

    // 6. Now make sure to replace the operation correctly.
    rewriter.replaceOp(op,
                       {make_tuple_op.getResult(), make_tuple_op.getResult()});

    return success();
  }
};

static Value copyFifoToMemref(PatternRewriter &rewriter, Location loc,
                              Value srcFifo, Value srcIndex) {
  auto srcType = mlir::cast<MemRefType>(srcFifo.getType());
  int64_t rank = srcType.getRank();

  // The source memref has shape [N, ...], we want to extract a subview at
  // srcIndex along the first dimension. The result should be a memref with one
  // less dimension (i.e., drop the first dimension).

  // 1. Compute offsets, sizes, strides for subview
  SmallVector<OpFoldResult, 4> offsets, sizes, strides;

  // Offsets: first dimension is srcIndex, others are 0
  offsets.push_back(OpFoldResult(srcIndex));
  for (int64_t i = 1; i < rank; ++i)
    offsets.push_back(OpFoldResult(rewriter.getIndexAttr(0)));

  // Sizes: first dimension is 1, others match the shape of the remaining
  // dimensions
  sizes.push_back(rewriter.getIndexAttr(1));
  for (int64_t i = 1; i < rank; ++i)
    sizes.push_back(rewriter.getIndexAttr(srcType.getShape()[i]));

  // Strides: all 1
  for (int64_t i = 0; i < rank; ++i)
    strides.push_back(rewriter.getIndexAttr(1));

  // 2. Create subview
  auto subview =
      rewriter.create<memref::SubViewOp>(loc, srcFifo, offsets, sizes, strides);

  // 3. Collapse the first two dimensions (1, D1) -> D1, so result shape matches
  // destination
  SmallVector<ReassociationIndices> reassociation;
  if (rank > 1) {
    reassociation.push_back({0, 1});
    for (int64_t i = 2; i < rank; ++i)
      reassociation.push_back({i});
  } else {
    reassociation.push_back({0});
  }

  auto collapsed =
      rewriter.create<memref::CollapseShapeOp>(loc, subview, reassociation);

  // 4. Return the collapsed subview
  return collapsed.getResult();
}

// This class defines a conversion pattern for the `fifo.pop` operation. It
// transforms a `fifo.pop` operation that operates on a FIFO output port into a
// read operation from a circular buffer. The pattern works as follows:
//
// Note: Tensors and memrefs are handled differently for the output data. For
// tensors, the data is extracted using copyFifoToMemref and then converted back
// to tensor using bufferization.to_tensor. For memrefs, copyFifoToMemref is
// used directly. For scalars, a simple memref.load is used.
//
// - Extracts the `dataMemref`, `metadataMemref`, and `bufferSizeI32` from the
//       tuple that represents the FIFO state.
// - Retrieves the read index (i.e., the current position in the FIFO) and
//       converts it to an index type.
// - Loads the data from the FIFO at the current position (read index).
// - Increments the read index, wrapping it back to zero if it exceeds the
//       buffer size.
// - Stores the updated read index back to the metadata memref to keep track of
//       the FIFO's state.
//
// Input example:
//   %0 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
//
// Output example:
//   %1 = fifo.get_tuple_element %0[0] :
//       tuple<memref<10xi32>, memref<2xi32>,i32> -> memref<10xi32>
//   %2 = fifo.get_tuple_element %0[1] : tuple<memref<10xi32>, memref<2xi32>,
//       memref<2xi32>,i32> -> memref<2xi32>
//   %3 = fifo.get_tuple_element %0[2] : tuple<memref<10xi32>, memref<2xi32>,
//       i32> -> i32
//   %c0 = arith.constant 0 : index
//   %4 = memref.load %2[%c0] : memref<2xi32>
//   %5 = arith.index_cast %4 : i32 to index
//   %6 = memref.load %1[%5] : memref<10xi32>
//   %c0_i32 = arith.constant 0 : i32
//   %c1_i32 = arith.constant 1 : i32
//   %7 = arith.addi %4, %c1_i32 : i32
//   %8 = arith.remsi %7, %3 : i32
//   memref.store %8, %2[%c0_1] : memref<2xi32>
//   memref.store %9, %2[%c0] : memref<2xi32>
class ConvertFifoPopToMemref : public OpConversionPattern<Pop> {
  using OpConversionPattern<Pop>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(Pop op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    mlir::Location loc = op.getLoc();

    auto tupleType = mlir::cast<TupleType>(adaptor.getOutputPort().getType());
    auto dataMemref = rewriter.create<fifo::GetTupleElement>(
        loc, tupleType.getType(0), adaptor.getOutputPort(), 0);
    auto metadataMemref = rewriter.create<fifo::GetTupleElement>(
        loc, tupleType.getType(1), adaptor.getOutputPort(), 1);
    auto bufferSizeI32 = rewriter.create<fifo::GetTupleElement>(
        loc, tupleType.getType(2), adaptor.getOutputPort(), 2);

    // 1. Get the read index and convert it to type index
    Value readLocationIndex = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    auto readI32 =
        rewriter.create<memref::LoadOp>(loc, metadataMemref, readLocationIndex);
    Value readIndex = rewriter.create<arith::IndexCastOp>(
        loc, rewriter.getIndexType(), readI32);

    // 2. Get the data at the front of the fifo using the read index
    auto tokenType = op.getOutputToken().getType();

    Value outputData;
    if (auto tensorType = mlir::dyn_cast<mlir::TensorType>(tokenType)) {

      outputData = copyFifoToMemref(rewriter, loc, dataMemref, readIndex);
      auto toTensorOp = rewriter.create<mlir::bufferization::ToTensorOp>(
          loc, tokenType, outputData);
      toTensorOp->setAttr("restrict", rewriter.getUnitAttr());
      outputData = toTensorOp.getResult();
    } else if (auto memrefType = mlir::dyn_cast<mlir::MemRefType>(tokenType)) {
      outputData = copyFifoToMemref(rewriter, loc, dataMemref, readIndex);
    } else {
      outputData = rewriter.create<memref::LoadOp>(loc, dataMemref, readIndex);
    }

    // 3. Increment the read index and wrap it to zero if it goes out of bounds
    auto oneI32 = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(1));
    auto incrementedReadI32 =
        rewriter.create<arith::AddIOp>(loc, readI32, oneI32);
    auto newReadI32 =
        rewriter.create<arith::RemSIOp>(loc, incrementedReadI32, bufferSizeI32);

    // 4. Write the new read index back to the metadata
    rewriter.create<memref::StoreOp>(loc, newReadI32, metadataMemref,
                                     readLocationIndex);

    rewriter.replaceOp(op, outputData);

    return success();
  }
};

/// Helper function to copy a memref or tensor value into the FIFO data buffer
/// at a given index. Handles copying shaped values (memref/tensor) into a slice
/// of the FIFO data memref.
/// - rewriter: The PatternRewriter to use for IR construction.
/// - loc: The location for new operations.
/// - src: The source memref/tensor value to copy from.
/// - dstIndex: The index in the FIFO data buffer to copy to (index-typed).
/// - fifoDataMemref: The FIFO data memref to copy into.
static void copyMemrefToFifo(PatternRewriter &rewriter, Location loc, Value src,
                             Value dstIndex, Value fifoDataMemref) {
  auto srcType = mlir::cast<MemRefType>(src.getType());
  auto dstType = mlir::cast<MemRefType>(fifoDataMemref.getType());

  // Strategy: The FIFO data memref has shape [N, ...], where N is the FIFO
  // size. We want to copy src into fifoDataMemref[dstIndex, ...]. We'll use
  // memref.subview to get a slice at dstIndex, then memref.copy.

  // 1. Compute the offsets, sizes, and strides for subview operation
  SmallVector<OpFoldResult, 4> offsets, sizes, strides;

  // 1.1. Set offsets: first dimension uses dstIndex, others are 0
  offsets.push_back(OpFoldResult(dstIndex));
  for (int64_t i = 1, e = dstType.getRank(); i < e; ++i)
    offsets.push_back(OpFoldResult(rewriter.getIndexAttr(0)));

  // 1.2. Set sizes: first dimension is 1 (single slice), others match src shape
  sizes.push_back(rewriter.getIndexAttr(1));
  if (auto srcMemref = mlir::dyn_cast<MemRefType>(srcType)) {
    for (int64_t d : srcMemref.getShape())
      sizes.push_back(rewriter.getIndexAttr(d));
  } else if (auto srcTensor = mlir::dyn_cast<RankedTensorType>(srcType)) {
    for (int64_t d : srcTensor.getShape())
      sizes.push_back(rewriter.getIndexAttr(d));
  } else {
    // Not a shaped type, nothing to do
    return;
  }

  // 1.3. Set strides: all dimensions have stride 1
  for (int i = 0, e = dstType.getRank(); i < e; ++i)
    strides.push_back(rewriter.getIndexAttr(1));

  // 2. Create subview of the FIFO data memref at the given index
  auto subview = rewriter.create<memref::SubViewOp>(loc, fifoDataMemref,
                                                    offsets, sizes, strides);

  // 3. Create reassociation indices for collapsing the shape.
  // For example, this collapses a shape like 1x2x2xi32 to 2x2xi32,
  // by merging the first (slice) dimension with the next dimension(s).
  SmallVector<ReassociationIndices> reassociation;
  auto subviewRank = subview.getType().getRank();
  if (subviewRank > 1) {
    reassociation.push_back({0, 1});
    for (int i = 2; i < subviewRank; ++i) {
      reassociation.push_back({i});
    }
  } else if (subviewRank == 1) {
    reassociation.push_back({0});
  }

  // 4. Reshape the subview to match the source memref shape
  auto reshapedSubview = rewriter.create<memref::CollapseShapeOp>(
      loc, subview.getResult(), reassociation);

  // 5. Copy the source memref into the reshaped subview
  rewriter.create<memref::CopyOp>(loc, src, reshapedSubview);
}

// This transformation converts a `fifo.push` operation into a series of
// operations for interacting with a circular buffer.
//
// Note: Tensors and memrefs are handled differently for the input data. For
// tensors, the data is first converted to memref using bufferization.to_memref
// and then copied using copyMemrefToFifo. For memrefs, copyMemrefToFifo is
// used directly. For scalars, a simple memref.store is used.
//
// Input: A FIFO push operation with a value to be pushed to the FIFO and a
// reference to an output port in the form of a tuple (data, metadata, buffer
// size). The input consists of a data value and metadata for managing the FIFO
// (e.g., write index).
//
// Output: A series of operations that handle the actual push operation into the
// circular buffer. This includes:
//   1. Retrieving the current write index from the metadata.
//   2. Storing the input data into the buffer at the current write index.
//   3. Incrementing the write index, checking if it goes out of bounds, and
//   wrapping it
//      to zero if necessary.
//   4. Writing the updated write index back to the metadata buffer.
//
// Example Input:
//   %constant672 = arith.constant 672 : i32
//   fifo.push(%in0: !fifo.input_port<i32>, %constant672: i32)
//
// Example Output:
//   %c672_i32 = arith.constant 672 : i32
//   %1 = fifo.get_tuple_element %0[0] : tuple<memref<10xi32>, memref<2xi32>,
//   i32> -> memref<10xi32> %2 = fifo.get_tuple_element %0[1] :
//   tuple<memref<10xi32>, memref<2xi32>, i32> -> memref<2xi32> %3 =
//   fifo.get_tuple_element %0[2] : tuple<memref<10xi32>, memref<2xi32>, i32> ->
//   i32 %c1_1 = arith.constant 1 : index %4 = memref.load %2[%c1_1] :
//   memref<2xi32> %5 = arith.index_cast %4 : i32 to index memref.store
//   %c672_i32, %1[%5] : memref<10xi32> %c0_i32_2 = arith.constant 0 : i32
//   %c1_i32 = arith.constant 1 : i32
//   %6 = arith.addi %4, %c1_i32 : i32
//   %7 = arith.remsi %6, %3 : i32
//   memref.store %7, %2[%c1_1] : memref<2xi32>
class ConvertFifoPushToMemref : public OpConversionPattern<Push> {
  using OpConversionPattern<Push>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(Push op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    mlir::Location loc = op.getLoc();

    auto tupleType = mlir::cast<TupleType>(adaptor.getInputPort().getType());
    auto dataMemref = rewriter.create<fifo::GetTupleElement>(
        loc, tupleType.getType(0), adaptor.getInputPort(), 0);
    auto metadataMemref = rewriter.create<fifo::GetTupleElement>(
        loc, tupleType.getType(1), adaptor.getInputPort(), 1);
    auto bufferSizeI32 = rewriter.create<fifo::GetTupleElement>(
        loc, tupleType.getType(2), adaptor.getInputPort(), 2);

    // 1. Get the write index and convert it to type index
    Value writeLocationIndex = rewriter.create<arith::ConstantIndexOp>(loc, 1);
    auto writeI32 = rewriter.create<memref::LoadOp>(loc, metadataMemref,
                                                    writeLocationIndex);
    Value writeIndex = rewriter.create<arith::IndexCastOp>(
        loc, rewriter.getIndexType(), writeI32);

    // 2. Push the data at the back of the fifo
    auto tokenType = adaptor.getInputToken().getType();
    auto token = adaptor.getInputToken();

    // mlir::Type convertedTokenType = tokenType;
    if (auto tensorType = mlir::dyn_cast<mlir::TensorType>(tokenType)) {
      auto bufferizedToken = rewriter.create<mlir::bufferization::ToMemrefOp>(
          loc,
          mlir::MemRefType::get(tensorType.getShape(),
                                tensorType.getElementType()),
          token);

      copyMemrefToFifo(rewriter, loc, bufferizedToken, writeIndex, dataMemref);

    } else if (auto memrefType = mlir::dyn_cast<mlir::MemRefType>(tokenType)) {
      copyMemrefToFifo(rewriter, loc, token, writeIndex, dataMemref);
    } else {
      rewriter.create<memref::StoreOp>(loc, token, dataMemref, writeIndex);
    }

    // 3. Increment the write index and wrap it to zero if it goes out of bounds
    auto oneI32 = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(1));
    auto incrementedWriteI32 =
        rewriter.create<arith::AddIOp>(loc, writeI32, oneI32);
    auto newWriteI32 = rewriter.create<arith::RemSIOp>(loc, incrementedWriteI32,
                                                       bufferSizeI32);

    // 4. Write the new write index back to the metadata buffer
    rewriter.create<memref::StoreOp>(loc, newWriteI32, metadataMemref,
                                     writeLocationIndex);

    rewriter.eraseOp(op);

    return success();
  }
};

// This class defines a conversion pattern for the `fifo.size` operation.
// It transforms a `fifo.size` operation that operates on a FIFO output port
// into a sequence of operations that compute the number of elements present in
// the FIFO. The transformation proceeds as follows:
//
// - Extracts the `dataMemref`, `metadataMemref`, and the buffer size (as an
// i32) from the tuple representing the FIFO state.
// - Loads the write index (stored at metadata index 1) and the read index
// (stored at metadata index 0).
// - Computes the FIFO size using the formula:
//      (write - read + bufferSize) % bufferSize
//   where `bufferSize` is the total size of the circular buffer (including an
//   extra slot).
// - Casts the resulting i32 value into an index type.
//
// Input example:
//   %0 = fifo.size(%out0: !fifo.output_port<i32>) : index
//
// Transformed output:
//   %1 = fifo.get_tuple_element %0[0] :
//       tuple<memref<11xi32>, memref<2xi32>, i32> -> memref<11xi32>
//   %2 = fifo.get_tuple_element %0[1] : tuple<memref<11xi32>, memref<2xi32>,
//       memref<2xi32>, i32> -> memref<2xi32>
//   %3 = fifo.get_tuple_element %0[2] : tuple<memref<11xi32>, memref<2xi32>,
//       i32> -> i32
//   %c1_2 = arith.constant 1 : index
//   %4 = memref.load %2[%c1_2] : memref<2xi32>
//   %c0_3 = arith.constant 0 : index
//   %5 = memref.load %2[%c0_3] : memref<2xi32>
//   %6 = arith.subi %4, %5 : i32
//   %7 = arith.addi %6, %3 : i32
//   %8 = arith.remsi %7, %3 : i32
//   %9 = arith.index_cast %8 : i32 to index
//
// The arithmetic operations compute the FIFO size based on the current write
// and read indices.
class ConvertFifoSizeOpToMemref : public OpConversionPattern<SizeOp> {
  using OpConversionPattern<SizeOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(SizeOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    mlir::Location loc = op.getLoc();

    auto tupleType = mlir::cast<TupleType>(adaptor.getOutputPort().getType());
    auto metadataMemref = rewriter.create<fifo::GetTupleElement>(
        loc, tupleType.getType(1), adaptor.getOutputPort(), 1);
    auto bufferSizeI32 = rewriter.create<fifo::GetTupleElement>(
        loc, tupleType.getType(2), adaptor.getOutputPort(), 2);

    // 1. Get the write and read index and convert it to type index
    Value writeLocationIndex = rewriter.create<arith::ConstantIndexOp>(loc, 1);
    auto writeI32 = rewriter.create<memref::LoadOp>(loc, metadataMemref,
                                                    writeLocationIndex);

    Value readLocationIndex = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    auto readI32 =
        rewriter.create<memref::LoadOp>(loc, metadataMemref, readLocationIndex);

    // 2. Calculate the size of the FIFO - equal to
    // (write-read+bufferSize)%bufferSize
    auto step1 = rewriter.create<arith::SubIOp>(loc, writeI32, readI32);
    auto step2 = rewriter.create<arith::AddIOp>(loc, step1, bufferSizeI32);
    auto size = rewriter.create<arith::RemSIOp>(loc, step2, bufferSizeI32);
    auto sizeIndex =
        rewriter.create<arith::IndexCastOp>(loc, rewriter.getIndexType(), size);

    // 3. Replace eraseOp with the new calculated size
    rewriter.replaceOp(op, sizeIndex);

    return success();
  }
};

// This class defines a conversion pattern for the `fifo.space` operation.
// It transforms a `fifo.space` operation that operates on a FIFO input port
// into a sequence of operations that compute the amount of free space available
// in the FIFO. The transformation involves the following steps:
//
// - Extracts the `dataMemref`, `metadataMemref`, and the buffer size (as an
// i32) from the tuple representing the FIFO state.
// - Loads the write index (at metadata index 1) and the read index (at metadata
// index 0).
// - Computes the space available using the formula:
//      bufferSize - (write - read + bufferSize) % bufferSize - 1
//   Here, the subtraction of 1 accounts for the extra slot used for
//   differentiating between full and empty states in the circular buffer
//   implementation.
// - Casts the resulting i32 value into an index type.
//
// Input example:
//   %space0 = fifo.space(%in0: !fifo.input_port<i32>) : index
//
// Transformed output (simplified):
//   %1 = fifo.get_tuple_element %0[0] : tuple<memref<11xi32>, memref<2xi32>,
//            i32> -> memref<11xi32>
//   %2 = fifo.get_tuple_element %0[1] : tuple<memref<11xi32>, memref<2xi32>,
//            i32> -> memref<2xi32>
//   %3 = fifo.get_tuple_element %0[2] : tuple<memref<11xi32>, memref<2xi32>,
//            i32> -> i32
//   %c1_2 = arith.constant 1 : index
//   %4 = memref.load %2[%c1_2] : memref<2xi32>
//   %c0_3 = arith.constant 0 : index
//   %5 = memref.load %2[%c0_3] : memref<2xi32>
//   %c1_i32 = arith.constant 1 : i32
//   %6 = arith.subi %4, %5 : i32
//   %7 = arith.addi %6, %3 : i32
//   %8 = arith.remsi %7, %3 : i32
//   %9 = arith.subi %3, %8 : i32
//   %10 = arith.subi %9, %c1_i32 : i32
//   %11 = arith.index_cast %10 : i32 to index
//
// The arithmetic operations compute the free space in the FIFO by subtracting
// the current FIFO size (i.e., the number of elements present) from the total
// buffer size, then adjusting by one.
class ConvertFifoSpaceOpToMemref : public OpConversionPattern<SpaceOp> {
  using OpConversionPattern<SpaceOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(SpaceOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    mlir::Location loc = op.getLoc();

    auto tupleType = mlir::cast<TupleType>(adaptor.getInputPort().getType());
    auto metadataMemref = rewriter.create<fifo::GetTupleElement>(
        loc, tupleType.getType(1), adaptor.getInputPort(), 1);
    auto bufferSizeI32 = rewriter.create<fifo::GetTupleElement>(
        loc, tupleType.getType(2), adaptor.getInputPort(), 2);

    // 1. Get the write and read index and convert it to type index
    Value writeLocationIndex = rewriter.create<arith::ConstantIndexOp>(loc, 1);
    auto writeI32 = rewriter.create<memref::LoadOp>(loc, metadataMemref,
                                                    writeLocationIndex);

    Value readLocationIndex = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    auto readI32 =
        rewriter.create<memref::LoadOp>(loc, metadataMemref, readLocationIndex);

    // 2. Calculate the space avaialble in theFIFO - equal to
    // bufferSize - (write-read+bufferSize)%bufferSize - 1
    auto oneI32 = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(1));
    auto step1 = rewriter.create<arith::SubIOp>(loc, writeI32, readI32);
    auto step2 = rewriter.create<arith::AddIOp>(loc, step1, bufferSizeI32);
    auto step3 = rewriter.create<arith::RemSIOp>(loc, step2, bufferSizeI32);
    auto step4 = rewriter.create<arith::SubIOp>(loc, bufferSizeI32, step3);
    auto space = rewriter.create<arith::SubIOp>(loc, step4, oneI32);
    auto spaceIndex = rewriter.create<arith::IndexCastOp>(
        loc, rewriter.getIndexType(), space);

    // 3. Replace eraseOp with the new calculated size
    rewriter.replaceOp(op, spaceIndex);

    return success();
  }
};

// This class defines a conversion pattern for the fifo.peek operation.
// It transforms a fifo.peek operation, which reads a value at a specified
// offset from the current read index of a FIFO output port, into a sequence of
// memref operations that perform the equivalent access on a circular buffer.
//
// Note: Tensors and memrefs are handled differently for the output data. For
// tensors, the data is extracted using copyFifoToMemref and then converted back
// to tensor using bufferization.to_tensor. For memrefs, copyFifoToMemref is
// used directly. For scalars, a simple memref.load is used.
//
// The transformation performs the following steps:
//
// - Extracts the dataMemref, metadataMemref, and the buffer size (as an i32)
//   from the tuple representing the FIFO state.
// - Loads the read index (stored in metadata index 0) and casts it to an
//   index-typed value.
// - Adds the peek index to the read index and wraps the resulting index using
//   a modulo operation with the buffer size to ensure circular access.
// - Loads the data from the data memref at the wrapped index.
//
// Input example:
//   %peekVal = fifo.peek(%out0: !fifo.output_port<i32>, %idx: index) : i32
//
// Transformed output (simplified):
//   %0 = fifo.get_tuple_element %out0[0] :
//        tuple<memref<6xi32>, memref<2xi32>, i32> -> memref<6xi32>
//   %1 = fifo.get_tuple_element %out0[1] :
//        tuple<memref<6xi32>, memref<2xi32>, i32> -> memref<2xi32>
//   %2 = fifo.get_tuple_element %out0[2] :
//        tuple<memref<6xi32>, memref<2xi32>, i32> -> i32
//   %3 = arith.index_cast %2 : i32 to index
//   %c0 = arith.constant 0 : index
//   %4 = memref.load %1[%c0] : memref<2xi32>
//   %5 = arith.index_cast %4 : i32 to index
//   %6 = arith.addi %5, %idx : index
//   %7 = arith.remsi %6, %3 : index
//   %8 = memref.load %0[%7] : memref<6xi32>
//
// This conversion allows the fifo.peek operation to be lowered into
// conventional index arithmetic and memory access operations that operate
// directly on memrefs, making it compatible with passes that work over standard
// MLIR dialects like memref and arith.
class ConvertFifoPeekToMemref : public OpConversionPattern<Peek> {
  using OpConversionPattern<Peek>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(Peek op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    mlir::Location loc = op.getLoc();

    auto tupleType = mlir::cast<TupleType>(adaptor.getOutputPort().getType());
    auto dataMemref = rewriter.create<fifo::GetTupleElement>(
        loc, tupleType.getType(0), adaptor.getOutputPort(), 0);
    auto metadataMemref = rewriter.create<fifo::GetTupleElement>(
        loc, tupleType.getType(1), adaptor.getOutputPort(), 1);
    auto bufferSizeI32 = rewriter.create<fifo::GetTupleElement>(
        loc, tupleType.getType(2), adaptor.getOutputPort(), 2);
    Value bufferSizeIndex = rewriter.create<arith::IndexCastOp>(
        loc, rewriter.getIndexType(), bufferSizeI32);

    // 1. Get the read index and convert it to type index
    Value readLocationIndex = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    auto readI32 =
        rewriter.create<memref::LoadOp>(loc, metadataMemref, readLocationIndex);
    Value readIndex = rewriter.create<arith::IndexCastOp>(
        loc, rewriter.getIndexType(), readI32);

    // 2. Increment the read index by the peek amount and wrap it to zero if
    // it goes out of bounds
    auto peekIndex = op.getPeekIndex();
    auto peekIndexFromReadIndex =
        rewriter.create<arith::AddIOp>(loc, readIndex, peekIndex);
    auto peekIndexWrapped = rewriter.create<arith::RemSIOp>(
        loc, peekIndexFromReadIndex, bufferSizeIndex);

    // 3. Get the data to be peeked using the peekIndexWrapped
    Value outputData;
    auto tokenType = op.getResult().getType();
    if (auto tensorType = mlir::dyn_cast<mlir::TensorType>(tokenType)) {
      outputData =
          copyFifoToMemref(rewriter, loc, dataMemref, peekIndexWrapped);
      auto toTensorOp = rewriter.create<mlir::bufferization::ToTensorOp>(
          loc, tokenType, outputData);
      toTensorOp->setAttr("restrict", rewriter.getUnitAttr());
      outputData = toTensorOp.getResult();
    } else if (auto memrefType = mlir::dyn_cast<mlir::MemRefType>(tokenType)) {
      outputData =
          copyFifoToMemref(rewriter, loc, dataMemref, peekIndexWrapped);
    } else {
      outputData = rewriter.create<memref::LoadOp>(
          loc, dataMemref, peekIndexWrapped.getResult());
    }
    rewriter.replaceOp(op, outputData);

    return success();
  }
};

/// Helper function to create a tuple type for FIFO port conversion
static mlir::Type createFifoPortTupleType(mlir::Type elementType,
                                          MLIRContext *context) {
  auto memRefType_data =
      createFifoDataMemRefType(elementType, mlir::ShapedType::kDynamic);
  auto i32Type = mlir::IntegerType::get(context, 32);
  auto memRefType_metadata = MemRefType::get(2, i32Type);
  auto tupleType =
      TupleType::get(context, {memRefType_data, memRefType_metadata, i32Type});
  return tupleType;
}

/// Build a converter that changes !fifo.output_port<T> and !fifo.input_port<T>
/// types into tuple<memref<?xT>, memref<2x i32>, i32>
static void populateFifoTypeConverterDynamic(mlir::TypeConverter &converter,
                                             MLIRContext *context) {

  // 1) The identity conversion for all other types
  converter.addConversion([&](Type type) { return type; });
  // 2) Custom conversion for fifo::OutputPortType
  converter.addConversion(
      [context](fifo::OutputPortType portType) -> mlir::Type {
        return createFifoPortTupleType(portType.getElementType(), context);
      });
  // 3) Custom conversion for fifo::InputPortType
  converter.addConversion(
      [context](fifo::InputPortType portType) -> mlir::Type {
        return createFifoPortTupleType(portType.getElementType(), context);
      });
  // 4) Target Materialization - converts statically sized memrefs to dynamic
  // ones
  //
  // Handles conversion from static to dynamic memref dimensions when needed.
  // Example: tuple<memref<11xi32>, memref<2xi32>, i32> → tuple<memref<?xi32>,
  // memref<2xi32>, i32>
  converter.addTargetMaterialization([context](OpBuilder &builder,
                                               TupleType resultType,
                                               ValueRange inputs,
                                               Location loc) -> Value {
    Value input = inputs[0];

    TupleType inputTupleType = mlir::cast<TupleType>(input.getType());
    Type dataType =
        mlir::cast<MemRefType>(inputTupleType.getType(0)).getElementType();
    Type inputDataMemrefType = inputTupleType.getType(0);
    Type metadataMemrefType = inputTupleType.getType(1);
    Type sizeType = inputTupleType.getType(2);
    auto inputDataMemref = builder.create<fifo::GetTupleElement>(
        loc, inputDataMemrefType, input, 0);
    auto metadataMemref = builder.create<fifo::GetTupleElement>(
        loc, metadataMemrefType, input, 1);
    auto size = builder.create<fifo::GetTupleElement>(loc, sizeType, input, 2);

    // Create new shape with dynamic first dimension but preserve other
    // dimensions
    auto inputMemrefType = mlir::cast<MemRefType>(inputDataMemrefType);
    auto originalShape = inputMemrefType.getShape();
    llvm::SmallVector<int64_t> newShape;
    newShape.push_back(mlir::ShapedType::kDynamic);
    newShape.append(originalShape.begin() + 1, originalShape.end());

    auto dynamicDataMemrefType =
        mlir::MemRefType::get(newShape, dataType, inputMemrefType.getLayout(),
                              inputMemrefType.getMemorySpace());
    auto castedMemref = builder.create<mlir::memref::CastOp>(
        loc, dynamicDataMemrefType, inputDataMemref);

    auto makeTupleOp = builder.create<fifo::MakeTuple>(
        loc, resultType,
        ValueRange{castedMemref.getResult(), metadataMemref.getResult(),
                   size.getResult()});

    return makeTupleOp;
  });
}

// This class defines a conversion pattern for the cal.actor operation.
// It applies a type conversion to the arguments of the cal.actor operation,
// specifically targeting types such as fifo.input_port and fifo.output_port.
// The conversion transforms these types into their corresponding tuple types,
// enabling further decomposition and lowering in subsequent passes.
//
// The transformation performs the following steps:
//
// - Applies the provided type converter to the region's argument types,
//   converting types like fifo.input_port and fifo.output_port into tuple
//   types.
// - Updates the region's signature with the converted types.
//
// Input example:
//   cal.actor @my_actor3(%arg0: i32, %arg1: i32)
//       ports_in (
//         %arg2: !fifo.output_port<i32>
//       )
//     {
//     }
//
// Transformed output:
//   cal.actor @my_actor3(%arg0: i32, %arg1: i32, %arg2: tuple<memref<?xi32>,
//   memref<2xi32>, i32>)
//     {
//     }
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

// This class defines a conversion pattern for the cal.create_instance
// operation. It does not need to do much as the ArrayRef<Value> array
// already contains the transformed operands. We just create a new
// cal.create_instance operation with the transformed operands and
// replace the cal.create_instance old operation with the new one.
//
// Input example:
//   cal.create_instance @one_output "temp" ()
//     ports_out (%inputPort : !fifo.input_port<i32>)
//
// Transformed output:
//   cal.create_instance @one_output "temp" (%4 :
//            tuple<memref<?xi32>, memref<2xi32>, i32>)
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

// This pass converts operations from the FIFO dialect to the MemRef dialect,
// enabling interaction with memory buffers in a more conventional MLIR
// representation. The pass transforms `fifo.push`, `fifo.pop`, and
// `fifo.create` operations into equivalent operations using the `memref`
// dialect, along with necessary metadata (e.g., write/read indices).
//
// The conversion is performed using a set of rewrite patterns that handle each
// of the FIFO operations, turning them into operations for circular buffers
// using memrefs:
//   1. `ConvertFifoPopToMemref`: Converts `fifo.pop` to a read from a
//   circular buffer.
//   2. `ConvertFifoPushToMemref`: Converts `fifo.push` to a write to a circular
//   buffer.
//   3. `ConvertFifoCreateOpToMemref`: Converts `fifo.create` into memory
//   allocation and tuple creation operations.
//
// After the conversion, the pass ensures that only legal operations remain in
// the operation (e.g., `memref.alloc`, `memref.load`, `memref.store`, etc.) and
// makes the `fifo` dialect illegal. The fifo make_tuple and get_tuple_element
// operations are kept legal to allow with the expectation that the
// --decompose-fifo-tuples pass will be run after this pass to decompose the
// tuples into original operands
class LowerFifoToMemrefPass
    : public impl::LowerFifoToMemrefPassBase<LowerFifoToMemrefPass> {
public:
  // using impl::LowerFifoToMemrefPassBase<
  //  LowerFifoToMemrefPass>::LowerFifoToMemrefPassBase;
  void runOnOperation() final {
    ConversionTarget target(getContext());

    TypeConverter typeConverter;
    populateFifoTypeConverterDynamic(typeConverter, &getContext());

    RewritePatternSet patterns(&getContext());
    patterns.add<ConvertFifoSizeOpToMemref>(&getContext());
    patterns.add<ConvertFifoSpaceOpToMemref>(&getContext());
    patterns.add<ConvertFifoPopToMemref>(&getContext());
    patterns.add<ConvertFifoPushToMemref>(&getContext());
    patterns.add<ConvertFifoCreateOpToMemref>(&getContext());
    patterns.add<ConvertFifoPeekToMemref>(&getContext());
    patterns.add<ConvertCalActorArguments>(&getContext(), typeConverter);
    patterns.add<ConvertCalCreateInstanceOperands>(&getContext(),
                                                   typeConverter);

    // Helper functions to add a type conversion pattern to the func.func
    // and func.call operations
    mlir::populateFunctionOpInterfaceTypeConversionPattern<mlir::func::FuncOp>(
        patterns, typeConverter);
    mlir::populateCallOpTypeConversionPattern(patterns, typeConverter);

    // Set the legal and illegal dialects after this conversion
    target.addIllegalDialect<fifo::FifoDialect>();
    target.addLegalOp<fifo::MakeTuple, fifo::GetTupleElement, fifo::PrintOp,
                      fifo::PrintTensorOp>();
    target.addLegalDialect<memref::MemRefDialect, index::IndexDialect,
                           arith::ArithDialect, tensor::TensorDialect,
                           bufferization::BufferizationDialect>();

    // Ensure that func.func and func.call operations can handle the new
    // types after the typeConverter has been applied.
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
        if (mlir::isa<fifo::OutputPortType>(arg.getType()) ||
            mlir::isa<fifo::InputPortType>(arg.getType())) {
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
