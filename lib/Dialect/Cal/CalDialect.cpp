//===- CalDialect.cpp - Cal dialect ---------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalTypes.h"

using namespace mlir;
using namespace mlir::cal;

#include "Dialect/Cal/CalOpsDialect.cpp.inc"

//===----------------------------------------------------------------------===//
// Cal dialect.
//===----------------------------------------------------------------------===//

void CalDialect::initialize() {
  addOperations<
#define GET_OP_LIST
#include "Dialect/Cal/CalOps.cpp.inc"
      >();
  registerTypes();

  // Nothing extra to do here.
}
