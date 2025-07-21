//===- BufferizableOpInterfaceImpl.cpp - Impl. of BufferizableOpInterface -===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// Fifo Dialect Bufferization
//===----------------------------------------------------------------------===//
//
// This file declares BufferizableOpInterface external models for Fifo dialect
// operations that work with tensor types. The bufferization process transforms
// tensor-based operations into their memref equivalents for efficient
// execution.
//
// Currently implements bufferization support for:
// - fifo.print_tensor: Converts tensor operands to memref types while
//   preserving the printing functionality. The operation reads from tensor
//   arguments but does not modify them, making it safe for bufferization.
//
// The bufferization ensures that:
// 1. Tensor operands are converted to equivalent memref types
// 2. No memory aliasing issues are introduced
// 3. Read-only semantics are preserved for printing operations
// 4. The operation maintains its original printing behavior after bufferization
//
// Example transformation:
//   Input:  fifo.print_tensor %tensor : tensor<2x3xf32>
//   Output: fifo.print_tensor %memref : memref<2x3xf32>
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_FIFO_TRANSFORMS_BUFFERIZABLEOPINTERFACEIMPL_H
#define MLIR_DIALECT_FIFO_TRANSFORMS_BUFFERIZABLEOPINTERFACEIMPL_H

namespace mlir {
class DialectRegistry;

namespace fifo {
void registerBufferizableOpInterfaceExternalModels(DialectRegistry &registry);
} // namespace fifo
} // namespace mlir

#endif // MLIR_DIALECT_FIFO_TRANSFORMS_BUFFERIZABLEOPINTERFACEIMPL_H