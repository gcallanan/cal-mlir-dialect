//===- CalOps.h - Cal dialect ops -----------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef CAL_CALOPS_H
#define CAL_CALOPS_H

#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/OpDefinition.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/Interfaces/InferTypeOpInterface.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"
#include "mlir/IR/SymbolTable.h"
#include "mlir/Bytecode/BytecodeOpInterface.h"

// Ensure custom CAL types (e.g., InstanceType) are visible to op declarations
#include "Dialect/Cal/CalTypes.h"

#define GET_OP_CLASSES
#include "Dialect/Cal/CalOps.h.inc"

namespace mlir {
class RewritePatternSet;
}

namespace mlir::cal {
// Register CAL-specific canonicalization patterns (including patterns
// anchored on non-CAL ops like scf.for that manipulate CAL constructs).
void populateCalCanonicalizationPatterns(mlir::RewritePatternSet &results);
}

#endif // CAL_CALOPS_H
