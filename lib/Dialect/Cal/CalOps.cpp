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
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/Block.h"
#include "mlir/IR/Region.h"

using namespace mlir;
using namespace mlir::cal;

#define GET_OP_CLASSES
#include "Dialect/Cal/CalOps.cpp.inc"

// Custom assembly for cal.connect (explicit handle form)
mlir::ParseResult ConnectOp::parse(OpAsmParser &parser, OperationState &result) {
  OpAsmParser::UnresolvedOperand srcOperand, dstOperand;
  Type srcTy, dstTy;
  StringAttr srcPortAttr, dstPortAttr;

  // %src : type
  if (parser.parseOperand(srcOperand) || parser.parseColon() ||
      parser.parseType(srcTy))
    return failure();

  // "srcPort"
  if (parser.parseAttribute(srcPortAttr))
    return failure();

  // ->
  if (parser.parseArrow())
    return failure();

  // %dst : type
  if (parser.parseOperand(dstOperand) || parser.parseColon() ||
      parser.parseType(dstTy))
    return failure();

  // "dstPort"
  if (parser.parseAttribute(dstPortAttr))
    return failure();

  // Optional: capacity(<i64>)
  IntegerAttr capacityAttr;
  if (succeeded(parser.parseOptionalKeyword("capacity"))) {
    if (parser.parseLParen() || parser.parseAttribute(capacityAttr) ||
        parser.parseRParen())
      return failure();
    result.addAttribute("capacity", capacityAttr);
  }

  // Optional extra attributes
  (void)parser.parseOptionalAttrDict(result.attributes);

  // Resolve operands
  if (parser.resolveOperand(srcOperand, srcTy, result.operands) ||
      parser.resolveOperand(dstOperand, dstTy, result.operands))
    return failure();

  // Set required attributes
  result.addAttribute("srcPort", srcPortAttr);
  result.addAttribute("dstPort", dstPortAttr);

  return success();
}

void ConnectOp::print(OpAsmPrinter &printer) {
  printer << ' ';
  printer.printOperand(getSrcHandle());
  printer << " : ";
  printer.printType(getSrcHandle().getType());
  printer << ' ';
  printer.printAttributeWithoutType(getSrcPortAttr());
  printer << " -> ";
  printer.printOperand(getDstHandle());
  printer << " : ";
  printer.printType(getDstHandle().getType());
  printer << ' ';
  printer.printAttributeWithoutType(getDstPortAttr());
  if (auto cap = getCapacityAttr()) {
    printer << " capacity(" << cap.getInt() << ")";
  }
  printer.printOptionalAttrDict(getOperation()->getAttrs(),
                                {"srcPort", "dstPort", "capacity"});
}

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
    "expected fifo.output_port<...> for ports_in argument"))) {
    return failure();
  }

  if (failed(parseAndCheckPorts<mlir::fifo::InputPortType>(
    parser, outVals, "ports_out",
    "expected fifo.input_port<...> for ports_out argument"))) {
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
      op->getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName()).getValue();
  printer << ' ';
  printer.printSymbolName(actorName);

  // Separate parameters vs ports.
  SmallVector<Value> params;
  for (Value arg : getBody().getArguments()) {
    if (!mlir::isa<mlir::fifo::OutputPortType>(arg.getType()) &&
        !mlir::isa<mlir::fifo::InputPortType>(arg.getType())) {
      params.push_back(arg);
    }
  }

  printer << '(';
  if (!params.empty()) {
    interleaveComma(params, printer, [&](Value v) {
      printer.printOperand(v);
      printer << ": ";
      printer.printType(v.getType());
    });
  }
  printer << ')';

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

//===----------------------------------------------------------------------===//
// Cal_NetworkOp (symbolic hierarchical network)
//===----------------------------------------------------------------------===//

