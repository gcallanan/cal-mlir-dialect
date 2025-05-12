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

#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoPasses.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Func/Transforms/FuncConversions.h"
#include "mlir/Dialect/Index/IR/IndexDialect.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Rewrite/FrozenRewritePatternSet.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include <iostream>

namespace mlir::fifo {
#define GEN_PASS_DEF_LOWERFIFOTOMEMREFPASS
#include "Dialect/Fifo/FifoPasses.h.inc"

// This transformation converts the `fifo.create` operation into a sequence of
// operations that allocate memory for the data and metadata and store the
// initial values. The process involves the following steps:
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
    auto memRefType_data = MemRefType::get(bufferSize, elementType);
    auto alloc_data = rewriter.create<memref::AllocOp>(loc, memRefType_data);

    // 2. Allocate the metadata memref and zero its elements
    auto memRefType_metadata = MemRefType::get(2, rewriter.getI32Type());
    auto alloc_metadata =
        rewriter.create<memref::AllocOp>(loc, memRefType_metadata);

    // 3. Store the size of the buffer in a constant
    auto i32Type = rewriter.getIntegerType(32);
    auto bufferSizeConstant = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getI32IntegerAttr(bufferSize));

    // 4. Create a tuple type to hold the data and metadata memrefs as well as
    // the buffer size
    auto tupleType = TupleType::get(
        getContext(), {memRefType_data, memRefType_metadata, i32Type});
    auto make_tuple_op = rewriter.create<fifo::MakeTuple>(
        loc, tupleType,
        ValueRange{alloc_data.getResult(), alloc_metadata.getResult(),
                   bufferSizeConstant.getResult()});
    auto zeroI32 = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(0));
    Value index0 = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    Value index1 = rewriter.create<arith::ConstantIndexOp>(loc, 1);
    rewriter.create<memref::StoreOp>(loc, zeroI32, alloc_metadata, index0);
    rewriter.create<memref::StoreOp>(loc, zeroI32, alloc_metadata, index1);

    rewriter.replaceOp(op,
                       {make_tuple_op.getResult(), make_tuple_op.getResult()});

    return success();
  }
};

// This class defines a conversion pattern for the `fifo.pop` operation. It
// transforms a `fifo.pop` operation that operates on a FIFO output port into a
// read operation from a circular buffer. The pattern works as follows:
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
    auto outputData =
        rewriter.create<memref::LoadOp>(loc, dataMemref, readIndex);

    // 3. Increment the read index and wrap it to zero if it goes out of bounds
    auto oneI32 = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(1));
    auto incrementedReadI32 =
        rewriter.create<arith::AddIOp>(loc, readI32, oneI32);
    auto newReadI32 =
        rewriter.create<arith::RemSIOp>(loc, incrementedReadI32, bufferSizeI32);

    // 4. Write the new read index back to the metadata
    rewriter.create<memref::StoreOp>(
        loc, newReadI32, metadataMemref, readLocationIndex);

    rewriter.replaceOp(op, outputData);

    return success();
  }
};

// This transformation converts a `fifo.push` operation into a series of
// operations for interacting with a circular buffer.
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

    // 2. Push the data at the back of the fifo using the write index
    auto pushedData = rewriter.create<memref::StoreOp>(
        loc, adaptor.getInputToken(), dataMemref, writeIndex);

    // 3. Increment the write index and wrap it to zero if it goes out of bounds
    auto oneI32 = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(1));
    auto incrementedWriteI32 =
        rewriter.create<arith::AddIOp>(loc, writeI32, oneI32);
    auto newWriteI32 = rewriter.create<arith::RemSIOp>(loc, incrementedWriteI32,
                                                       bufferSizeI32);

    // 4. Write the new write index back to the metadata buffer
    rewriter.create<memref::StoreOp>(
        loc, newWriteI32, metadataMemref, writeLocationIndex);

    rewriter.replaceOp(op, pushedData);

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

    // llvm::outs() << "Peek op: " << op << "\n";

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
    auto peekedData = rewriter.create<memref::LoadOp>(
        loc, dataMemref, peekIndexWrapped.getResult());
    rewriter.replaceOp(op, peekedData);

    return success();
  }
};

