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

//===----------------------------------------------------------------------===//
// VariantType custom parse/print and verification
//===----------------------------------------------------------------------===//

// Format: !cal.variant<"TypeName", [("VariantName", [field_types...]), ...]>
// Example: !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>

Type VariantType::parse(AsmParser &parser) {
  MLIRContext *ctx = parser.getContext();

  if (failed(parser.parseLess()))
    return Type();

  // Parse the type name as a string
  std::string typeName;
  if (failed(parser.parseString(&typeName)))
    return Type();

  if (failed(parser.parseComma()))
    return Type();

  // Parse the variants list: [("Name", [types...]), ...]
  SmallVector<Attribute, 4> variantAttrs;
  if (failed(parser.parseLSquare()))
    return Type();

  // Handle empty list
  if (succeeded(parser.parseOptionalRSquare())) {
    auto variants = ArrayAttr::get(ctx, variantAttrs);
    if (failed(parser.parseGreater()))
      return Type();
    return VariantType::get(ctx, typeName, variants);
  }

  while (true) {
    // Parse each variant: ("VariantName", [field_types...])
    if (failed(parser.parseLParen()))
      return Type();

    std::string variantName;
    if (failed(parser.parseString(&variantName)))
      return Type();

    if (failed(parser.parseComma()))
      return Type();

    // Parse field types list
    SmallVector<Attribute, 4> fieldTypeAttrs;
    if (failed(parser.parseLSquare()))
      return Type();

    if (failed(parser.parseOptionalRSquare())) {
      // Non-empty field list
      while (true) {
        Type fieldType;
        if (failed(parser.parseType(fieldType)))
          return Type();
        fieldTypeAttrs.push_back(TypeAttr::get(fieldType));

        if (succeeded(parser.parseOptionalRSquare()))
          break;
        if (failed(parser.parseComma()))
          return Type();
      }
    }

    if (failed(parser.parseRParen()))
      return Type();

    // Create a DictionaryAttr for this variant
    SmallVector<NamedAttribute, 2> variantDict;
    variantDict.push_back(
        NamedAttribute(StringAttr::get(ctx, "name"), StringAttr::get(ctx, variantName)));
    variantDict.push_back(
        NamedAttribute(StringAttr::get(ctx, "fields"), ArrayAttr::get(ctx, fieldTypeAttrs)));
    variantAttrs.push_back(DictionaryAttr::get(ctx, variantDict));

    if (succeeded(parser.parseOptionalRSquare()))
      break;
    if (failed(parser.parseComma()))
      return Type();
  }

  if (failed(parser.parseGreater()))
    return Type();

  auto variants = ArrayAttr::get(ctx, variantAttrs);
  return VariantType::get(ctx, typeName, variants);
}

void VariantType::print(AsmPrinter &printer) const {
  printer << "<\"" << getName() << "\", [";
  bool firstVariant = true;
  for (Attribute attr : getVariants()) {
    if (!firstVariant)
      printer << ", ";
    firstVariant = false;

    auto variantDict = attr.cast<DictionaryAttr>();
    auto variantName = variantDict.getAs<StringAttr>("name").getValue();
    auto fields = variantDict.getAs<ArrayAttr>("fields");

    printer << "(\"" << variantName << "\", [";
    bool firstField = true;
    for (Attribute fieldAttr : fields) {
      if (!firstField)
        printer << ", ";
      firstField = false;
      printer << fieldAttr.cast<TypeAttr>().getValue();
    }
    printer << "])";
  }
  printer << "]>";
}

LogicalResult VariantType::verify(function_ref<InFlightDiagnostic()> emitError,
                                  StringRef name, ArrayAttr variants) {
  if (name.empty())
    return emitError() << "variant type name cannot be empty";

  llvm::SmallDenseSet<StringRef> variantNames;
  for (Attribute attr : variants) {
    auto variantDict = attr.dyn_cast<DictionaryAttr>();
    if (!variantDict)
      return emitError() << "each variant must be a dictionary attribute";

    auto variantNameAttr = variantDict.getAs<StringAttr>("name");
    if (!variantNameAttr)
      return emitError() << "variant missing 'name' attribute";

    StringRef variantName = variantNameAttr.getValue();
    if (variantName.empty())
      return emitError() << "variant name cannot be empty";

    if (!variantNames.insert(variantName).second)
      return emitError() << "duplicate variant name: " << variantName;

    auto fieldsAttr = variantDict.getAs<ArrayAttr>("fields");
    if (!fieldsAttr)
      return emitError() << "variant '" << variantName << "' missing 'fields' attribute";

    for (Attribute fieldAttr : fieldsAttr) {
      if (!fieldAttr.isa<TypeAttr>())
        return emitError() << "variant '" << variantName
                           << "' has invalid field type attribute";
    }
  }

  return success();
}