ParseResult NetworkOp::parse(OpAsmParser &parser, OperationState &result) {
  SmallVector<OpAsmParser::Argument> inVals, outVals, standardArgs;

  auto location = parser.getCurrentLocation();

  // Parse symbol name @id
  StringAttr symNameAttr;
  if (failed(parser.parseSymbolName(symNameAttr, "sym_name", result.attributes)))
    return failure();

  // Parse parameter list (may be empty but required parens for consistency)
  if (failed(parser.parseArgumentList(standardArgs, OpAsmParser::Delimiter::Paren,
                                      /*allowType=*/true, /*allowAttrs=*/false)))
    return failure();

  // Reuse helper for ports
  if (failed(parseAndCheckPorts<mlir::fifo::OutputPortType>(
          parser, inVals, "ports_in",
          "expected fifo.output_port<...> for ports_in argument")))
    return failure();

  if (failed(parseAndCheckPorts<mlir::fifo::InputPortType>(
          parser, outVals, "ports_out",
          "expected fifo.input_port<...> for ports_out argument")))
    return failure();

  // Combine args in canonical order: params, ports_in, ports_out
  SmallVector<OpAsmParser::Argument> entryArgs;
  entryArgs.reserve(standardArgs.size() + inVals.size() + outVals.size());
  entryArgs.append(standardArgs.begin(), standardArgs.end());
  entryArgs.append(inVals.begin(), inVals.end());
  entryArgs.append(outVals.begin(), outVals.end());

  Region &bodyRegion = *result.addRegion();
  if (parser.parseRegion(bodyRegion, entryArgs, /*enableNameShadowing=*/true))
    return failure();

  // (Future) Verification can enforce only allowed ops / no nested networks yet
  // For now rely on general symbol / operand verification elsewhere.
  (void)location;
  return success();
}

void NetworkOp::print(OpAsmPrinter &printer) {
  Operation *op = getOperation();
  auto netName =
      op->getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName()).getValue();
  printer << ' ';
  printer.printSymbolName(netName);

  // Separate parameters vs ports (similar logic to ActorOp)
  SmallVector<Value> params;
  for (Value arg : getBody().getArguments()) {
    if (!mlir::isa<mlir::fifo::OutputPortType>(arg.getType()) &&
        !mlir::isa<mlir::fifo::InputPortType>(arg.getType())) {
      params.push_back(arg);
    }
  }

  printer << '(';
  if (!params.empty()) {
    interleaveComma(params, printer, [&](Value v) {
      printer.printOperand(v);
      printer << ": ";
      printer.printType(v.getType());
    });
  }
  printer << ')';

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

int NetworkOp::inDegree() {
  int portsIn = 0;
  for (Value arg : getBody().getArguments()) {
    if (mlir::isa<mlir::fifo::OutputPortType>(arg.getType()))
      portsIn++;
  }
  return portsIn;
}

int NetworkOp::outDegree() {
  int portsOut = 0;
  for (Value arg : getBody().getArguments()) {
    if (mlir::isa<mlir::fifo::InputPortType>(arg.getType()))
      portsOut++;
  }
  return portsOut;
}

