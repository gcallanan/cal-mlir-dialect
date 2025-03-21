//===- FifoDialect.cpp - Fifo dialect ---------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Fifo/FifoDialect.h"
#include "Fifo/FifoOps.h"
#include "Fifo/FifoTypes.h"

using namespace mlir;
using namespace mlir::fifo;

#include "Fifo/FifoOpsDialect.cpp.inc"

//===----------------------------------------------------------------------===//
// Fifo dialect.
//===----------------------------------------------------------------------===//

void FifoDialect::initialize() {
  addOperations<
#define GET_OP_LIST
#include "Fifo/FifoOps.cpp.inc"
      >();
  registerTypes();
}
