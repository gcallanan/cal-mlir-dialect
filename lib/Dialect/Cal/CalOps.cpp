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
///             output.
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
/// This templated function attempts to parse a list of arguments specified by
/// the given `keyword`, and ensures that each argument is of the expected port
/// type. If any argument's type does not match the expected `PortType`, an
/// error is emitted with a specified error message.
///
/// Template Parameter:
///   PortType - The type that the arguments are expected to have (e.g.,
///   OutputPortType or InputPortType).
///
/// Parameters:
///   parser   - The OpAsmParser used to parse the arguments.
///   args     - A vector to store the parsed arguments (either `ports_in` or
///              `ports_out`).
///   keyword  - The keyword in the ASM (e.g., "ports_in" or
///              "ports_out") to trigger parsing.
///   errorMsg - The error message to display
///   if any argument doesn't match the expected type.
///
/// Returns:
///   `success` if all arguments are of the expected type; otherwise, `failure`.
template <typename PortType>
ParseResult parseAndCheckPorts(OpAsmParser &parser,
                               SmallVectorImpl<OpAsmParser::Argument> &args,
                               StringRef keyword, StringRef errorMsg) {
  auto location = parser.getCurrentLocation();
  if (succeeded(parser.parseOptionalKeyword(keyword))) {
    if (failed(parser.parseArgumentList(args, OpAsmParser::Delimiter::Paren,
                                        /*allowType=*/true,
                                        /*allowAttrs=*/false)))
      return failure();

    for (auto &arg : args) {
      if (!mlir::isa<PortType>(arg.type)) {
        return parser.emitError(location, errorMsg);
      }
    }
  }
  return success();
}

ParseResult ActorOp::parse(OpAsmParser &parser, OperationState &result) {
  SmallVector<OpAsmParser::Argument> inVals, outVals, standardArgs;

  auto location = parser.getCurrentLocation();

  // Get the symbol name
  mlir::StringAttr symNameAttr;
  if (failed(
          parser.parseSymbolName(symNameAttr, "sym_name", result.attributes)))
    return failure();

  // Get list of arguments if they exist
  if (failed(parser.parseArgumentList(standardArgs,
                                      OpAsmParser::Delimiter::Paren,
                                      /*allowType=*/true,
                                      /*allowAttrs=*/false)))
    return failure();

  // Parse the input and output arguments.
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

  // Combine the input and output arguments into a single list
  SmallVector<OpAsmParser::Argument> entryArgs;
  entryArgs.reserve(inVals.size() + outVals.size() + standardArgs.size());
  entryArgs.append(standardArgs.begin(), standardArgs.end());
  entryArgs.append(inVals.begin(), inVals.end());
  entryArgs.append(outVals.begin(), outVals.end());

  // Attach the arguments to the region
  Region &bodyRegion = *result.addRegion();
  if (parser.parseRegion(bodyRegion, entryArgs,
                         /*enableNameShadowing=*/true))
    return failure();

  // Check that the last operations in a region are all of cal.action
  // auto beginIt = bodyRegion.op_begin();
  // auto endIt = bodyRegion.op_end();
  // bool firstActionFound = false;
  // for (auto it = beginIt; it != endIt; ++it) {
  //   Operation &op = *it; // reference to the operation
  //   if (llvm::isa<ActionOp>(op)) {
  //     firstActionFound = true; // first action found
  //   } else {
  //     if (firstActionFound) { // We found a non-action operation after an
  //     action
  //                             // operation
  //       return parser.emitError(
  //           location,
  //           "Expected all cal.action operations in the cal.actor to appear at
  //           " "the end of the region. In this cal.actor, some non-action "
  //           "operations were found after a cal.action operation.");
  //     }
  //   }
  // }

  // Here we perform a few checks to enforce that cal.actor body is formatted
  // how we expect it to be:
  // 1. If the last operation is a cal.execution_body then there can only be
  // one of these operations in the region (it must be last) and there
  // can be no cal.action operations in the actor.
  // 2. cal.action and cal.execution_body are mutually exclusive operations in a
  // cal.actor. If one is present, the other must not be present.
  // 3. cal.action operations must be the last operations in the region.
  auto beginIt = bodyRegion.op_begin();
  auto endIt = bodyRegion.op_end();
  bool executionBodyFound = false;
  bool firstActionFound = false;
  for (auto it = beginIt; it != endIt; ++it) {
    Operation &op = *it; // reference to the operation
    if (llvm::isa<ActionOp>(op)) {
      firstActionFound = true; // first action found
      if (executionBodyFound) {
        return parser.emitError(
            location,
            ". Within a cal.actor, there can either be a single cal.execution "
            "body or one or more cal.actions. Both of the operations may not "
            "appear in the same cal.actor.");
      }
    } else if (llvm::isa<ExecutionBody>(op)) {
      if (executionBodyFound) {
        return parser.emitError(
            location,
            ". The cal.execution_body operation in the cal.actor is "
            "required to be unique and the last operation in the region. You "
            "may not have more than one cal.execution_body in this region");
      }

      if (firstActionFound) {
        return parser.emitError(
            location,
            ". Within a cal.actor, there can either be a single cal.execution "
            "body or one or more cal.actions. Both of the operations may not "
            "appear in the same cal.actor.");
      }
      executionBodyFound = true; // first action found
    } else {
      if (executionBodyFound) { // We found a non-action operation after an
                                // action
                                // operation
        return parser.emitError(
            location, "The cal.execution_body operation in the cal.actor is "
                      "required to be the last operation in the region.");
      }
      if (firstActionFound) { // We found a non-action operation after an action
                              // operation
        return parser.emitError(
            location,
            "expected all cal.action operations in the cal.actor to appear at "
            "the end of the region. In this cal.actor, some non - action "
            "operations were found after a cal.action operation.");
      }
    }
  }

  return success();
}

