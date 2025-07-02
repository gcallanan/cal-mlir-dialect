//===- BufferizableOpInterfaceImpl.cpp - Impl. of BufferizableOpInterface -===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Cal State Bufferization
//===----------------------------------------------------------------------===//
//
// This file implements BufferizableOpInterface for Cal dialect operations that
// work with tensor-typed state variables. The bufferization process transforms
// tensor-based Cal state operations into their memref equivalents.
//
// The transformation handles three key operations:
// 1. cal.create_state_var: Creates state variables with memref types instead 
//    of tensor types
// 2. cal.get: Retrieves memref values from state variables instead of tensors
// 3. cal.set: Stores memref values into state variables, with automatic
//    bufferization of tensor operands
//
// Input example:
//   %accumulator = cal.create_state_var<tensor<2x2xf64>> : !cal.state_ref<tensor<2x2xf64>>
//   %tensor = cal.get(%accumulator: !cal.state_ref<tensor<2x2xf64>>) : tensor<2x2xf64>
//   %tensor0 = tensor.from_elements %c0_f64, %c1_f64, %c2_f64, %c3_f64 : tensor<2x2xf64>
//   cal.set(%accumulator: !cal.state_ref<tensor<2x2xf64>>, %tensor0: tensor<2x2xf64>)
//
// Transformed output:
//   %1 = cal.create_state_var<memref<2x2xf64>> : !cal.state_ref<memref<2x2xf64>>
//   %2 = cal.get(%1 : !cal.state_ref<memref<2x2xf64>>) : memref<2x2xf64>
//   %alloc = memref.alloc() {alignment = 64 : i64} : memref<2x2xf64>
//   memref.store %cst, %alloc[%c0_3, %c0_3] : memref<2x2xf64>
//   memref.store %cst_0, %alloc[%c0_3, %c1_4] : memref<2x2xf64>
//   memref.store %cst_1, %alloc[%c1_4, %c0_3] : memref<2x2xf64>
//   memref.store %cst_2, %alloc[%c1_4, %c1_4] : memref<2x2xf64>
//   cal.set(%1 : !cal.state_ref<memref<2x2xf64>>, %alloc : memref<2x2xf64>)
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_CAL_TRANSFORMS_BUFFERIZABLEOPINTERFACEIMPL_H
#define MLIR_DIALECT_CAL_TRANSFORMS_BUFFERIZABLEOPINTERFACEIMPL_H

namespace mlir {
class DialectRegistry;

namespace cal {
void registerBufferizableOpInterfaceExternalModels(DialectRegistry &registry);
} // namespace cal
} // namespace mlir

#endif // MLIR_DIALECT_CAL_TRANSFORMS_BUFFERIZABLEOPINTERFACEIMPL_H