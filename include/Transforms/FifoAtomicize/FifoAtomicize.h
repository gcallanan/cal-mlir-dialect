//===- FifoAtomicize.h - FIFO atomic operations pass ----------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines a transformation pass that converts plain LLVM loads and
// stores on FIFO counter metadata to atomic operations for SPSC thread safety.
//
// The pass identifies memref allocations that represent FIFO metadata (typically
// memref<2xi64> containing readCount and writeCount) and replaces subsequent
// load/store operations on these memrefs with atomic equivalents using
// appropriate memory ordering (acquire for loads, release for stores).
//
//===----------------------------------------------------------------------===//

#ifndef TRANSFORMS_FIFOATOMICIZE_FIFOATOMICIZE_H
#define TRANSFORMS_FIFOATOMICIZE_FIFOATOMICIZE_H

#include "mlir/Pass/Pass.h"
#include <memory>

namespace mlir {

/// Creates a pass that converts FIFO counter memref operations to atomic operations.
///
/// This pass should be run after FIFO dialect lowering (--lower-fifo-to-memref)
/// but before conversion to LLVM dialect. It works on memref.load and memref.store
/// operations and converts them to memref.atomic_rmw operations for thread safety.
std::unique_ptr<Pass> createFifoMemrefAtomicizePass();

} // namespace mlir

#endif // TRANSFORMS_FIFOATOMICIZE_FIFOATOMICIZE_H