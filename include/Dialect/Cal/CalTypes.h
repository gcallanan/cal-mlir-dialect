//===- CalTypes.h - Cal dialect types -------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef CAL_CALTYPES_H
#define CAL_CALTYPES_H

#include "mlir/IR/BuiltinTypes.h"

#define GET_TYPEDEF_CLASSES
#include "Dialect/Cal/CalOpsTypes.h.inc"

#endif // CAL_CALTYPES_H
