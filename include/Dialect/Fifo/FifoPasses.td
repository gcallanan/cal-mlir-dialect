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

def LowerFifoPrintToLLVM: Pass<"lower-fifo-print-to-llvm"> {
  let summary = "Lowers fifo.print and fifo.print_tensor operations to LLVM dialect equivalents.";
  let description = [{
    This pass converts both `fifo.print` and `fifo.print_tensor` operations into equivalent
    constructs in the LLVM dialect for compatibility with LLVM-based backends.

    **For `fifo.print` operations:**
    - Converts format strings and variadic arguments into calls to the `printf` function
    - Handles type conversions (f32 to f64, index to i32) as needed for printf compatibility
    - Creates global string constants for format specifiers

    **For `fifo.print_tensor` operations:**
    - Converts tensor/memref printing into nested `scf.for` loops with `fifo.print` calls
    - Handles tensors of arbitrary dimensions by treating the last two dimensions as matrices
    - Prints index indicators for higher-dimensional tensors (e.g., "At index [0][][]:")
    - Automatically converts tensors to memrefs using bufferization when necessary
    - Uses appropriate format specifiers based on element type ("%f" for floats, "%d" for integers)

    The pass ensures that all printing operations are properly lowered to LLVM-compatible
    constructs while maintaining the original formatting and readability of the output.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];

  let options = [
      Option<"tensors_on_gpu", "tensors-on-gpu", "bool", /*default=*/"false",
            "Assume all tensors are in GPU memory and transfer them to host memory before printing.">,
    ];

  let dependentDialects = [
    "fifo::FifoDialect",
    "LLVM::LLVMDialect",
    "scf::SCFDialect",
    "arith::ArithDialect",
    "memref::MemRefDialect",
    "tensor::TensorDialect",
    "gpu::GPUDialect",
    "bufferization::BufferizationDialect"
  ];
}

def ExtractFifoPopViewPass: Pass<"extract-fifo-pop-view", "ModuleOp"> {
  let summary = "Replace loop-of-pops into an alloca with fifo.pop_bulk_view/release for zero-copy bulk reads";
  let description = [{
    Identifies the pattern of a fifo.pop inside an scf.for (with constant lb=0,
    step=1, and a constant upper bound N) whose result is stored into a
    memref.alloca inside a cal.action, and replaces it with a paired
    fifo.pop_bulk_view (acquire) / fifo.pop_bulk_release (release):
    - fifo.pop_bulk_view is placed where the fill loop was -- the earliest point
      any of the alloca's uses occur -- and returns a direct view into the FIFO
      backing buffer without touching the read counter.
    - fifo.pop_bulk_release is placed at the end of the action body, so it is
      guaranteed to run after every use of the view, and advances the read
      counter to free the consumed slots.
    The alloca and fill loop are erased. Splitting the counter advance out and
    deferring it to the end of the action (rather than performing it eagerly,
    as a single combined op would) prevents a concurrently running producer
    from observing freed slots and overwriting them while this action is still
    reading through the view.

    Constraints:
    - The scf.for must have lb=0, step=1, and a constant upper bound.
    - The fifo.pop must store its result into the alloca at the loop IV.
    - The pattern must appear directly in a cal.action body block.
    - No other fifo.pop targeting the same port may appear anywhere else in the
      action: it would advance the read counter out from under the base offset
      this pass captures, racing for the same slots.

    Must run before lower-fifo-to-memref.
  }];
  let dependentDialects = [
    "fifo::FifoDialect",
    "arith::ArithDialect"
  ];
}

def ExtractFifoPushViewPass: Pass<"extract-fifo-push-view", "ModuleOp"> {
  let summary = "Replace alloca-then-loop-of-pushes into fifo.push_bulk_view/fifo.push_bulk_commit for zero-copy bulk writes";
  let description = [{
    Identifies the pattern of a memref.alloca inside a cal.action that is
    later drained by an scf.for (with constant lb=0, step=1, and a constant
    upper bound N) whose body loads from the alloca at the loop IV and pushes
    the result via a single fifo.push, and replaces it with a
    fifo.push_bulk_view (a direct, writable view into the FIFO backing buffer,
    placed where the alloca was) and a fifo.push_bulk_commit (which publishes
    the data and advances the write counter, placed where the drain loop was).
    The alloca and drain loop are erased; any computation that previously
    filled the alloca now writes directly into the FIFO buffer.

    Constraints:
    - The scf.for must have lb=0, step=1, and a constant upper bound N
      (matching the alloca's static size), expressed either directly as an
      index constant or as an i32 constant fed through arith.index_cast.
    - The loop body must be exactly: load from alloca[iv], fifo.push of that
      value to a single port, and yield.
    - The drain loop must be the alloca's last use.
    - No other fifo.push to the same port may appear anywhere else in the
      action (it would race with the reserved-but-not-yet-committed region).
    - The pattern must appear directly in a cal.action body block.

    Must run before lower-fifo-to-memref. Only safe for single-threaded /
    static-schedule execution.
  }];
  let dependentDialects = [
    "fifo::FifoDialect",
    "arith::ArithDialect"
  ];
}

#endif // FIFO_PASS
