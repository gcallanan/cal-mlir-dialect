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
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
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
// size `10`.
//    - The tuple is created using `fifo.make_tuple` with the following types:
//      - `memref<10xi32>` for the data buffer.
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

    auto bufferSize = op.getBufferSize();
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
    auto zeroReadLocation =
        rewriter.create<memref::StoreOp>(loc, zeroI32, alloc_metadata, index0);
    auto zeroWriteLocation =
        rewriter.create<memref::StoreOp>(loc, zeroI32, alloc_metadata, index1);

    rewriter.replaceOp(op,
                       {make_tuple_op.getResult(), make_tuple_op.getResult()});

    return success();
  }
};

// This class defines a conversion pattern for the `fifo.pull` operation. It
// transforms a `fifo.pull` operation that operates on a FIFO output port into a
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
//   %0 = fifo.pull(%out0: !fifo.output_port<i32>) : i32
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
class ConvertFifoPullToMemref : public OpConversionPattern<Pull> {
  using OpConversionPattern<Pull>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(Pull op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    mlir::Location loc = op.getLoc();

    auto tupleType = adaptor.getOutputPort().getType().cast<TupleType>();
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
    auto zeroI32 = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(0));
    auto oneI32 = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(1));
    auto incrementedReadI32 =
        rewriter.create<arith::AddIOp>(loc, readI32, oneI32);
    auto newReadI32 =
        rewriter.create<arith::RemSIOp>(loc, incrementedReadI32, bufferSizeI32);

    // 4. Write the new read index back to the metadata
    auto storeNewReadI32 = rewriter.create<memref::StoreOp>(
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

    auto tupleType = adaptor.getInputPort().getType().cast<TupleType>();
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
    auto zeroI32 = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(0));
    auto oneI32 = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getI32Type(), rewriter.getI32IntegerAttr(1));
    auto incrementedWriteI32 =
        rewriter.create<arith::AddIOp>(loc, writeI32, oneI32);
    auto newWriteI32 = rewriter.create<arith::RemSIOp>(loc, incrementedWriteI32,
                                                       bufferSizeI32);

    // 4. Write the new write index back to the metadata buffer
    auto storeNewReadI32 = rewriter.create<memref::StoreOp>(
        loc, newWriteI32, metadataMemref, writeLocationIndex);

    rewriter.replaceOp(op, pushedData);

    return success();
  }
};

// This pass converts operations from the FIFO dialect to the MemRef dialect,
// enabling interaction with memory buffers in a more conventional MLIR
// representation. The pass transforms `fifo.push`, `fifo.pull`, and
// `fifo.create` operations into equivalent operations using the `memref`
// dialect, along with necessary metadata (e.g., write/read indices).
//
// The conversion is performed using a set of rewrite patterns that handle each
// of the FIFO operations, turning them into operations for circular buffers
// using memrefs:
//   1. `ConvertFifoPullToMemref`: Converts `fifo.pull` to a read from a
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

    RewritePatternSet patterns(&getContext());
    patterns.add<ConvertFifoPullToMemref>(&getContext());
    patterns.add<ConvertFifoPushToMemref>(&getContext());
    patterns.add<ConvertFifoCreateOpToMemref>(&getContext());

    // Set the legal and illegal dialects after this conversion
    target.addIllegalDialect<fifo::FifoDialect>();
    target.addLegalOp<fifo::MakeTuple, fifo::GetTupleElement, fifo::PrintOp>();
    target.addLegalDialect<memref::MemRefDialect, index::IndexDialect,
                           arith::ArithDialect>();

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