LogicalResult NetworkOp::verify() {
  // Rule 1: Body must have exactly one block (ensured by parser but double-check)
  if (!getBody().hasOneBlock())
    return emitOpError() << "expected network region to have exactly one block";

  // Allowed top-level ops inside a network (structural / instantiation)
  // We allow: fifo.create / print / print_tensor, arith.constant, cal.create_instance,
  // other cal.network will appear only as symbol definitions (not nested definitions),
  // but disallow cal.actor definitions inside a network region.
  static llvm::DenseSet<llvm::StringRef> allowedDialectPrefixes = {
      "arith", "fifo", "cal"};

  for (Operation &op : getBody().front()) {
    if (llvm::isa<NetworkOp>(op))
      return emitOpError() << "nested cal.network definitions are not allowed; define networks at top module scope";
    if (llvm::isa<ActorOp>(op))
      return emitOpError() << "actor definitions are not permitted inside a cal.network";
    StringRef dialectNs = op.getDialect()->getNamespace();
    if (!allowedDialectPrefixes.contains(dialectNs))
      return emitOpError() << "operation from unsupported dialect '" << dialectNs << "' inside cal.network";
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

LogicalResult CreateStateVarOp::verify() {
  // The result must be a !cal.state_ref<T> and the type parameter must match.
  Type resTy = getStateVarRef().getType();
  if (!mlir::isa<StateVarRefType>(resTy))
    return emitOpError() << "result must be !cal.state_ref<...>, but got "
                         << resTy;

  auto refTy = mlir::cast<StateVarRefType>(resTy);
  Type declared = getStateType();
  if (refTy.getStateType() != declared)
    return emitOpError() << "state_ref element type (" << refTy.getStateType()
                         << ") does not match declared <" << declared << ">";
  return success();
}

//===----------------------------------------------------------------------===//
// Verifiers for symbolic construction ops
//===----------------------------------------------------------------------===//

LogicalResult InstantiateArrayOp::verify() {
  // Result type must be !cal.instance.array<actorRef, count>
  Type resTy = getHandlesArray().getType();
  auto arrTy = mlir::dyn_cast<InstanceArrayType>(resTy);
  if (!arrTy)
    return emitOpError() << "result must be !cal.instance.array<@Actor, N>, got " << resTy;

  // Check actor symbol matches
  if (arrTy.getActorRef() != getActorRefAttr())
    return emitOpError() << "result actor '" << arrTy.getActorRef()
                         << "' does not match attribute '" << getActorRefAttr() << "'";

  // Check count matches
  if (static_cast<uint64_t>(arrTy.getCount()) != getCount())
    return emitOpError() << "result count " << arrTy.getCount()
                         << " does not match attribute count " << getCount();

  // Base name, if present, must be non-empty
  if (auto bn = getBaseNameAttr(); bn && bn.getValue().empty())
    return emitOpError() << "basename, if provided, must be non-empty";

  return success();
}

LogicalResult InstanceAtOp::verify() {
  // Array must be an instance array; result is an instance of the same actor.
  auto arrayTy = mlir::dyn_cast<InstanceArrayType>(getArray().getType());
  if (!arrayTy)
    return emitOpError() << "array must be !cal.instance.array<@Actor, N>";

  auto handleTy = mlir::dyn_cast<InstanceType>(getHandle().getType());
  if (!handleTy)
    return emitOpError() << "result must be !cal.instance<@Actor>";

  if (arrayTy.getActorRef() != handleTy.getActorRef())
    return emitOpError() << "actor mismatch between array and result: "
                         << arrayTy.getActorRef() << " vs " << handleTy.getActorRef();

  // If the index is a constant, ensure it is within bounds.
  if (auto c = getIndex().getDefiningOp<arith::ConstantOp>()) {
    Attribute val = c.getValueAttr();
    if (auto intAttr = mlir::dyn_cast<IntegerAttr>(val)) {
      // Accept both index-typed and integer attributes.
      int64_t idx = intAttr.getInt();
  if (idx < 0 || static_cast<uint64_t>(idx) >= static_cast<uint64_t>(arrayTy.getCount()))
        return emitOpError() << "constant index " << idx << " out of bounds [0,"
             << arrayTy.getCount() << ")";
    }
  }

  return success();
}

LogicalResult ConnectOp::verify() {
  // Port names must be non-empty.
  if (getSrcPortAttr().getValue().empty() || getDstPortAttr().getValue().empty())
    return emitOpError() << "port names must be non-empty";

  // Optional capacity must be non-negative if present.
  if (auto cap = getCapacityAttr()) {
    if (cap.getInt() < 0)
      return emitOpError() << "capacity, if provided, must be >= 0";
  }
  return success();
}

LogicalResult CreateInstanceOp::verifySymbolUses(
    SymbolTableCollection &symbolTable) {
  FlatSymbolRefAttr targetRef = getActorRefAttr();

  // Try resolve as Actor first
  if (auto actor =
          symbolTable.lookupNearestSymbolFrom<ActorOp>(*this, targetRef)) {
    auto formalArgs = actor.getBody().getArguments();
    auto actuals = getOperands();
    // Fast fail on count mismatch with focused diagnostic.
    if (actuals.size() != formalArgs.size()) {
      return emitOpError()
             << "operand count mismatch: expected " << formalArgs.size()
             << " operands (actor params+ports), but got " << actuals.size();
    }
    for (size_t i = 0; i < actuals.size(); ++i) {
      if (actuals[i].getType() != formalArgs[i].getType()) {
        return emitOpError()
               << "operand type mismatch for operand " << i << ": expected "
               << formalArgs[i].getType() << ", but got "
               << actuals[i].getType();
      }
    }
    return success();
  }

  // Try resolve as Network next
  if (auto network =
          symbolTable.lookupNearestSymbolFrom<NetworkOp>(*this, targetRef)) {
    auto formalArgs = network.getBody().getArguments();
    auto actuals = getOperands();
    if (actuals.size() != formalArgs.size()) {
      return emitOpError()
             << "operand count mismatch: expected " << formalArgs.size()
             << " operands (network params+ports), but got " << actuals.size();
    }
    for (size_t i = 0; i < actuals.size(); ++i) {
      if (actuals[i].getType() != formalArgs[i].getType()) {
        return emitOpError()
               << "operand type mismatch for operand " << i << ": expected "
               << formalArgs[i].getType() << ", but got "
               << actuals[i].getType();
      }
    }
    return success();
  }

  return emitOpError() << "'" << targetRef.getValue()
                       << "' does not reference a valid cal.actor or cal.network";
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
    "expected fifo.output_port<...> for ports_in argument")))
    return failure();

  // 5. Parse ports_out
  SmallVector<OpAsmParser::UnresolvedOperand> portsOut;
  SmallVector<Type> portsOutTypes;
  if (failed(parseOperandGroup(
    parser, "ports_out", portsOut, portsOutTypes,
    [](Type t) { return mlir::isa<fifo::InputPortType>(t); },
    "expected fifo.input_port<...> for ports_out argument")))
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

