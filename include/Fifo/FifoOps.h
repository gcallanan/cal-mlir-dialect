//===- FifoOps.h - Fifo dialect ops -----------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef FIFO_FIFOOPS_H
#define FIFO_FIFOOPS_H

#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/OpDefinition.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/Interfaces/InferTypeOpInterface.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"
#include "mlir/IR/SymbolTable.h"
#include "mlir/Bytecode/BytecodeOpInterface.h"

#define GET_OP_CLASSES
#include "Fifo/FifoOps.h.inc"

#endif // FIFO_FIFOOPS_H