//===----------------------------------------------------------------------===//
// ProductType custom parse/print and verification
//===----------------------------------------------------------------------===//

// Format: !cal.product<"TypeName", [("fieldName", type), ...]>
// Example: !cal.product<"Vec2", [("x", i32), ("y", i32)]>

Type ProductType::parse(AsmParser &parser) {
  MLIRContext *ctx = parser.getContext();

  if (failed(parser.parseLess()))
    return Type();

  // Parse the type name as a string
  std::string typeName;
  if (failed(parser.parseString(&typeName)))
    return Type();

  if (failed(parser.parseComma()))
    return Type();

  // Parse the fields list: [("name", type), ...]
  SmallVector<Attribute, 4> fieldAttrs;
  if (failed(parser.parseLSquare()))
    return Type();

  // Handle empty list
  if (succeeded(parser.parseOptionalRSquare())) {
    auto fields = ArrayAttr::get(ctx, fieldAttrs);
    if (failed(parser.parseGreater()))
      return Type();
    return ProductType::get(ctx, typeName, fields);
  }

  while (true) {
    // Parse each field: ("fieldName", type)
    if (failed(parser.parseLParen()))
      return Type();

    std::string fieldName;
    if (failed(parser.parseString(&fieldName)))
      return Type();

    if (failed(parser.parseComma()))
      return Type();

    Type fieldType;
    if (failed(parser.parseType(fieldType)))
      return Type();

    if (failed(parser.parseRParen()))
      return Type();

    // Create a DictionaryAttr for this field
    SmallVector<NamedAttribute, 2> fieldDict;
    fieldDict.push_back(
        NamedAttribute(StringAttr::get(ctx, "name"), StringAttr::get(ctx, fieldName)));
    fieldDict.push_back(
        NamedAttribute(StringAttr::get(ctx, "type"), TypeAttr::get(fieldType)));
    fieldAttrs.push_back(DictionaryAttr::get(ctx, fieldDict));

    if (succeeded(parser.parseOptionalRSquare()))
      break;
    if (failed(parser.parseComma()))
      return Type();
  }

  if (failed(parser.parseGreater()))
    return Type();

  auto fields = ArrayAttr::get(ctx, fieldAttrs);
  return ProductType::get(ctx, typeName, fields);
}

void ProductType::print(AsmPrinter &printer) const {
  printer << "<\"" << getName() << "\", [";
  bool first = true;
  for (Attribute attr : getFields()) {
    if (!first)
      printer << ", ";
    first = false;

    auto fieldDict = attr.cast<DictionaryAttr>();
    auto fieldName = fieldDict.getAs<StringAttr>("name").getValue();
    auto fieldType = fieldDict.getAs<TypeAttr>("type").getValue();

    printer << "(\"" << fieldName << "\", " << fieldType << ")";
  }
  printer << "]>";
}

LogicalResult ProductType::verify(function_ref<InFlightDiagnostic()> emitError,
                                  StringRef name, ArrayAttr fields) {
  if (name.empty())
    return emitError() << "product type name cannot be empty";

  llvm::SmallDenseSet<StringRef> fieldNames;
  for (Attribute attr : fields) {
    auto fieldDict = attr.dyn_cast<DictionaryAttr>();
    if (!fieldDict)
      return emitError() << "each field must be a dictionary attribute";

    auto fieldNameAttr = fieldDict.getAs<StringAttr>("name");
    if (!fieldNameAttr)
      return emitError() << "field missing 'name' attribute";

    StringRef fieldName = fieldNameAttr.getValue();
    if (fieldName.empty())
      return emitError() << "field name cannot be empty";

    if (!fieldNames.insert(fieldName).second)
      return emitError() << "duplicate field name: " << fieldName;

    auto fieldTypeAttr = fieldDict.getAs<TypeAttr>("type");
    if (!fieldTypeAttr)
      return emitError() << "field '" << fieldName << "' missing 'type' attribute";
  }

  return success();
}

} // namespace mlir::cal
