//===- CalPassesDetectRecursiveTypes.cpp ----------------------*- C++ -*-===//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//===----------------------------------------------------------------------===//
//
// This pass detects recursive algebraic types (variants and products) and
// marks operations that use them. This information is used by subsequent
// passes to determine memory management strategy (boxing vs inline storage).
//
//===----------------------------------------------------------------------===//

#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalPasses.h"
#include "Dialect/Cal/CalTypes.h"
#include "Dialect/Fifo/FifoOps.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/PatternMatch.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/StringMap.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/StringSet.h"

namespace mlir::cal {
#define GEN_PASS_DEF_DETECTRECURSIVETYPES
#include "Dialect/Cal/CalPasses.h.inc"

namespace {

//===----------------------------------------------------------------------===//
// Type Analysis Utilities
//===----------------------------------------------------------------------===//

/// Get a unique identifier for an algebraic type (variant or product).
/// Returns empty string for non-algebraic types.
static StringRef getAlgebraicTypeName(Type type) {
  if (auto variant = dyn_cast<VariantType>(type))
    return variant.getName();
  if (auto product = dyn_cast<ProductType>(type))
    return product.getName();
  return StringRef();
}

/// Check if a type is an algebraic type (variant or product).
static bool isAlgebraicType(Type type) {
  return isa<VariantType, ProductType>(type);
}

/// Get all types referenced in a variant's fields.
static void getVariantFieldTypes(VariantType variant,
                                 SmallVectorImpl<Type> &fieldTypes) {
  for (Attribute variantAttr : variant.getVariants()) {
    auto variantDict = cast<DictionaryAttr>(variantAttr);
    auto fields = variantDict.getAs<ArrayAttr>("fields");
    if (!fields)
      continue;
    for (Attribute fieldAttr : fields) {
      if (auto typeAttr = dyn_cast<TypeAttr>(fieldAttr))
        fieldTypes.push_back(typeAttr.getValue());
    }
  }
}

/// Get all types referenced in a product's fields.
static void getProductFieldTypes(ProductType product,
                                 SmallVectorImpl<Type> &fieldTypes) {
  for (Attribute fieldAttr : product.getFields()) {
    auto fieldDict = cast<DictionaryAttr>(fieldAttr);
    auto typeAttr = fieldDict.getAs<TypeAttr>("type");
    if (typeAttr)
      fieldTypes.push_back(typeAttr.getValue());
  }
}

/// Get all algebraic types referenced in a type (handles nested types).
static void collectReferencedAlgebraicTypes(Type type,
                                            SmallVectorImpl<Type> &refs) {
  // Direct algebraic type
  if (isAlgebraicType(type)) {
    refs.push_back(type);
    return;
  }

  // Check for algebraic types in RC wrapper
  if (auto rcType = dyn_cast<RCType>(type)) {
    collectReferencedAlgebraicTypes(rcType.getElementType(), refs);
    return;
  }

  // Check for algebraic types in Token wrapper
  if (auto tokenType = dyn_cast<TokenType>(type)) {
    collectReferencedAlgebraicTypes(tokenType.getElementType(), refs);
    return;
  }

  // Check for algebraic types in state reference
  if (auto stateRef = dyn_cast<StateVarRefType>(type)) {
    collectReferencedAlgebraicTypes(stateRef.getStateType(), refs);
    return;
  }

  // Tensor/memref types with algebraic element types are not currently
  // supported for recursion detection - they would need special handling
}

//===----------------------------------------------------------------------===//
// Recursive Type Detection using DFS cycle detection
//===----------------------------------------------------------------------===//

/// Stores information about a detected recursive type.
struct RecursiveTypeInfo {
  StringRef typeName;
  SmallVector<unsigned> recursiveFieldIndices;
};

/// Build a type dependency graph and detect cycles using DFS.
/// Returns a set of type names that are part of recursive cycles.
class RecursiveTypeDetector {
public:
  RecursiveTypeDetector() = default;

  /// Analyze all algebraic types in the module.
  void analyze(Operation *module) {
    // First pass: collect all algebraic types used in the module
    module->walk([&](Operation *op) {
      // Check result types
      for (Type type : op->getResultTypes())
        collectAlgebraicTypes(type);
      // Check operand types
      for (Type type : op->getOperandTypes())
        collectAlgebraicTypes(type);
    });

    // Second pass: build dependency graph
    for (auto &[name, type] : typesByName) {
      buildDependencies(type);
    }

    // Third pass: detect cycles using DFS
    detectCycles();
  }