void ActorOp::print(OpAsmPrinter &printer) {
  Operation *op = getOperation();
  auto actorName =
      op->getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName())
          .getValue();

  printer << ' ';
  printer.printSymbolName(actorName);

  // Print all non-port arguments if they exist
  SmallVector<Value> standardArgs;
  for (Value arg : getBody().getArguments()) {
    if (!mlir::isa<mlir::fifo::OutputPortType>(arg.getType()) &&
        !mlir::isa<mlir::fifo::InputPortType>(arg.getType())) {
      standardArgs.push_back(arg);
    }
  }

  printer << "(";
  if (standardArgs.size() > 0) {
    interleaveComma(standardArgs, printer, [&](Value v) {
      printer.printOperand(v);
      printer << ": ";
      printer.printType(v.getType());
    });
  }
  printer << ")";

  printer.increaseIndent();
  collectAndPrintArgumentsByType<mlir::fifo::OutputPortType>(
      printer, getBody().getArguments(), "ports_in");
  collectAndPrintArgumentsByType<mlir::fifo::InputPortType>(
      printer, getBody().getArguments(), "ports_out");
  printer.decreaseIndent();

  printer.printNewline();
  printer.printRegion(getBody(), /*printEntryBlockArgs=*/false,
                      /*printBlockTerminators=*/false);
  printer.printNewline();
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

  if (getOperation()->getParentOp()) {
    if (mlir::isa<ExecutionBody>(getOperation()->getParentOp())) {
      return emitOpError()
             << "cannot create state variable within cal.execution_body";
    } else if (mlir::isa<ActionOp>(getOperation()->getParentOp())) {
      return emitOpError() << "cannot create state variable within cal.action";
    } else if (mlir::isa<Predicate>(getOperation()->getParentOp())) {
      return emitOpError()
             << "cannot create state variable within cal.predicate";
    }
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

  if (mlir::isa<Predicate>(getOperation()->getParentOp())) {
    return emitOpError() << "cannot modify state variable within cal.predicate";
  }

  return success();
}