llvm::MapVector<mlir::Value, int> ActionOp::getPortRates() {

  llvm::MapVector<mlir::Value, int> portRates;
  for (auto pushOp : getOps<fifo::Push>()) {
    portRates[pushOp.getInputPort()] += 1;
  }

  for (auto popOp : getOps<fifo::Pop>()) {
    portRates[popOp.getOutputPort()] -= 1;
  }
  return portRates;
}

int ActorOp::inDegree() {
  int portsIn = 0;
  for (Value arg : getBody().getArguments()) {
    if (mlir::isa<mlir::fifo::OutputPortType>(arg.getType())) {
      portsIn++;
    }
  }
  return portsIn;
}

int ActorOp::outDegree() {
  int portsOut = 0;
  for (Value arg : getBody().getArguments()) {
    if (mlir::isa<mlir::fifo::InputPortType>(arg.getType())) {
      portsOut++;
    }
  }
  return portsOut;
}

bool ActorOp::isSimpleActor() {
  if (inDegree() != 1) {
    return false; // Need to have 1 port in to be a simple actor
  }

  if (outDegree() != 1) {
    return false; // Need to have 1 port out to be a simple actor
  }

  int actionCount = 0;
  cal::ActionOp savedActionOp;
  for (Operation &op : getBody().getOps()) {
    if (auto actionOp = llvm::dyn_cast<ActionOp>(&op)) {
      actionCount++;
      savedActionOp = actionOp;
    }
  }

  if (actionCount != 1) {
    return false; // Need to have exactly one action in the actor to be a simple
                  // actor
  }

  // Check that all port rates are either +1 or -1
  llvm::MapVector<mlir::Value, int> portRates = savedActionOp.getPortRates();
  for (const auto &entry : portRates) {
    int rate = entry.second;
    if (rate != 1 && rate != -1) {
      return false; // Port rate must be exactly +1 or -1 for a simple actor
    }
  }

  // (no predicate count needed here)
  for (Operation &op : savedActionOp.getBody().getOps()) {
    if (llvm::isa<cal::Predicate>(op)) {
      return false; // If any predicate is present in the action body, it is not a
                    // simple actor
    }
  }

  return true;
}

cal::ActorOp CreateInstanceOp::getActor() {
  FlatSymbolRefAttr actorRef = getActorRefAttr();
  SymbolTableCollection symbolTable;
  ActorOp actor = symbolTable.lookupNearestSymbolFrom<ActorOp>(*this, actorRef);
  if (!actor) {
    emitOpError() << "'" << actorRef.getValue()
                  << "' does not reference a valid cal.actor";
    return nullptr;
  }
  return actor;
}

// NOTE: verification for future array/connect ops will be added once those
// ops are fully integrated via TableGen generation.