  /// Check if a type name is recursive.
  bool isRecursive(StringRef typeName) const {
    return recursiveTypes.count(typeName) > 0;
  }
  /// Check if a type is recursive.
  bool isRecursive(Type type) const {
    StringRef name = getAlgebraicTypeName(type);
    if (name.empty())
      return false;
    return isRecursive(name);
  }

  /// Get indices of recursive fields for a variant type.
  SmallVector<unsigned> getRecursiveFieldIndices(VariantType variant,
                                                 StringRef variantCase) const {
    SmallVector<unsigned> indices;
    
    // Find the variant case
    for (Attribute variantAttr : variant.getVariants()) {
      auto variantDict = cast<DictionaryAttr>(variantAttr);
      auto nameAttr = variantDict.getAs<StringAttr>("name");
      if (!nameAttr || nameAttr.getValue() != variantCase) {
        continue;
      }

      // Check each field
      auto fields = variantDict.getAs<ArrayAttr>("fields");
      if (!fields)
        return indices;

      unsigned fieldIdx = 0;
      for (Attribute fieldAttr : fields) {
        auto typeAttr = dyn_cast<TypeAttr>(fieldAttr);
        if (typeAttr) {
          Type fieldType = typeAttr.getValue();
          // A field is recursive if:
          // 1. It's the same algebraic type
          // 2. It contains a reference to a recursive type
          if (isRecursiveField(variant, fieldType))
            indices.push_back(fieldIdx);
        }
        ++fieldIdx;
      }
      break;
    }
    return indices;
  }

private:
  /// Collect all algebraic types from a type (including nested).
  void collectAlgebraicTypes(Type type) {
    SmallVector<Type> refs;
    collectReferencedAlgebraicTypes(type, refs);
    for (Type ref : refs) {
      StringRef name = getAlgebraicTypeName(ref);
      if (!name.empty() && !typesByName.contains(name))
        typesByName[name] = ref;
    }
  }

  /// Build dependencies for a type.
  void buildDependencies(Type type) {
    StringRef name = getAlgebraicTypeName(type);
    if (name.empty())
      return;

    SmallVector<Type> fieldTypes;
    if (auto variant = dyn_cast<VariantType>(type))
      getVariantFieldTypes(variant, fieldTypes);
    else if (auto product = dyn_cast<ProductType>(type))
      getProductFieldTypes(product, fieldTypes);

    auto &deps = dependencies[name];
    for (Type fieldType : fieldTypes) {
      SmallVector<Type> refs;
      collectReferencedAlgebraicTypes(fieldType, refs);
      for (Type ref : refs) {
        StringRef refName = getAlgebraicTypeName(ref);
        if (!refName.empty()) {
          // Add if not already present
          bool found = false;
          for (const auto &existing : deps) {
            if (existing == refName) {
              found = true;
              break;
            }
          }
          if (!found)
            deps.push_back(refName.str());
        }
      }
    }
  }

  /// Detect cycles using DFS with coloring (white/gray/black).
  void detectCycles() {
    // Color: 0 = white (unvisited), 1 = gray (in stack), 2 = black (done)
    llvm::DenseMap<StringRef, int> color;
    for (auto &[name, _] : typesByName)
      color[name] = 0;

    for (auto &[name, _] : typesByName) {
      if (color[name] == 0)
        dfs(name, color);
    }
  }

  /// DFS traversal for cycle detection.
  /// Returns true if a cycle is found involving this node.
  bool dfs(StringRef name, llvm::DenseMap<StringRef, int> &color) {
    color[name] = 1; // Gray - in progress

    auto it = dependencies.find(name);
    if (it != dependencies.end()) {
      for (const std::string &dep : it->second) {
        if (color[dep] == 1) {
          // Found a back edge - cycle detected!
          recursiveTypes[name] = true;
          recursiveTypes[dep] = true;
          return true;
        }
        if (color[dep] == 0) {
          if (dfs(dep, color)) {
            // Propagate recursiveness up
            recursiveTypes[name] = true;
            return true;
          }
        }
      }
    }

    color[name] = 2; // Black - done
    return false;
  }