/// Build a converter that changes !fifo.output_port<T> and !fifo.input_port<T>
/// into tuple<memref<?xT>, memref<2x i32>, i32>
static void populateFifoTypeConverterDynamic(mlir::TypeConverter &converter,
                                             MLIRContext *context) {

  // 1) The identity conversion for all other types
  converter.addConversion([&](Type type) { return type; });
  // 2) Custom conversion for fifo::OutputPortType
  converter.addConversion(
      [context](fifo::OutputPortType portType) -> mlir::Type {
        auto elementType = portType.getElementType();
        // kDynamic means that the size of the memref is not known at compile
        // time
        auto memRefType_data =
            MemRefType::get(mlir::ShapedType::kDynamic, elementType);
        auto memRefType_metadata = MemRefType::get(2, elementType);
        auto i32Type = mlir::IntegerType::get(context, 32);
        auto tupleType = TupleType::get(
            context, {memRefType_data, memRefType_metadata, i32Type});
        return tupleType;
      });
  // 3) Custom conversion for fifo::OutputPortType
  converter.addConversion(
      [context](fifo::InputPortType portType) -> mlir::Type {
        auto elementType = portType.getElementType();
        // kDynamic means that the size of the memref is not known at compile
        // time
        auto memRefType_data =
            MemRefType::get(mlir::ShapedType::kDynamic, elementType);
        auto memRefType_metadata = MemRefType::get(2, elementType);
        auto i32Type = mlir::IntegerType::get(context, 32);
        auto tupleType = TupleType::get(
            context, {memRefType_data, memRefType_metadata, i32Type});
        return tupleType;
      });
  // 4) Target Materialization for fifo::InputPortType and fifo::OutputPortType
  //
  // During conversions, we sometimes get a tuple containing a statically sized
  // memref, and we need to convert it to a dynamically sized memref. An example
  // is passing a FIFO port of a static size to a call function that
  // can support different sizes of ports. The static form needs to be cast
  // to a dynamic form. This function will insert fifo.get_tuple_element
  // memref.cast and fifo.make_tuple operations into your SSA.
  //
  // Example input type: tuple<memref<11xi32>, memref<2xi32>, i32>
  // Generated output type: tuple<memref<?xi32>, memref<2xi32>, i32>
  //
  // Process:
  //   1. Extract the input tuple and decompose it into its constituent
  //   elements:
  //      - inputDataMemref: memref<11xi32>
  //      - metadataMemref: memref<2xi32>
  //      - size: i32
  //   2. Cast inputDataMemref from memref<11xi32> to memref<?xi32> using
  //   memref.cast.
  //   3. Reconstruct a new tuple with the casted memref, preserving the
  //   metadata and size.
  converter.addTargetMaterialization(
      [context](OpBuilder &builder, TupleType resultType, ValueRange inputs,
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
        auto size =
            builder.create<fifo::GetTupleElement>(loc, sizeType, input, 2);

        auto dynamicDataMemrefType =
            mlir::MemRefType::get({mlir::ShapedType::kDynamic}, dataType);
        auto castedMemref = builder.create<mlir::memref::CastOp>(
            loc, dynamicDataMemrefType, inputDataMemref);
        llvm::outs() << castedMemref << "\n";

        auto makeTupleOp = builder.create<fifo::MakeTuple>(
            loc, resultType,
            ValueRange{castedMemref.getResult(), metadataMemref.getResult(),
                       size.getResult()});

        return makeTupleOp;
      });
}

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

    // Helper functions to add a type conversion pattern to the func.func
    // and func.call operations
    mlir::populateFunctionOpInterfaceTypeConversionPattern<mlir::func::FuncOp>(
        patterns, typeConverter);
    mlir::populateCallOpTypeConversionPattern(patterns, typeConverter);

    // Set the legal and illegal dialects after this conversion
    target.addIllegalDialect<fifo::FifoDialect>();
    target.addLegalOp<fifo::MakeTuple, fifo::GetTupleElement, fifo::PrintOp>();
    target.addLegalDialect<memref::MemRefDialect, index::IndexDialect,
                           arith::ArithDialect>();

    // Ensure that func.func and func.call operations can handle the new
    // types after the typeConverter has been applied.
    target.addDynamicallyLegalOp<func::FuncOp>([&](func::FuncOp fn) {
      return typeConverter.isSignatureLegal(fn.getFunctionType());
    });
    target.addDynamicallyLegalOp<func::CallOp>([&](func::CallOp op) {
      return typeConverter.isSignatureLegal(op.getCalleeType());
    });

    // Run the conversion
    if (failed(applyPartialConversion(getOperation(), target,
                                      std::move(patterns)))) {
      signalPassFailure();
    }
  }
};

} // namespace mlir::fifo

// Creates and returns a new instance of the LowerFifoToMemrefPass.
// This pass is responsible for lowering operations in the FIFO dialect to
// equivalent operations in the MemRef dialect, enabling further optimizations
// and transformations that work on the MemRef data model.
std::unique_ptr<mlir::Pass> mlir::fifo::createLowerFifoToMemrefPass() {
  return std::make_unique<mlir::fifo::LowerFifoToMemrefPass>();
}