LogicalResult
CreateInstanceOp::verifySymbolUses(SymbolTableCollection &symbolTable) {

  // 1. Verify that this operation references a valid cal.actor
  FlatSymbolRefAttr actorRef = getActorRefAttr();
  ActorOp actor = symbolTable.lookupNearestSymbolFrom<ActorOp>(*this, actorRef);
  if (!actor)
    return emitOpError() << "'" << actorRef.getValue()
                         << "' does not reference a valid cal.actor";

  // 2. Verify that the number of operands matches the number of arguments in
  // the cal.actor
  auto actorArgs = actor.getBody().getArguments();
  auto operands = getOperands();
  if (operands.size() != actorArgs.size())
    return emitOpError() << "expected " << actorArgs.size()
                         << " operands, but got " << operands.size();

  // 3. Verify that the types of the operands match the types of the arguments
  // in the cal.actor.
  for (size_t i = 0; i < operands.size(); i++) {
    if (operands[i].getType() != actorArgs[i].getType()) {
      return emitOpError() << "operand type mismatch: expected "
                           << actorArgs[i].getType() << ", but got "
                           << operands[i].getType();
    }
  }

  return success();
}

/// Prints a labeled group of operands along with their types in a structured
/// format.
///
/// This function outputs a group of operands under a specified label (e.g.,
/// "ports_in", "ports_out"), formatting them as follows:
///
///   label (%operand1, %operand2, ...) : type1, type2, ...
///
/// If the operand list is empty, the function performs no action.
///
/// Parameters:
/// - `printer`: The MLIR assembly printer used to emit the output.
/// - `label`: A string label describing the operand group.
/// - `operands`: The list of operands to be printed.
///
/// Behavior:
/// - Outputs a newline followed by the label and an opening parenthesis.
/// - Prints the operands as a comma-separated list.
/// - Prints a colon followed by the types of each operand, also as a
/// comma-separated list.
/// - Closes the group with a closing parenthesis.
///
/// Example Output:
///   ports_in (%in1, %in2 : !fifo.output_port<i32>, !fifo.output_port<f32>)
void printOperandGroup(OpAsmPrinter &printer, StringRef label,
                       ArrayRef<Value> operands) {
  if (operands.empty())
    return;
  printer.printNewline();
  printer << label << " (";
  printer.printOperands(operands);
  printer << " : ";
  llvm::interleaveComma(operands, printer,
                        [&](Value v) { printer.printType(v.getType()); });
  printer << ")";
}

void CreateInstanceOp::print(OpAsmPrinter &printer) {
  // 1. Print the symbol name
  printer << " ";
  printer.printSymbolName(getActorRefAttr().getValue());

  // 2. Print the optional instance name if it exists
  if (getInstanceNameAttr()) {
    printer << " ";
    printer.printString(getInstanceNameAttr().getValue());
    printer << " ";
  }

  // 3. Sort the operands according to if they are ports or not
  SmallVector<Value> portsOut, portsIn, others;
  for (Value operand : getOperands()) {
    Type type = operand.getType();
    if (mlir::isa<fifo::InputPortType>(type))
      portsOut.push_back(operand);
    else if (mlir::isa<fifo::OutputPortType>(type))
      portsIn.push_back(operand);
    else
      others.push_back(operand);
  }

  // 3.1 Print out the standard operands
  printer << "(";
  if (!others.empty()) {
    printer.printOperands(others);
    printer << " : ";
    llvm::interleaveComma(others, printer,
                          [&](Value v) { printer.printType(v.getType()); });
  }
  printer << ")";

  printer.increaseIndent();
  printer.increaseIndent();
  // 3.2 Print out the ports_in
  printOperandGroup(printer, "ports_in", portsIn);
  // 3.3 Print out the ports_in
  printOperandGroup(printer, "ports_out", portsOut);
  printer.decreaseIndent();
  printer.decreaseIndent();
}

