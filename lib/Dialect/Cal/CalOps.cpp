//===- CalOps.cpp - Cal dialect ops ---------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalTypes.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoTypes.h"

using namespace mlir;
using namespace mlir::cal;

#define GET_OP_CLASSES
#include "Dialect/Cal/CalOps.cpp.inc"

LogicalResult CreateStateVarOp::verify() {
  Type stateRefType = getStateVarRef().getType();
  if (!stateRefType.isa<StateVarRefType>()) {
    return emitOpError() << "expected stateVarRef to be of type "
                            "StateVarRefType (!cal.state_ref<"
                         << getStateType() << ">), but got " << stateRefType;
  }

  StateVarRefType stateRef = stateRefType.cast<StateVarRefType>();
  if (stateRef.getStateType() != getStateType()) {
    return emitOpError() << "expected stateVarRef state type to be "
                         << getStateType() << ", but got "
                         << stateRef.getStateType();
  }

  return success();
}

LogicalResult StateGetOp::verify() {
  Type stateValueType = getStateValue().getType();
  Type stateRefType = getStateRef().getType();

  if (!stateRefType.isa<StateVarRefType>()) {
    return emitOpError() << "expected stateVarRef to be of type "
                            "StateVarRefType (!cal.state_ref<"
                         << stateValueType << ">), but got " << stateRefType;
  }

  StateVarRefType stateRef = stateRefType.cast<StateVarRefType>();
  if (stateRef.getStateType() != stateValueType) {
    return emitOpError() << "expected stateVarRef state type to be "
                         << stateValueType << ", but got "
                         << stateRef.getStateType();
  }

  return success();
}

LogicalResult StateSetOp::verify() {
  Type stateValueType = getStateValue().getType();
  Type stateRefType = getStateRef().getType();

  if (!stateRefType.isa<StateVarRefType>()) {
    return emitOpError() << "expected stateVarRef to be of type "
                            "StateVarRefType (!cal.state_ref<"
                         << stateValueType << ">), but got " << stateRefType;
  }

  StateVarRefType stateRef = stateRefType.cast<StateVarRefType>();
  if (stateRef.getStateType() != stateValueType) {
    return emitOpError() << "expected stateVarRef state type to be "
                         << stateValueType << ", but got "
                         << stateRef.getStateType();
  }

  return success();
}
