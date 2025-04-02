//===- FifoPsss.td - Fifo dialect passes -------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef FIFO_PASS
#define FIFO_PASS

include "mlir/Pass/PassBase.td"

def LowerFifoToMemrefPass: Pass<"lower-fifo-to-memref"> {
  let summary = "Lowers to fifo dialect to memref dialect";
  let description = [{
    The `lower-fifo-to-memref` pass converts operations in the FIFO dialect to equivalent
    operations in the MemRef dialect. This pass is used to lower abstract FIFO queues into
    concrete representation of this FIFO in memory.

    This pass works by transforming FIFO buffer operations (such as `fifo.create`, `fifo.push`,
    and `fifo.pull`) into MemRef-based operations that represent memory buffers. The pass
    is not thread-safe, meaning it should be used in single-threaded execution contexts
    to avoid issues with concurrent transformations.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];
  let constructor = "mlir::fifo::createLowerFifoToMemrefPass()";
  let dependentDialects = [
    "memref::MemRefDialect",
    "index::IndexDialect",
    "arith::ArithDialect",
    "LLVM::LLVMDialect",
    "fifo::FifoDialect"
  ];
}

def DecomposeFifoTuples: Pass<"decompose-fifo-tuples"> {
  let summary = "Eliminate tuple constructs in the FIFO dialect.";
  let description = [{
    In the FIFO dialect, the `lower-fifo-to-memref` pass transforms `fifo.input_port`
    and `fifo.output_port` operations into `memref` types, resulting in types like
    `tuple<memref<Axi32>, memref<Bxi32>>`. These are constructed using the
    `fifo.make_tuple` operation (e.g., `%tuple = fifo.make_tuple(%a, %b)`) and accessed
    via `fifo.get_element` (e.g., `%element = fifo.get_element(%tuple, %index)`).

    This pass simplifies the IR by removing `fifo.make_tuple` and
    `fifo.get_element` operations, replacing tuple-based constructs with direct use of
    the original operands.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];
  let constructor = "mlir::fifo::decomposeFifoTuples()";
  let dependentDialects = [
    "fifo::FifoDialect"
  ];
}

#endif // FIFO_PASS
