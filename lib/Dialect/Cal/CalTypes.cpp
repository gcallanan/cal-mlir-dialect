//===- CalTypes.cpp - Cal dialect types -----------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Dialect/Cal/CalTypes.h"

#include "Dialect/Cal/CalDialect.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/DialectImplementation.h"
#include "llvm/ADT/TypeSwitch.h"

using namespace mlir::cal;

#define GET_TYPEDEF_CLASSES
#include "Dialect/Cal/CalOpsTypes.cpp.inc"

void CalDialect::registerTypes() {
  addTypes<
#define GET_TYPEDEF_LIST
#include "Dialect/Cal/CalOpsTypes.cpp.inc"
      >();
}
