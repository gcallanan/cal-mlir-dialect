//===- CalPasses.h - Cal passes  ------------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#ifndef CAL_CALPASSES_H
#define CAL_CALPASSES_H

#include "Cal/CalDialect.h"
#include "Cal/CalOps.h"
#include "mlir/Pass/Pass.h"
#include <memory>

namespace mlir {
namespace cal {
#define GEN_PASS_DECL
#include "Cal/CalPasses.h.inc"

#define GEN_PASS_REGISTRATION
#include "Cal/CalPasses.h.inc"
} // namespace cal
} // namespace mlir

#endif