/// Parses an optional operand group with an associated type list and
/// validates each type against a provided constraint.
///
/// This function attempts to parse a group of operands prefixed by a specific
/// keyword (e.g., "ports_in", "ports_out"). The expected syntax is:
///
///   keyword (%operand1, %operand2, ...) : type1, type2, ...
///
/// - If the keyword is present:
///   - Parses the operand list enclosed in parentheses.
///   - If operands are present:
///     - Parses a colon followed by a comma-separated list of types.
///     - Validates each type using the provided `typeConstraint` function.
///   - Parses the closing parenthesis.
///
/// Parameters:
/// - `parser`: The MLIR assembly parser.
/// - `keyword`: The keyword indicating the start of the operand group.
/// - `operands`: Output vector to store the parsed operands.
/// - `types`: Output vector to store the parsed types.
/// - `typeConstraint`: A function that returns true if a type is valid.
/// - `typeConstraintMsg`: Error message to emit if a type fails validation.
///
/// Returns:
/// - `success()` if parsing and validation succeed.
/// - `failure()` if any parsing step fails or a type does not satisfy the
/// constraint.
static ParseResult
parseOperandGroup(OpAsmParser &parser, StringRef keyword,
                  SmallVectorImpl<OpAsmParser::UnresolvedOperand> &operands,
                  SmallVectorImpl<Type> &types,
                  llvm::function_ref<bool(Type)> typeConstraint,
                  StringRef typeConstraintMsg) {
  auto location = parser.getCurrentLocation();
  if (succeeded(parser.parseOptionalKeyword(keyword))) {
    if (failed(parser.parseLParen()) ||
        failed(parser.parseOperandList(operands, OpAsmParser::Delimiter::None)))
      return failure();

    if (!operands.empty()) {
      if (failed(parser.parseColon()) || failed(parser.parseTypeList(types)))
        return failure();
      for (Type &type : types) {
        if (!typeConstraint(type))
          return parser.emitError(location, typeConstraintMsg);
      }
    }
    if (failed(parser.parseRParen()))
      return failure();
  }
  return success();
}

ParseResult CreateInstanceOp::parse(OpAsmParser &parser,
                                    OperationState &result) {

  // 1. Parse the symbol name
  FlatSymbolRefAttr actorRef;
  if (failed(parser.parseAttribute<FlatSymbolRefAttr>(
          actorRef, /*type=*/{}, "actorRef", result.attributes)))
    return failure();

  // 2. Parse the optional instance name if it exists
  std::string instance_name;
  if (succeeded(parser.parseOptionalString(&instance_name))) {
    result.addAttribute("instanceName",
                        parser.getBuilder().getStringAttr(instance_name));
  }

  if (failed(parser.parseLParen()))
    return failure();

  // 3. Parse standard operands
  SmallVector<OpAsmParser::UnresolvedOperand> standardOperands;
  SmallVector<Type> standardTypes;
  if (failed(parser.parseOperandList(standardOperands,
                                     OpAsmParser::Delimiter::None)))
    return failure();

  if (!standardOperands.empty()) {
    if (failed(parser.parseColon()) ||
        failed(parser.parseTypeList(standardTypes)))
      return failure();
    for (Type &type : standardTypes) {
      if (mlir::isa<fifo::InputPortType>(type) ||
          mlir::isa<fifo::OutputPortType>(type))
        return parser.emitError(parser.getCurrentLocation(),
                                "standard arguments may not include fifo "
                                "input/output port types");
    }
  }

  if (failed(parser.parseRParen()))
    return failure();

  // 4. Parse ports_in
  SmallVector<OpAsmParser::UnresolvedOperand> portsIn;
  SmallVector<Type> portsInTypes;
  if (failed(parseOperandGroup(
          parser, "ports_in", portsIn, portsInTypes,
          [](Type t) { return mlir::isa<fifo::OutputPortType>(t); },
          "expected fifo.output_port<...> for ports_in")))
    return failure();

  // 5. Parse ports_out
  SmallVector<OpAsmParser::UnresolvedOperand> portsOut;
  SmallVector<Type> portsOutTypes;
  if (failed(parseOperandGroup(
          parser, "ports_out", portsOut, portsOutTypes,
          [](Type t) { return mlir::isa<fifo::InputPortType>(t); },
          "expected fifo.input_port<...> for ports_out")))
    return failure();

  // 6. Combine all operands and assign them to the result so that they can be
  // be used to constuct the operation
  SmallVector<OpAsmParser::UnresolvedOperand> allOperands;
  SmallVector<Type> allTypes;
  allOperands.append(standardOperands);
  allOperands.append(portsIn);
  allOperands.append(portsOut);
  allTypes.append(standardTypes);
  allTypes.append(portsInTypes);
  allTypes.append(portsOutTypes);

  return parser.resolveOperands(allOperands, allTypes, parser.getNameLoc(),
                                result.operands);
}

