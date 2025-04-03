//===- FifoPasses.h - Fifo passes  ------------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#ifndef FIFO_FIFOPASSES_H
#define FIFO_FIFOPASSES_H

#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoOps.h"
#include "mlir/Pass/Pass.h"
#include <memory>

namespace mlir {
namespace fifo {

// These have to go before the "#define GEN_PASS_REGISTRATION" line or else
// we get an error - I have not yet figured out why
std::unique_ptr<mlir::Pass> createLowerFifoToMemrefPass();
std::unique_ptr<mlir::Pass> decomposeFifoTuples();
std::unique_ptr<mlir::Pass> lowerFifoPrintToLLVM();

#define GEN_PASS_DECL
#include "Dialect/Fifo/FifoPasses.h.inc"

#define GEN_PASS_REGISTRATION
#include "Dialect/Fifo/FifoPasses.h.inc"

} // namespace fifo
} // namespace mlir

#endif
