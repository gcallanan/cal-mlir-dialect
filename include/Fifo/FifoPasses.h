//===- FifoPasses.h - Fifo passes  ------------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#ifndef FIFO_FIFOPASSES_H
#define FIFO_FIFOPASSES_H

#include "Fifo/FifoDialect.h"
#include "Fifo/FifoOps.h"
#include "mlir/Pass/Pass.h"
#include <memory>

namespace mlir {
namespace fifo {
#define GEN_PASS_DECL
#include "Fifo/FifoPasses.h.inc"

#define GEN_PASS_REGISTRATION
#include "Fifo/FifoPasses.h.inc"
} // namespace fifo
} // namespace mlir

#endif
