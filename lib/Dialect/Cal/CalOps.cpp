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
#include "mlir/IR/Block.h"
#include "mlir/IR/Region.h"

using namespace mlir;
using namespace mlir::cal;

#define GET_OP_CLASSES
#include "Dialect/Cal/CalOps.cpp.inc"

/// Prints a labeled list of block arguments whose types match a given MLIR
/// type.
///
/// This templated function filters the provided block arguments (`args`) to
/// include only those whose type matches the type `T`. If any matching
/// arguments are found, it prints them under the specified `label`, formatted
/// with indentation and type annotations using the provided `OpAsmPrinter`.
///
/// Template Parameter:
///   T - The MLIR type to filter arguments by (e.g., fifo::InputPortType).
///
/// Parameters:
///   printer - The printer used to emit the formatted output.
///   args    - The list of block arguments to filter and print.
///   label   - A string label (e.g., "ports_in") used as a prefix in the
///   output.
template <typename T>
void collectAndPrintArgumentsByType(OpAsmPrinter &printer,
                                    mlir::Block::BlockArgListType args,
                                    StringRef label) {
  SmallVector<Value> filteredArgs;
  for (Value arg : args) {
    if (mlir::isa<T>(arg.getType())) {
      filteredArgs.push_back(arg);
    }
  }

  if (filteredArgs.size() > 0) {
    printer.printNewline();
    printer << label << " (";
    printer.increaseIndent();
    interleaveComma(filteredArgs, printer, [&](Value v) {
      printer.printNewline();
      printer.printOperand(v);
      printer << ": ";
      printer.printType(v.getType());
    });
    printer.decreaseIndent();
    printer.printNewline();
    printer << ")";
  }
}

/// Parses a list of arguments and checks if they are of the expected port type.
///
/// This templated function attempts to parse a list of arguments specified by the
/// given `keyword`, and ensures that each argument is of the expected port type.
/// If any argument's type does not match the expected `PortType`, an error is emitted
/// with a specified error message.
///
/// Template Parameter:
///   PortType - The type that the arguments are expected to have (e.g., OutputPortType or InputPortType).
///
/// Parameters:
///   parser   - The OpAsmParser used to parse the arguments.
///   args     - A vector to store the parsed arguments (either `ports_in` or `ports_out`).
///   keyword  - The keyword in the ASM (e.g., "ports_in" or "ports_out") to trigger parsing.
///   errorMsg - The error message to display if any argument doesn't match the expected type.
///
/// Returns:
///   `success` if all arguments are of the expected type; otherwise, `failure`.
template <typename PortType>
ParseResult parseAndCheckPorts(OpAsmParser &parser,
                               SmallVectorImpl<OpAsmParser::Argument> &args,
                               StringRef keyword, StringRef errorMsg) {
  if (succeeded(parser.parseOptionalKeyword(keyword))) {
    if (parser.parseArgumentList(args, OpAsmParser::Delimiter::Paren,
                                 /*allowType=*/true,
                                 /*allowAttrs=*/false))
      return failure();

    for (auto &arg : args) {
      if (!mlir::isa<PortType>(arg.type)) {
        return parser.emitError(parser.getCurrentLocation(), errorMsg);
      }
    }
  }
  return success();
}

ParseResult ActorOp::parse(OpAsmParser &parser, OperationState &result) {
  SmallVector<OpAsmParser::Argument> inVals, outVals;

  mlir::StringAttr symNameAttr;
  if (parser.parseSymbolName(symNameAttr, "sym_name", result.attributes))
    return failure();

  if (failed(parseAndCheckPorts<mlir::fifo::OutputPortType>(
          parser, inVals, "ports_in",
          "expected OutputPortType (fifo.output_port<...>) for ports_in "
          "argument"))) {
    return failure();
  }

  if (failed(parseAndCheckPorts<mlir::fifo::InputPortType>(
          parser, outVals, "ports_out",
          "expected InputPortType (fifo.input_port<...>) for ports_out "
          "argument"))) {
    return failure();
  }

  SmallVector<OpAsmParser::Argument> entryArgs;
  entryArgs.reserve(inVals.size() + outVals.size());
  entryArgs.append(inVals.begin(), inVals.end());
  entryArgs.append(outVals.begin(), outVals.end());

  Region &bodyRegion = *result.addRegion();
  if (parser.parseRegion(bodyRegion, entryArgs,
                         /*enableNameShadowing=*/true))
    return failure();

  return success();
}

void ActorOp::print(OpAsmPrinter &printer) {
  Operation *op = getOperation();
  auto actorName =
      op->getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName())
          .getValue();

  printer << ' ';
  printer.printSymbolName(actorName);

  printer.increaseIndent();
  collectAndPrintArgumentsByType<mlir::fifo::OutputPortType>(
      printer, getBody().getArguments(), "ports_in");
  collectAndPrintArgumentsByType<mlir::fifo::InputPortType>(
      printer, getBody().getArguments(), "ports_out");
  printer.decreaseIndent();

  printer.printNewline();
  printer.printRegion(getBody(), /*printEntryBlockArgs=*/false,
                      /*printBlockTerminators=*/false);
}

LogicalResult CreateStateVarOp::verify() {
  Type stateRefType = getStateVarRef().getType();
  if (!mlir::isa<StateVarRefType>(stateRefType)) {
    return emitOpError() << "expected stateVarRef to be of type "
                            "StateVarRefType (!cal.state_ref<"
                         << getStateType() << ">), but got " << stateRefType;
  }

  StateVarRefType stateRef = mlir::cast<StateVarRefType>(stateRefType);
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

  if (!mlir::isa<StateVarRefType>(stateRefType)) {
    return emitOpError() << "expected stateVarRef to be of type "
                            "StateVarRefType (!cal.state_ref<"
                         << stateValueType << ">), but got " << stateRefType;
  }

  StateVarRefType stateRef = mlir::cast<StateVarRefType>(stateRefType);
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

  if (!mlir::isa<StateVarRefType>(stateRefType)) {
    return emitOpError() << "expected stateVarRef to be of type "
                            "StateVarRefType (!cal.state_ref<"
                         << stateValueType << ">), but got " << stateRefType;
  }

  StateVarRefType stateRef = mlir::cast<StateVarRefType>(stateRefType);
  if (stateRef.getStateType() != stateValueType) {
    return emitOpError() << "expected stateVarRef state type to be "
                         << stateValueType << ", but got "
                         << stateRef.getStateType();
  }

  return success();
}
