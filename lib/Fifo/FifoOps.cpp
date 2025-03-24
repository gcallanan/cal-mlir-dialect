//===- FifoOps.cpp - Fifo dialect ops ---------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Fifo/FifoOps.h"
#include "Fifo/FifoDialect.h"
#include "Fifo/FifoTypes.h"

using namespace mlir;
using namespace mlir::fifo;

#define GET_OP_CLASSES
#include "Fifo/FifoOps.cpp.inc"


LogicalResult CreateOp::verify()
{
    if(getBufferSize() <= 0){
        return emitOpError() << "CreateOp buffer size is " << std::to_string(getBufferSize()) <<" but must be greater than 0";
    }

    // I think that this error is picked up by the "parser", it may not be necessary to check it here
    if(getResults().size() != 2){
        return emitOpError() << "CreateOp must have 2 results";
    }

    Type inputPortType = getInputPort().getType();
    if (!inputPortType.isa<InputPortType>()) {
        return emitOpError() << "expected inputPort to be of type InputPortType (!fifo.input_port<"<< getElementType() <<">), but got " << inputPortType;
    }

    InputPortType inputPort = inputPortType.cast<InputPortType>();
    if (inputPort.getElementType() != getElementType()) {
        return emitOpError() << "expected inputPort element type to be " << getElementType() << ", but got " << inputPort.getElementType();
    }

    Type outputPortType = getOutputPort().getType();
    if (!outputPortType.isa<OutputPortType>()) {
        return emitOpError() << "expected outputPort to be of type OutputPortType (!fifo.output_port<"<< getElementType() <<">), but got " << outputPortType;
    }

    OutputPortType outputPort = outputPortType.cast<OutputPortType>();
    if (outputPort.getElementType() != getElementType()) {
        return emitOpError() << "expected outputPort element type to be " << getElementType() << ", but got " << outputPort.getElementType();
    }

    return success();
}
