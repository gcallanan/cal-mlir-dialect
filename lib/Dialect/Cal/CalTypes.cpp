//===- CalTypes.cpp - Cal dialect types -----------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Dialect/Cal/CalTypes.h"

#include "Dialect/Cal/CalDialect.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/DialectImplementation.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/BuiltinAttributes.h"
#include "mlir/IR/AsmState.h"
#include "llvm/ADT/TypeSwitch.h"

using namespace mlir::cal;

#define GET_TYPEDEF_CLASSES
#include "Dialect/Cal/CalOpsTypes.cpp.inc"

void CalDialect::registerTypes() {
  addTypes<
#define GET_TYPEDEF_LIST
#include "Dialect/Cal/CalOpsTypes.cpp.inc"
      >();
}

//===----------------------------------------------------------------------===//
// Custom printers/parsers for ND instance array types with dynamic dims ('?')
// We encode dynamic dims as IntegerAttr(-1) in the stored ArrayAttr.
//===----------------------------------------------------------------------===//

namespace mlir::cal {

// Helper to print a shape ArrayAttr with '?' for -1
static void printNDShape(AsmPrinter &p, ArrayAttr shape) {
  p << "[";
  bool first = true;
  for (Attribute a : shape) {
    if (!first) p << ", ";
    first = false;
    if (auto ia = a.dyn_cast<IntegerAttr>()) {
      if (ia.getInt() == -1) {
        p << "?";
      } else {
        p << ia.getInt();
      }
    } else {
      // Fallback: print the attribute directly
      p.printAttribute(a);
    }
  }
  p << "]";
}

// Helper to parse a shape list of ints or '?' into an ArrayAttr with -1
static ParseResult parseNDShape(AsmParser &parser, SmallVectorImpl<Attribute> &dimsAttrs) {
  MLIRContext *ctx = parser.getContext();
  if (failed(parser.parseLSquare()))
    return failure();
  // Handle empty list
  if (succeeded(parser.parseOptionalRSquare()))
    return success();

  while (true) {
    // Try '?' first
    if (succeeded(parser.parseOptionalQuestion())) {
      dimsAttrs.push_back(IntegerAttr::get(IntegerType::get(ctx, 64), -1));
    } else {
      // Expect an integer
      int64_t val = 0;
      if (failed(parser.parseInteger(val)))
        return failure();
      dimsAttrs.push_back(IntegerAttr::get(IntegerType::get(ctx, 64), val));
    }
    if (succeeded(parser.parseOptionalRSquare()))
      break;
    if (failed(parser.parseComma()))
      return failure();
  }
  return success();
}

// InstanceArrayType custom parse/print
Type InstanceArrayType::parse(AsmParser &parser) {
  // Format: < @Actor , [d0, d1, ...] > with '?' allowed in shape
  FlatSymbolRefAttr actorRef;
  if (failed(parser.parseLess()) || failed(parser.parseAttribute(actorRef)))
    return Type();
  if (failed(parser.parseComma()))
    return Type();
  SmallVector<Attribute, 4> dimsAttrs;
  if (failed(parseNDShape(parser, dimsAttrs)))
    return Type();
  if (failed(parser.parseGreater()))
    return Type();
  auto shape = ArrayAttr::get(parser.getContext(), dimsAttrs);
  return InstanceArrayType::get(parser.getContext(), actorRef, shape);
}

void InstanceArrayType::print(AsmPrinter &printer) const {
  printer << "<";
  printer.printAttribute(getActorRef());
  printer << ", ";
  printNDShape(printer, getShape());
  printer << ">";
}

// InterfaceInstanceArrayType custom parse/print
Type InterfaceInstanceArrayType::parse(AsmParser &parser) {
  // Format: < @Iface , [d0, d1, ...] > with '?' allowed
  FlatSymbolRefAttr ifaceRef;
  if (failed(parser.parseLess()) || failed(parser.parseAttribute(ifaceRef)))
    return Type();
  if (failed(parser.parseComma()))
    return Type();
  SmallVector<Attribute, 4> dimsAttrs;
  if (failed(parseNDShape(parser, dimsAttrs)))
    return Type();
  if (failed(parser.parseGreater()))
    return Type();
  auto shape = ArrayAttr::get(parser.getContext(), dimsAttrs);
  return InterfaceInstanceArrayType::get(parser.getContext(), ifaceRef, shape);
}

void InterfaceInstanceArrayType::print(AsmPrinter &printer) const {
  printer << "<";
  printer.printAttribute(getIfaceRef());
  printer << ", ";
  printNDShape(printer, getShape());
  printer << ">";
}

} // namespace mlir::cal
