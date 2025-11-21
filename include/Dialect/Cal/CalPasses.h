//===- CalPasses.h - Cal passes  ------------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#ifndef CAL_CALPASSES_H
#define CAL_CALPASSES_H

#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "mlir/Dialect/ControlFlow/IR/ControlFlow.h"
#include "mlir/Pass/Pass.h"
#include <memory>

namespace mlir {
namespace cal {

std::unique_ptr<mlir::Pass> convertCalActionsToExecutionBodies();
std::unique_ptr<mlir::Pass> hoistCalStateOutOfActor();
std::unique_ptr<mlir::Pass> insertCalPortPredicates();
std::unique_ptr<mlir::Pass> lowerCalFsmToExecutionBody();
// Infers static shapes for dynamic memref state variables where possible.
std::unique_ptr<mlir::Pass> inferCalDynamicStateShapes();

void populateHoistCalStateOutOfActorPatterns(RewritePatternSet &patterns);

#define GEN_PASS_DECL
#include "Dialect/Cal/CalPasses.h.inc"

#define GEN_PASS_REGISTRATION
#include "Dialect/Cal/CalPasses.h.inc"
} // namespace cal
} // namespace mlir

#endif
