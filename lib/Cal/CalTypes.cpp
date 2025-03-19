//===- CalTypes.cpp - Cal dialect types -----------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Cal/CalTypes.h"

#include "Cal/CalDialect.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/DialectImplementation.h"
#include "llvm/ADT/TypeSwitch.h"

using namespace mlir::cal;

#define GET_TYPEDEF_CLASSES
#include "Cal/CalOpsTypes.cpp.inc"

void CalDialect::registerTypes() {
  addTypes<
#define GET_TYPEDEF_LIST
#include "Cal/CalOpsTypes.cpp.inc"
      >();
}
