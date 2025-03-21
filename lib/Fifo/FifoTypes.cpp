//===- FifoTypes.cpp - Fifo dialect types -----------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Fifo/FifoTypes.h"

#include "Fifo/FifoDialect.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/DialectImplementation.h"
#include "llvm/ADT/TypeSwitch.h"

using namespace mlir::fifo;

#define GET_TYPEDEF_CLASSES
#include "Fifo/FifoOpsTypes.cpp.inc"

void FifoDialect::registerTypes() {
  addTypes<
#define GET_TYPEDEF_LIST
#include "Fifo/FifoOpsTypes.cpp.inc"
      >();
}