ParseResult ActionOp::parse(OpAsmParser &parser, OperationState &result) {
  // Optional string: actionName
  std::string action_name;
  if (succeeded(parser.parseOptionalString(&action_name))) {
    result.addAttribute("actionName",
                        parser.getBuilder().getStringAttr(action_name));
  }

  // Optional keyword "priority = <int>"
  if (succeeded(parser.parseOptionalKeyword("priority"))) {
    IntegerAttr priorityAttr;
    if (parser.parseEqual() ||
        parser.parseAttribute(priorityAttr, parser.getBuilder().getI32Type(),
                              "priority", result.attributes))
      return failure();
  }

  Region *body = result.addRegion();
  if (parser.parseRegion(*body, /*arguments=*/{}, /*argTypes=*/{}))
    return failure();

  return success();
}

void ActionOp::print(OpAsmPrinter &printer) {
  if (getActionNameAttr()) {
    printer << " ";
    printer.printString(getActionNameAttr().getValue());
  }

  if (getPriorityAttr()) {
    printer << " priority=" << getPriorityAttr().getValue();
  }

  printer.printNewline();
  printer.printRegion(getBody(), /*printEntryBlockArgs=*/false,
                      /*printBlockTerminators=*/false);
  printer.printNewline();
}

/// Verifies that the operations inside a `cal.action` body follow the correct
/// ordering constraints.
///
/// The expected ordering is:
///   1. `cal.predicate` operations
///   2. `fifo.pop` operations
///   3. `cal.set` (state update) operations
///   4. `fifo.push` operations
///
/// The function walks through the body of the `cal.action` block and enforces
/// that:
/// - All `cal.predicate` ops appear before any `fifo.pop`, `cal.set`, or
///   `fifo.push` ops.
/// - All `fifo.pop` ops appear before any `cal.set` or `fifo.push` ops.
/// - All `cal.set` ops appear before any `fifo.push` ops.
/// - `fifo.push` ops can only appear after all others.
///
/// If any of these constraints are violated, an error is emitted for the
/// `cal.action` operation.

LogicalResult ActionOp::verify() {
  enum Phase { predicateOps = 0, popOps = 1, setStateOps = 2, pushOps = 3 };

  Phase currentPhase = predicateOps;

  if (!getBody().empty()) {
    for (Operation &op : getBody().front()) {
      if (mlir::isa<cal::Predicate>(op)) {
        if (currentPhase > predicateOps) {
          return emitOpError()
                 << "cal.predicate operations must be before fifo.pop, "
                    "cal.set, and fifo.push operations in the body of the "
                    "cal.action";
        }
        currentPhase = predicateOps;
      } else if (mlir::isa<fifo::Pop>(op)) {
        if (currentPhase > popOps) {
          return emitOpError()
                 << "fifo.pop operations must be before cal.set and "
                    "fifo.push operations and after cal.predicate operations "
                    "in the body of the cal.action";
        }
        currentPhase = popOps;
      } else if (mlir::isa<cal::StateSetOp>(op)) {
        if (currentPhase > setStateOps) {
          return emitOpError()
                 << "cal.set operations must be after fifo.pop and "
                    "cal.predicate operations and before fifo.push operations "
                    "in the body of the cal.action";
        }
        currentPhase = setStateOps;
      } else if (mlir::isa<fifo::Push>(op)) {
        if (currentPhase > pushOps) {
          return emitOpError()
                 << "fifo.push operations must be the last operations "
                    "in the the body of the cal.action";
        }
        currentPhase = pushOps;
      }
    }
  }

  return success();
}

llvm::DenseMap<mlir::Value, int> ActionOp::getPortRates() {

  llvm::DenseMap<mlir::Value, int> portRates;
  for (auto pushOp : getOps<fifo::Push>()) {
    portRates[pushOp.getInputPort()] += 1;
  }

  for (auto popOp : getOps<fifo::Pop>()) {
    portRates[popOp.getOutputPort()] -= 1;
  }
  return portRates;
}