  /// Check if a field type references a recursive type.
  bool isRecursiveField(Type containingType, Type fieldType) const {
    StringRef containingName = getAlgebraicTypeName(containingType);
    
    SmallVector<Type> refs;
    collectReferencedAlgebraicTypes(fieldType, refs);
    
    for (Type ref : refs) {
      StringRef refName = getAlgebraicTypeName(ref);
      if (!refName.empty()) {
        // Self-reference
        if (refName == containingName)
          return true;
        // Reference to another recursive type
        if (recursiveTypes.count(refName))
          return true;
      }
    }
    return false;
  }

  /// Map from type name to the actual Type.
  llvm::StringMap<Type> typesByName;

  /// Dependency graph: typeName -> set of type names it references.
  llvm::StringMap<llvm::SmallVector<std::string>> dependencies;

  /// Set of type names that are part of recursive cycles.
  llvm::StringMap<bool> recursiveTypes;
};

//===----------------------------------------------------------------------===//
// Pass Implementation
//===----------------------------------------------------------------------===//

class DetectRecursiveTypesPass
    : public impl::DetectRecursiveTypesBase<DetectRecursiveTypesPass> {
public:
  void runOnOperation() override {
    Operation *module = getOperation();
    RecursiveTypeDetector detector;

    // Analyze all types in the module
    detector.analyze(module);

    // Mark operations that use recursive types
    module->walk([&](Operation *op) {
      // Mark variant.create operations
      if (auto createOp = dyn_cast<VariantCreateOp>(op)) {
        Type resultType = createOp.getResult().getType();
        if (auto variant = dyn_cast<VariantType>(resultType)) {
          if (detector.isRecursive(variant)) {
            // Mark as recursive type
            createOp->setAttr("cal.recursive_type",
                              UnitAttr::get(op->getContext()));

            // Get indices of recursive fields
            StringRef variantCase = createOp.getVariantName();
            auto indices = detector.getRecursiveFieldIndices(variant, variantCase);
            if (!indices.empty()) {
              SmallVector<Attribute> indexAttrs;
              for (unsigned idx : indices)
                indexAttrs.push_back(
                    IntegerAttr::get(IndexType::get(op->getContext()), idx));
              createOp->setAttr("cal.recursive_fields",
                                ArrayAttr::get(op->getContext(), indexAttrs));
            }
          }
        }
      }

      // Mark product.create operations
      if (auto createOp = dyn_cast<ProductCreateOp>(op)) {
        Type resultType = createOp.getResult().getType();
        if (auto product = dyn_cast<ProductType>(resultType)) {
          if (detector.isRecursive(product)) {
            createOp->setAttr("cal.recursive_type",
                              UnitAttr::get(op->getContext()));
          }
        }
      }

      // Mark state variables that hold recursive types
      if (auto stateVar = dyn_cast<CreateStateVarOp>(op)) {
        Type stateType = stateVar.getStateType();
        SmallVector<Type> refs;
        collectReferencedAlgebraicTypes(stateType, refs);
        for (Type ref : refs) {
          if (detector.isRecursive(ref)) {
            stateVar->setAttr("cal.recursive_type",
                              UnitAttr::get(op->getContext()));
            break;
          }
        }
      }

      // Mark FIFO operations that transfer recursive types
      // This helps the arena insertion pass know where to wrap/unwrap tokens
      if (auto pushOp = dyn_cast<fifo::Push>(op)) {
        Type tokenType = pushOp.getInputToken().getType();
        SmallVector<Type> refs;
        collectReferencedAlgebraicTypes(tokenType, refs);
        for (Type ref : refs) {
          if (detector.isRecursive(ref)) {
            pushOp->setAttr("cal.recursive_token",
                            UnitAttr::get(op->getContext()));
            break;
          }
        }
      }

      if (auto popOp = dyn_cast<fifo::Pop>(op)) {
        Type tokenType = popOp.getOutputToken().getType();
        SmallVector<Type> refs;
        collectReferencedAlgebraicTypes(tokenType, refs);
        for (Type ref : refs) {
          if (detector.isRecursive(ref)) {
            popOp->setAttr("cal.recursive_token",
                           UnitAttr::get(op->getContext()));
            break;
          }
        }
      }
    });
  }
};

} // namespace

std::unique_ptr<Pass> detectRecursiveTypes() {
  return std::make_unique<DetectRecursiveTypesPass>();
}

} // namespace mlir::cal
