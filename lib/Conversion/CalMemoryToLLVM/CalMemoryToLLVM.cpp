//===- CalMemoryToLLVM.cpp - Lower CAL memory ops to LLVM -----------------===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements lowering of CAL memory management operations (arena,
// RC, token) to the LLVM dialect. All lowering is done inline without requiring
// an external C runtime.
//
//===----------------------------------------------------------------------===//

#include "Conversion/CalMemoryToLLVM/CalMemoryToLLVM.h"
#include "Conversion/Passes.h"
#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalTypes.h"
#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"
#include "mlir/Conversion/LLVMCommon/Pattern.h"
#include "mlir/Conversion/LLVMCommon/TypeConverter.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/LLVMIR/LLVMTypes.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir {

#define GEN_PASS_DEF_CONVERTCALMEMORYTOLLVM
#include "Conversion/Passes.h.inc"

using namespace cal;

//===----------------------------------------------------------------------===//
// Type Converters
//===----------------------------------------------------------------------===//

/// Returns the LLVM struct type representing the arena storage:
/// { ptr base, i64 offset, i64 capacity }
/// Note: !cal.arena converts to ptr (pointing to this struct), NOT the struct itself.
/// This enables in-place updates of the offset field.
static LLVM::LLVMStructType getArenaStructType(MLIRContext *ctx) {
  auto ptrTy = LLVM::LLVMPointerType::get(ctx);
  auto i64Ty = IntegerType::get(ctx, 64);
  return LLVM::LLVMStructType::getLiteral(ctx, {ptrTy, i64Ty, i64Ty});
}

//===----------------------------------------------------------------------===//
// Helper Functions
//===----------------------------------------------------------------------===//

/// Compute the size in bytes for a given LLVM type using the type converter's
/// DataLayout. Returns 8 (pointer size) as fallback for unknown/opaque types.
static int64_t getTypeSizeInBytes(const LLVMTypeConverter &typeConverter,
                                  Type llvmType) {
  const llvm::DataLayout &dataLayout = typeConverter.getDataLayout();

  // Handle LLVM types
  if (auto intTy = dyn_cast<IntegerType>(llvmType)) {
    return (intTy.getWidth() + 7) / 8; // Round up to bytes
  }
  if (isa<Float16Type>(llvmType))
    return 2;
  if (isa<Float32Type>(llvmType))
    return 4;
  if (isa<Float64Type>(llvmType))
    return 8;
  if (isa<LLVM::LLVMPointerType>(llvmType))
    return dataLayout.getPointerSize();

  // For LLVM struct types, sum the field sizes (simplified, no padding)
  if (auto structTy = dyn_cast<LLVM::LLVMStructType>(llvmType)) {
    int64_t size = 0;
    for (Type fieldTy : structTy.getBody()) {
      size += getTypeSizeInBytes(typeConverter, fieldTy);
    }
    return size > 0 ? size : 8;
  }

  // For LLVM array types
  if (auto arrayTy = dyn_cast<LLVM::LLVMArrayType>(llvmType)) {
    int64_t elemSize = getTypeSizeInBytes(typeConverter, arrayTy.getElementType());
    return elemSize * arrayTy.getNumElements();
  }

  // Default fallback: pointer-sized
  return 8;
}

/// Compute the preferred alignment for a given LLVM type.
/// Returns 8 (pointer alignment) as fallback for unknown types.
static int64_t getTypeAlignmentInBytes(const LLVMTypeConverter &typeConverter,
                                       Type llvmType) {
  // For simple types, align to their size (up to 8)
  if (auto intTy = dyn_cast<IntegerType>(llvmType)) {
    int64_t bytes = (intTy.getWidth() + 7) / 8;
    return std::min(bytes, (int64_t)8);
  }
  if (isa<Float16Type>(llvmType))
    return 2;
  if (isa<Float32Type>(llvmType))
    return 4;
  if (isa<Float64Type>(llvmType))
    return 8;
  if (isa<LLVM::LLVMPointerType>(llvmType))
    return typeConverter.getDataLayout().getPointerSize();

  // For struct types, use maximum field alignment
  if (auto structTy = dyn_cast<LLVM::LLVMStructType>(llvmType)) {
    int64_t maxAlign = 1;
    for (Type fieldTy : structTy.getBody()) {
      maxAlign = std::max(maxAlign, getTypeAlignmentInBytes(typeConverter, fieldTy));
    }
    return maxAlign;
  }

  // For array types, use element alignment
  if (auto arrayTy = dyn_cast<LLVM::LLVMArrayType>(llvmType)) {
    return getTypeAlignmentInBytes(typeConverter, arrayTy.getElementType());
  }

  // Default: 8-byte alignment
  return 8;
}

/// Gets or declares the malloc function in the module.
static LLVM::LLVMFuncOp getOrInsertMalloc(ModuleOp module, OpBuilder &builder) {
  auto *ctx = module.getContext();
  if (auto malloc = module.lookupSymbol<LLVM::LLVMFuncOp>("malloc"))
    return malloc;

  auto ptrTy = LLVM::LLVMPointerType::get(ctx);
  auto i64Ty = IntegerType::get(ctx, 64);
  auto fnTy = LLVM::LLVMFunctionType::get(ptrTy, {i64Ty});

  OpBuilder::InsertionGuard guard(builder);
  builder.setInsertionPointToStart(module.getBody());
  return builder.create<LLVM::LLVMFuncOp>(module.getLoc(), "malloc", fnTy);
}

/// Gets or declares the free function in the module.
static LLVM::LLVMFuncOp getOrInsertFree(ModuleOp module, OpBuilder &builder) {
  auto *ctx = module.getContext();
  if (auto free = module.lookupSymbol<LLVM::LLVMFuncOp>("free"))
    return free;

  auto ptrTy = LLVM::LLVMPointerType::get(ctx);
  auto voidTy = LLVM::LLVMVoidType::get(ctx);
  auto fnTy = LLVM::LLVMFunctionType::get(voidTy, {ptrTy});

  OpBuilder::InsertionGuard guard(builder);
  builder.setInsertionPointToStart(module.getBody());
  return builder.create<LLVM::LLVMFuncOp>(module.getLoc(), "free", fnTy);
}

/// Gets or declares the abort function in the module for arena overflow errors.
static LLVM::LLVMFuncOp getOrInsertAbort(ModuleOp module, OpBuilder &builder) {
  auto *ctx = module.getContext();
  if (auto abort = module.lookupSymbol<LLVM::LLVMFuncOp>("abort"))
    return abort;

  auto voidTy = LLVM::LLVMVoidType::get(ctx);
  auto fnTy = LLVM::LLVMFunctionType::get(voidTy, {});

  OpBuilder::InsertionGuard guard(builder);
  builder.setInsertionPointToStart(module.getBody());
  auto fn = builder.create<LLVM::LLVMFuncOp>(module.getLoc(), "abort", fnTy);
  // Mark abort as noreturn for better codegen
  fn->setAttr("passthrough", builder.getArrayAttr({builder.getStringAttr("noreturn")}));
  return fn;
}

//===----------------------------------------------------------------------===//
// Recursive RC Release Helpers
//===----------------------------------------------------------------------===//

/// Check if a type contains nested RC or boxed pointer fields that require
/// custom recursive release logic.
/// Returns true if the type is a variant/product containing:
/// - Nested !cal.rc<U> fields
/// - Boxed pointers (!llvm.ptr) that represent recursive type references
static bool needsCustomRelease(Type elemType) {
  // Check for variant types with nested RCs or pointers
  if (auto variantTy = dyn_cast<VariantType>(elemType)) {
    for (Attribute attr : variantTy.getVariants()) {
      auto dict = cast<DictionaryAttr>(attr);
      auto fields = dict.getAs<ArrayAttr>("fields");
      for (Attribute fieldAttr : fields) {
        Type fieldTy = cast<TypeAttr>(fieldAttr).getValue();
        // Check for nested RC types
        if (isa<RCType>(fieldTy))
          return true;
        // Check for pointer types (boxed recursive references)
        if (isa<LLVM::LLVMPointerType>(fieldTy))
          return true;
        // Recursively check nested variants/products
        if (needsCustomRelease(fieldTy))
          return true;
      }
    }
    return false;
  }
  
  // Check for product types with nested RCs or pointers
  if (auto productTy = dyn_cast<ProductType>(elemType)) {
    for (Attribute attr : productTy.getFields()) {
      auto dict = cast<DictionaryAttr>(attr);
      auto fieldType = dict.getAs<TypeAttr>("type").getValue();
      if (isa<RCType>(fieldType))
        return true;
      if (isa<LLVM::LLVMPointerType>(fieldType))
        return true;
      if (needsCustomRelease(fieldType))
        return true;
    }
    return false;
  }
  
  return false;
}

/// Generate a mangled name for a type-specific release function.
/// Format: @__cal_release_<TypeName>[_<ElementTypes>]
/// Examples:
///   - VariantType "List" with i32 elements -> "__cal_release_List"
///   - ProductType "Vec2" -> "__cal_release_Vec2"
static std::string mangleReleaseFunctionName(Type elemType) {
  std::string name = "__cal_release_";
  
  if (auto variantTy = dyn_cast<VariantType>(elemType)) {
    name += variantTy.getName().str();
    return name;
  }
  
  if (auto productTy = dyn_cast<ProductType>(elemType)) {
    name += productTy.getName().str();
    return name;
  }
  
  // Fallback for unknown types
  name += "unknown";
  return name;
}

/// Get the variant field types from a VariantType for a specific variant name.
static SmallVector<Type> getVariantFieldTypes(VariantType varTy, StringRef variantName) {
  SmallVector<Type> result;
  for (Attribute attr : varTy.getVariants()) {
    auto dict = cast<DictionaryAttr>(attr);
    auto name = dict.getAs<StringAttr>("name").getValue();
    if (name == variantName) {
      auto fields = dict.getAs<ArrayAttr>("fields");
      for (Attribute fieldAttr : fields) {
        result.push_back(cast<TypeAttr>(fieldAttr).getValue());
      }
      break;
    }
  }
  return result;
}

/// Compute the maximum payload size across all variants.
static int64_t getMaxVariantPayloadSize(VariantType varTy, 
                                        const LLVMTypeConverter &converter) {
  int64_t maxSize = 0;
  for (Attribute attr : varTy.getVariants()) {
    auto dict = cast<DictionaryAttr>(attr);
    auto fields = dict.getAs<ArrayAttr>("fields");
    int64_t variantSize = 0;
    for (Attribute fieldAttr : fields) {
      Type fieldTy = cast<TypeAttr>(fieldAttr).getValue();
      Type llvmTy = converter.convertType(fieldTy);
      variantSize += getTypeSizeInBytes(converter, llvmTy);
    }
    maxSize = std::max(maxSize, variantSize);
  }
  return std::max(maxSize, (int64_t)1);
}

/// Get the pointee type for a boxed pointer field.
///
/// For recursive types, pointer fields may reference either the same type
/// (self-recursion) or a different type (mutual recursion). This function
/// looks up the pointee type from field annotations.
///
/// Arguments:
///   - containingType: The variant/product type containing the field
///   - variantName: Name of the variant case (for variants) or empty (for products)
///   - fieldIndex: Index of the field within the variant/product
///   - module: Module for looking up pointee type annotations
///
/// Returns the pointee type. Falls back to containingType for self-recursion.
static Type getPointeeTypeForField(Type containingType, StringRef variantName,
                                   unsigned fieldIndex, ModuleOp module) {
  // Look for module-level annotation: cal.pointer_field_types
  // Format: { "TypeName::VariantName::FieldIndex" = "PointeeTypeName" }
  if (auto ptrFieldTypes = module->getAttrOfType<DictionaryAttr>("cal.pointer_field_types")) {
    std::string key;
    if (auto variantTy = dyn_cast<VariantType>(containingType)) {
      key = variantTy.getName().str() + "::" + variantName.str() + "::" + 
            std::to_string(fieldIndex);
    } else if (auto productTy = dyn_cast<ProductType>(containingType)) {
      key = productTy.getName().str() + "::" + std::to_string(fieldIndex);
    }
    
    if (auto pointeeAttr = ptrFieldTypes.getAs<TypeAttr>(key)) {
      return pointeeAttr.getValue();
    }
  }
  
  // Default: self-recursion - pointer points back to containing type
  return containingType;
}

/// Get or generate a type-specific release function for recursive RC types.
/// The generated function:
/// 1. Atomically decrements the refcount
/// 2. If count reaches zero:
///    - For variants: switch on tag, release nested RC/ptr fields per case
///    - For products: release each nested RC/ptr field
///    - Free the RC container
///
/// Supports mutual recursion: pointer fields can reference different types,
/// and the correct release function is called for each field based on the
/// pointee type annotation or self-recursion fallback.
///
/// Returns the LLVM function (either existing or newly generated).
static LLVM::LLVMFuncOp getOrGenerateReleaseFunction(
    ModuleOp module, Type elemType, const LLVMTypeConverter &typeConverter,
    OpBuilder &builder) {
  std::string funcName = mangleReleaseFunctionName(elemType);
  auto *ctx = module.getContext();
  
  // Check if function already exists
  if (auto existing = module.lookupSymbol<LLVM::LLVMFuncOp>(funcName))
    return existing;
  
  auto ptrTy = LLVM::LLVMPointerType::get(ctx);
  auto voidTy = LLVM::LLVMVoidType::get(ctx);
  auto i32Ty = IntegerType::get(ctx, 32);
  auto i64Ty = IntegerType::get(ctx, 64);
  auto i8Ty = IntegerType::get(ctx, 8);
  
  // Create function signature: (ptr) -> void
  auto fnTy = LLVM::LLVMFunctionType::get(voidTy, {ptrTy});
  
  OpBuilder::InsertionGuard guard(builder);
  builder.setInsertionPointToStart(module.getBody());
  auto func = builder.create<LLVM::LLVMFuncOp>(module.getLoc(), funcName, fnTy);
  func.setLinkage(LLVM::Linkage::Private);
  
  // Create entry block
  Block *entryBlock = func.addEntryBlock(builder);
  builder.setInsertionPointToStart(entryBlock);
  Value rcPtr = entryBlock->getArgument(0);
  Location loc = module.getLoc();
  
  // 1. Atomic decrement: atomicrmw sub ptr, 1 (returns old value)
  auto one = builder.create<LLVM::ConstantOp>(loc, i32Ty, builder.getI32IntegerAttr(1));
  auto oldCount = builder.create<LLVM::AtomicRMWOp>(
      loc, LLVM::AtomicBinOp::sub, rcPtr, one,
      LLVM::AtomicOrdering::seq_cst);
  
  // 2. Check if old count was 1 (meaning new count is 0 -> should free)
  auto cmp = builder.create<LLVM::ICmpOp>(
      loc, LLVM::ICmpPredicate::eq, oldCount, one);
  
  // Create blocks: releaseBlock, doneBlock
  Block *releaseBlock = func.addBlock();
  Block *doneBlock = func.addBlock();
  
  // Conditional branch: if count was 1, go to release; else done
  builder.create<LLVM::CondBrOp>(loc, cmp, releaseBlock, doneBlock);
  
  // Done block: just return
  builder.setInsertionPointToStart(doneBlock);
  builder.create<LLVM::ReturnOp>(loc, ValueRange{});
  
  // Release block: release nested fields, then free
  builder.setInsertionPointToStart(releaseBlock);
  
  // Calculate payload offset (after i32 refcount, aligned to payload type)
  Type llvmElemType = typeConverter.convertType(elemType);
  int64_t payloadAlign = getTypeAlignmentInBytes(typeConverter, llvmElemType);
  int64_t payloadOffset = (4 + payloadAlign - 1) & ~(payloadAlign - 1);
  
  // Get pointer to payload
  auto payloadOffsetVal = builder.create<LLVM::ConstantOp>(
      loc, i64Ty, builder.getI64IntegerAttr(payloadOffset));
  auto payloadPtr = builder.create<LLVM::GEPOp>(
      loc, ptrTy, i8Ty, rcPtr, ValueRange{payloadOffsetVal});
  
  // Handle variant types with switch on tag
  if (auto variantTy = dyn_cast<VariantType>(elemType)) {
    // Load the tag (first field of payload)
    auto tag = builder.create<LLVM::LoadOp>(loc, i32Ty, payloadPtr);
    
    // Get the number of variants and create a switch
    int numVariants = variantTy.getVariants().size();
    
    // Create a block for each variant case + a default/free block
    Block *freeBlock = func.addBlock();
    SmallVector<Block *> caseBlocks;
    SmallVector<int32_t> caseValues;
    
    for (int i = 0; i < numVariants; ++i) {
      auto dict = cast<DictionaryAttr>(variantTy.getVariants()[i]);
      auto fields = dict.getAs<ArrayAttr>("fields");
      
      // Check if this variant has any RC/ptr fields to release
      bool hasFieldsToRelease = false;
      for (Attribute fieldAttr : fields) {
        Type fieldTy = cast<TypeAttr>(fieldAttr).getValue();
        if (isa<RCType>(fieldTy) || isa<LLVM::LLVMPointerType>(fieldTy)) {
          hasFieldsToRelease = true;
          break;
        }
      }
      
      if (hasFieldsToRelease) {
        caseBlocks.push_back(func.addBlock());
        caseValues.push_back(i);
      }
    }
    
    // Build the switch - default goes to free (no fields to release)
    if (caseBlocks.empty()) {
      // No variants with RC/ptr fields, just branch to free
      builder.create<LLVM::BrOp>(loc, ValueRange{}, freeBlock);
    } else {
      // Create switch with cases
      SmallVector<int32_t> caseValuesVec(caseValues.begin(), caseValues.end());
      SmallVector<Block *> caseDestsVec(caseBlocks.begin(), caseBlocks.end());
      SmallVector<ValueRange> caseOperands(caseBlocks.size(), ValueRange{});
      
      builder.create<LLVM::SwitchOp>(
          loc, tag, freeBlock, ValueRange{},
          caseValuesVec, caseDestsVec, 
          SmallVector<ValueRange>(caseBlocks.size(), ValueRange{}));
      
      // Generate code for each case block
      int caseIdx = 0;
      for (int varIdx = 0; varIdx < numVariants; ++varIdx) {
        auto dict = cast<DictionaryAttr>(variantTy.getVariants()[varIdx]);
        auto variantNameAttr = dict.getAs<StringAttr>("name");
        StringRef variantCaseName = variantNameAttr ? variantNameAttr.getValue() : "";
        auto fields = dict.getAs<ArrayAttr>("fields");
        
        // Check if this variant was added to case blocks
        bool hasFieldsToRelease = false;
        for (Attribute fieldAttr : fields) {
          Type fieldTy = cast<TypeAttr>(fieldAttr).getValue();
          if (isa<RCType>(fieldTy) || isa<LLVM::LLVMPointerType>(fieldTy)) {
            hasFieldsToRelease = true;
            break;
          }
        }
        if (!hasFieldsToRelease)
          continue;
        
        Block *caseBlock = caseBlocks[caseIdx++];
        builder.setInsertionPointToStart(caseBlock);
        
        // Payload layout: { i32 tag, [payload bytes] }
        // Calculate field offsets within payload
        int64_t fieldOffset = 4; // Start after tag (simplified; real impl needs proper alignment)
        
        int fieldIdx = 0;
        for (Attribute fieldAttr : fields) {
          Type fieldTy = cast<TypeAttr>(fieldAttr).getValue();
          Type llvmFieldTy = typeConverter.convertType(fieldTy);
          int64_t fieldSize = getTypeSizeInBytes(typeConverter, llvmFieldTy);
          
          // Align field offset
          int64_t fieldAlign = getTypeAlignmentInBytes(typeConverter, llvmFieldTy);
          fieldOffset = (fieldOffset + fieldAlign - 1) & ~(fieldAlign - 1);
          
          if (isa<LLVM::LLVMPointerType>(fieldTy)) {
            // This is a boxed/recursive pointer field - need to release it
            // Determine the pointee type (supports mutual recursion)
            Type pointeeType = getPointeeTypeForField(elemType, variantCaseName, 
                                                      fieldIdx, module);
            
            // GEP to field, load pointer, null-check, recursive release
            auto fieldOffsetVal = builder.create<LLVM::ConstantOp>(
                loc, i64Ty, builder.getI64IntegerAttr(fieldOffset));
            auto fieldPtr = builder.create<LLVM::GEPOp>(
                loc, ptrTy, i8Ty, payloadPtr, ValueRange{fieldOffsetVal});
            auto nestedPtr = builder.create<LLVM::LoadOp>(loc, ptrTy, fieldPtr);
            
            // Null check before recursive release
            auto nullPtr = builder.create<LLVM::ZeroOp>(loc, ptrTy);
            auto isNull = builder.create<LLVM::ICmpOp>(
                loc, LLVM::ICmpPredicate::eq, nestedPtr, nullPtr);
            
            Block *releaseNestedBlock = func.addBlock();
            Block *afterNestedBlock = func.addBlock();
            
            builder.create<LLVM::CondBrOp>(loc, isNull, afterNestedBlock, releaseNestedBlock);
            
            // Release nested block: call release function for pointee type
            // For self-recursion, this is the same function (func)
            // For mutual recursion, this may be a different function
            builder.setInsertionPointToStart(releaseNestedBlock);
            
            LLVM::LLVMFuncOp releaseFunc;
            if (pointeeType == elemType) {
              // Self-recursion: call this function
              releaseFunc = func;
            } else {
              // Mutual recursion: get or generate release function for pointee type
              releaseFunc = getOrGenerateReleaseFunction(module, pointeeType, 
                                                         typeConverter, builder);
            }
            builder.create<LLVM::CallOp>(loc, releaseFunc, ValueRange{nestedPtr});
            builder.create<LLVM::BrOp>(loc, ValueRange{}, afterNestedBlock);
            
            // Continue after releasing this field
            builder.setInsertionPointToStart(afterNestedBlock);
          }
          
          fieldOffset += fieldSize;
          ++fieldIdx;
        }
        
        // After releasing all fields, branch to free
        builder.create<LLVM::BrOp>(loc, ValueRange{}, freeBlock);
      }
    }
    
    // Free block: call free and return
    builder.setInsertionPointToStart(freeBlock);
    auto freeFn = getOrInsertFree(module, builder);
    builder.create<LLVM::CallOp>(loc, freeFn, ValueRange{rcPtr});
    builder.create<LLVM::BrOp>(loc, ValueRange{}, doneBlock);
    
  } else if (auto productTy = dyn_cast<ProductType>(elemType)) {
    // Product type: release each RC/ptr field in order
    Block *freeBlock = func.addBlock();
    int64_t fieldOffset = 0;
    unsigned fieldIdx = 0;
    
    for (Attribute attr : productTy.getFields()) {
      auto dict = cast<DictionaryAttr>(attr);
      Type fieldTy = dict.getAs<TypeAttr>("type").getValue();
      Type llvmFieldTy = typeConverter.convertType(fieldTy);
      int64_t fieldSize = getTypeSizeInBytes(typeConverter, llvmFieldTy);
      int64_t fieldAlign = getTypeAlignmentInBytes(typeConverter, llvmFieldTy);
      
      // Align field offset
      fieldOffset = (fieldOffset + fieldAlign - 1) & ~(fieldAlign - 1);
      
      if (isa<LLVM::LLVMPointerType>(fieldTy)) {
        // Boxed/recursive pointer field
        // Determine the pointee type (supports mutual recursion)
        Type pointeeType = getPointeeTypeForField(elemType, /*variantName=*/"", 
                                                  fieldIdx, module);
        
        auto fieldOffsetVal = builder.create<LLVM::ConstantOp>(
            loc, i64Ty, builder.getI64IntegerAttr(fieldOffset));
        auto fieldPtr = builder.create<LLVM::GEPOp>(
            loc, ptrTy, i8Ty, payloadPtr, ValueRange{fieldOffsetVal});
        auto nestedPtr = builder.create<LLVM::LoadOp>(loc, ptrTy, fieldPtr);
        
        // Null check
        auto nullPtr = builder.create<LLVM::ZeroOp>(loc, ptrTy);
        auto isNull = builder.create<LLVM::ICmpOp>(
            loc, LLVM::ICmpPredicate::eq, nestedPtr, nullPtr);
        
        Block *releaseNestedBlock = func.addBlock();
        Block *afterNestedBlock = func.addBlock();
        
        builder.create<LLVM::CondBrOp>(loc, isNull, afterNestedBlock, releaseNestedBlock);
        
        builder.setInsertionPointToStart(releaseNestedBlock);
        
        // Call release function for pointee type
        LLVM::LLVMFuncOp releaseFunc;
        if (pointeeType == elemType) {
          // Self-recursion
          releaseFunc = func;
        } else {
          // Mutual recursion
          releaseFunc = getOrGenerateReleaseFunction(module, pointeeType,
                                                     typeConverter, builder);
        }
        builder.create<LLVM::CallOp>(loc, releaseFunc, ValueRange{nestedPtr});
        builder.create<LLVM::BrOp>(loc, ValueRange{}, afterNestedBlock);
        
        builder.setInsertionPointToStart(afterNestedBlock);
      }
      
      fieldOffset += fieldSize;
      ++fieldIdx;
    }
    
    // Branch to free
    builder.create<LLVM::BrOp>(loc, ValueRange{}, freeBlock);
    
    // Free block
    builder.setInsertionPointToStart(freeBlock);
    auto freeFn = getOrInsertFree(module, builder);
    builder.create<LLVM::CallOp>(loc, freeFn, ValueRange{rcPtr});
    builder.create<LLVM::BrOp>(loc, ValueRange{}, doneBlock);
    
  } else {
    // Unknown type - just free
    auto freeFn = getOrInsertFree(module, builder);
    builder.create<LLVM::CallOp>(loc, freeFn, ValueRange{rcPtr});
    builder.create<LLVM::BrOp>(loc, ValueRange{}, doneBlock);
  }
  
  return func;
}

//===----------------------------------------------------------------------===//
// Arena Operation Lowering
//===----------------------------------------------------------------------===//

/// Lowers cal.arena.create to inline LLVM code:
/// 1. Allocate the arena struct itself (header)
/// 2. Allocate the backing buffer
/// 3. Store {base, offset=0, capacity} in the arena struct
/// 4. Return pointer to arena struct (enables in-place offset updates)
struct ArenaCreateOpLowering : public ConvertOpToLLVMPattern<ArenaCreateOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(ArenaCreateOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto *ctx = rewriter.getContext();
    auto module = op->getParentOfType<ModuleOp>();

    // Default arena size: 4KB (can be overridden by attribute)
    int64_t capacity = 4096;
    if (auto sizeAttr = op.getInitialSizeAttr())
      capacity = sizeAttr.getInt();

    auto ptrTy = LLVM::LLVMPointerType::get(ctx);
    auto i64Ty = IntegerType::get(ctx, 64);
    auto i32Ty = IntegerType::get(ctx, 32);
    auto arenaStructTy = getArenaStructType(ctx);

    auto mallocFn = getOrInsertMalloc(module, rewriter);

    // 1. Allocate the arena struct header (3 fields: ptr, i64, i64)
    //    Size = 8 (ptr) + 8 (i64) + 8 (i64) = 24 bytes
    auto headerSize = rewriter.create<LLVM::ConstantOp>(
        loc, i64Ty, rewriter.getI64IntegerAttr(24));
    auto arenaPtr = rewriter.create<LLVM::CallOp>(loc, mallocFn, ValueRange{headerSize});

    // 2. Allocate the backing buffer
    auto capacityVal = rewriter.create<LLVM::ConstantOp>(
        loc, i64Ty, rewriter.getI64IntegerAttr(capacity));
    auto basePtr = rewriter.create<LLVM::CallOp>(loc, mallocFn, ValueRange{capacityVal});

    // 3. Store fields into arena struct
    // Store base pointer at offset 0
    auto zero32 = rewriter.create<LLVM::ConstantOp>(loc, i32Ty, rewriter.getI32IntegerAttr(0));
    auto one32 = rewriter.create<LLVM::ConstantOp>(loc, i32Ty, rewriter.getI32IntegerAttr(1));
    auto two32 = rewriter.create<LLVM::ConstantOp>(loc, i32Ty, rewriter.getI32IntegerAttr(2));

    auto basePtrSlot = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, arenaStructTy, arenaPtr.getResult(), ValueRange{zero32, zero32});
    rewriter.create<LLVM::StoreOp>(loc, basePtr.getResult(), basePtrSlot);

    // Store offset=0 at field 1
    auto zeroOffset = rewriter.create<LLVM::ConstantOp>(
        loc, i64Ty, rewriter.getI64IntegerAttr(0));
    auto offsetSlot = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, arenaStructTy, arenaPtr.getResult(), ValueRange{zero32, one32});
    rewriter.create<LLVM::StoreOp>(loc, zeroOffset, offsetSlot);

    // Store capacity at field 2
    auto capacitySlot = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, arenaStructTy, arenaPtr.getResult(), ValueRange{zero32, two32});
    rewriter.create<LLVM::StoreOp>(loc, capacityVal, capacitySlot);

    // Return pointer to arena struct
    rewriter.replaceOp(op, arenaPtr.getResult());
    return success();
  }
};

/// Lowers cal.arena.destroy to free both the backing buffer and the arena struct.
struct ArenaDestroyOpLowering : public ConvertOpToLLVMPattern<ArenaDestroyOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(ArenaDestroyOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto *ctx = rewriter.getContext();
    auto module = op->getParentOfType<ModuleOp>();

    auto ptrTy = LLVM::LLVMPointerType::get(ctx);
    auto i32Ty = IntegerType::get(ctx, 32);
    auto arenaStructTy = getArenaStructType(ctx);

    // adaptor.getArena() is now a pointer to the arena struct
    Value arenaPtr = adaptor.getArena();

    // Load base pointer from arena struct (field 0)
    auto zero32 = rewriter.create<LLVM::ConstantOp>(loc, i32Ty, rewriter.getI32IntegerAttr(0));
    auto basePtrSlot = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, arenaStructTy, arenaPtr, ValueRange{zero32, zero32});
    auto basePtr = rewriter.create<LLVM::LoadOp>(loc, ptrTy, basePtrSlot);

    auto freeFn = getOrInsertFree(module, rewriter);

    // Free the backing buffer
    rewriter.create<LLVM::CallOp>(loc, freeFn, ValueRange{basePtr});

    // Free the arena struct itself
    rewriter.create<LLVM::CallOp>(loc, freeFn, ValueRange{arenaPtr});

    rewriter.eraseOp(op);
    return success();
  }
};

/// Lowers cal.arena.alloc to bump-pointer allocation with bounds checking:
/// 1. Load current offset from arena struct (via pointer)
/// 2. Align offset to requested alignment
/// 3. Compute new offset = aligned_offset + size
/// 4. Check if new offset exceeds capacity; abort if so
/// 5. Store new offset back to arena struct (IN-PLACE UPDATE)
/// 6. Return pointer to base + aligned_offset
struct ArenaAllocOpLowering : public ConvertOpToLLVMPattern<ArenaAllocOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(ArenaAllocOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto *ctx = rewriter.getContext();
    auto module = op->getParentOfType<ModuleOp>();
    auto ptrTy = LLVM::LLVMPointerType::get(ctx);
    auto i64Ty = IntegerType::get(ctx, 64);
    auto i32Ty = IntegerType::get(ctx, 32);
    auto arenaStructTy = getArenaStructType(ctx);

    // adaptor.getArena() is now a pointer to the arena struct
    Value arenaPtr = adaptor.getArena();

    auto zero32 = rewriter.create<LLVM::ConstantOp>(loc, i32Ty, rewriter.getI32IntegerAttr(0));
    auto one32 = rewriter.create<LLVM::ConstantOp>(loc, i32Ty, rewriter.getI32IntegerAttr(1));
    auto two32 = rewriter.create<LLVM::ConstantOp>(loc, i32Ty, rewriter.getI32IntegerAttr(2));

    // Load base pointer from arena struct (field 0)
    auto basePtrSlot = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, arenaStructTy, arenaPtr, ValueRange{zero32, zero32});
    auto basePtr = rewriter.create<LLVM::LoadOp>(loc, ptrTy, basePtrSlot);

    // Load current offset from arena struct (field 1)
    auto offsetSlot = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, arenaStructTy, arenaPtr, ValueRange{zero32, one32});
    auto currentOffset = rewriter.create<LLVM::LoadOp>(loc, i64Ty, offsetSlot);

    // Load capacity from arena struct (field 2)
    auto capacitySlot = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, arenaStructTy, arenaPtr, ValueRange{zero32, two32});
    auto capacity = rewriter.create<LLVM::LoadOp>(loc, i64Ty, capacitySlot);

    // Convert size and alignment to i64 if needed
    Value size = adaptor.getSize();
    Value alignment = adaptor.getAlignment();
    if (size.getType() != i64Ty)
      size = rewriter.create<LLVM::ZExtOp>(loc, i64Ty, size);
    if (alignment.getType() != i64Ty)
      alignment = rewriter.create<LLVM::ZExtOp>(loc, i64Ty, alignment);

    // Align: aligned_offset = (offset + align - 1) & ~(align - 1)
    auto one = rewriter.create<LLVM::ConstantOp>(
        loc, i64Ty, rewriter.getI64IntegerAttr(1));
    auto alignM1 = rewriter.create<LLVM::SubOp>(loc, alignment, one);
    auto offsetPlusAlignM1 = rewriter.create<LLVM::AddOp>(loc, currentOffset, alignM1);
    auto negAlignM1 = rewriter.create<LLVM::XOrOp>(
        loc, alignM1,
        rewriter.create<LLVM::ConstantOp>(loc, i64Ty, rewriter.getI64IntegerAttr(-1)));
    auto alignedOffset = rewriter.create<LLVM::AndOp>(loc, offsetPlusAlignM1, negAlignM1);

    // Compute new offset: newOffset = alignedOffset + size
    auto newOffset = rewriter.create<LLVM::AddOp>(loc, alignedOffset, size);

    // Bounds check: if newOffset > capacity, call abort
    auto overflow = rewriter.create<LLVM::ICmpOp>(
        loc, LLVM::ICmpPredicate::ugt, newOffset, capacity);

    // Create blocks for bounds check
    Block *currentBlock = rewriter.getInsertionBlock();
    Block::iterator splitPoint = rewriter.getInsertionPoint();
    Block *contBlock = rewriter.splitBlock(currentBlock, splitPoint);
    Block *abortBlock = rewriter.createBlock(contBlock);

    // In abort block: call abort() (does not return)
    rewriter.setInsertionPointToStart(abortBlock);
    auto abortFn = getOrInsertAbort(module, rewriter);
    rewriter.create<LLVM::CallOp>(loc, abortFn, ValueRange{});
    rewriter.create<LLVM::UnreachableOp>(loc);

    // In current block: conditional branch based on overflow check
    rewriter.setInsertionPointToEnd(currentBlock);
    rewriter.create<LLVM::CondBrOp>(loc, overflow, abortBlock, contBlock);

    // Continue in contBlock after the bounds check passes
    rewriter.setInsertionPointToStart(contBlock);

    // Store new offset back to arena struct (IN-PLACE UPDATE)
    rewriter.create<LLVM::StoreOp>(loc, newOffset, offsetSlot);

    // Compute result pointer: base + aligned_offset
    auto resultPtr = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy,
        IntegerType::get(ctx, 8), // byte pointer arithmetic
        basePtr, ValueRange{alignedOffset});

    rewriter.replaceOp(op, resultPtr);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// Reference Counting Operation Lowering
//===----------------------------------------------------------------------===//

/// Lowers cal.rc.alloc to:
/// 1. Allocate memory for refcount (4 bytes) + payload
/// 2. Initialize refcount to 1
/// 3. Store payload value
/// 4. Return pointer
struct RCAllocOpLowering : public ConvertOpToLLVMPattern<RCAllocOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(RCAllocOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto *ctx = rewriter.getContext();
    auto module = op->getParentOfType<ModuleOp>();

    auto ptrTy = LLVM::LLVMPointerType::get(ctx);
    auto i32Ty = IntegerType::get(ctx, 32);
    auto i64Ty = IntegerType::get(ctx, 64);
    (void)ptrTy; // Used in payload pointer computation below

    // Get the converted payload type and compute its size
    Type payloadLLVMType = adaptor.getValue().getType();
    int64_t payloadSize = getTypeSizeInBytes(*getTypeConverter(), payloadLLVMType);
    int64_t payloadAlign = getTypeAlignmentInBytes(*getTypeConverter(), payloadLLVMType);
    
    // Compute offset for payload: refcount (4 bytes) aligned to payload alignment
    int64_t payloadOffset = (4 + payloadAlign - 1) & ~(payloadAlign - 1);
    int64_t totalSize = payloadOffset + payloadSize;

    // Allocate memory
    auto mallocFn = getOrInsertMalloc(module, rewriter);
    auto sizeVal = rewriter.create<LLVM::ConstantOp>(
        loc, i64Ty, rewriter.getI64IntegerAttr(totalSize));
    auto allocResult = rewriter.create<LLVM::CallOp>(loc, mallocFn, ValueRange{sizeVal});
    Value ptr = allocResult.getResult();

    // Initialize refcount to 1
    auto one = rewriter.create<LLVM::ConstantOp>(
        loc, i32Ty, rewriter.getI32IntegerAttr(1));
    rewriter.create<LLVM::StoreOp>(loc, one, ptr);

    // Store payload after refcount (offset to maintain alignment)
    auto offsetVal = rewriter.create<LLVM::ConstantOp>(
        loc, i64Ty, rewriter.getI64IntegerAttr(payloadOffset));
    auto payloadPtr = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, IntegerType::get(ctx, 8), ptr, ValueRange{offsetVal});
    rewriter.create<LLVM::StoreOp>(loc, adaptor.getValue(), payloadPtr);

    rewriter.replaceOp(op, ptr);
    return success();
  }
};

/// Lowers cal.rc.retain to atomic increment of refcount.
struct RCRetainOpLowering : public ConvertOpToLLVMPattern<RCRetainOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(RCRetainOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto *ctx = rewriter.getContext();
    auto i32Ty = IntegerType::get(ctx, 32);

    Value ptr = adaptor.getValue();

    // Atomic increment: atomicrmw add ptr, 1
    auto one = rewriter.create<LLVM::ConstantOp>(
        loc, i32Ty, rewriter.getI32IntegerAttr(1));
    rewriter.create<LLVM::AtomicRMWOp>(
        loc, LLVM::AtomicBinOp::add, ptr, one,
        LLVM::AtomicOrdering::seq_cst);

    // Return the same pointer
    rewriter.replaceOp(op, ptr);
    return success();
  }
};

/// Lowers cal.rc.release to atomic decrement and conditional free.
/// For nested types (variants/products containing pointer fields), generates
/// a type-specific release function that recursively releases nested RC values.
///
/// Simple types: inline atomic decrement + conditional free
/// Nested types: call generated release function that handles recursion
struct RCReleaseOpLowering : public ConvertOpToLLVMPattern<RCReleaseOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(RCReleaseOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto *ctx = rewriter.getContext();
    auto module = op->getParentOfType<ModuleOp>();
    auto i32Ty = IntegerType::get(ctx, 32);
    auto ptrTy = LLVM::LLVMPointerType::get(ctx);

    Value ptr = adaptor.getValue();

    // Get the original RC type to analyze its element type
    auto rcType = dyn_cast<RCType>(op.getValue().getType());
    
    // Check if the element type needs custom recursive release
    if (rcType) {
      Type elemType = rcType.getElementType();
      if (needsCustomRelease(elemType)) {
        // Use generated release function for recursive types
        auto releaseFunc = getOrGenerateReleaseFunction(
            module, elemType, *getTypeConverter(), rewriter);
        rewriter.create<LLVM::CallOp>(loc, releaseFunc, ValueRange{ptr});
        rewriter.eraseOp(op);
        return success();
      }
    }

    // Simple case: inline atomic decrement + conditional free
    
    // Atomic decrement: atomicrmw sub ptr, 1 (returns old value)
    auto one = rewriter.create<LLVM::ConstantOp>(
        loc, i32Ty, rewriter.getI32IntegerAttr(1));
    auto oldCount = rewriter.create<LLVM::AtomicRMWOp>(
        loc, LLVM::AtomicBinOp::sub, ptr, one,
        LLVM::AtomicOrdering::seq_cst);

    // Check if old count was 1 (meaning new count is 0)
    auto cmp = rewriter.create<LLVM::ICmpOp>(
        loc, LLVM::ICmpPredicate::eq, oldCount, one);

    // Conditional free - we need to split the block and create branches
    auto freeFn = getOrInsertFree(module, rewriter);

    // Get the current block and split it
    Block *currentBlock = rewriter.getInsertionBlock();
    
    // We need to split the block at the current insertion point
    Block::iterator splitPoint = rewriter.getInsertionPoint();
    Block *contBlock = rewriter.splitBlock(currentBlock, splitPoint);
    
    // Create a block for the free
    Block *freeBlock = rewriter.createBlock(contBlock);

    // In free block: free and branch to continuation
    rewriter.setInsertionPointToStart(freeBlock);
    rewriter.create<LLVM::CallOp>(loc, freeFn, ValueRange{ptr});
    rewriter.create<LLVM::BrOp>(loc, ValueRange{}, contBlock);

    // In current block: conditional branch
    rewriter.setInsertionPointToEnd(currentBlock);
    rewriter.create<LLVM::CondBrOp>(loc, cmp, freeBlock, contBlock);

    rewriter.eraseOp(op);
    return success();
  }
};

/// Lowers cal.rc.load to load payload from proper offset after refcount.
struct RCLoadOpLowering : public ConvertOpToLLVMPattern<RCLoadOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(RCLoadOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto *ctx = rewriter.getContext();
    auto ptrTy = LLVM::LLVMPointerType::get(ctx);
    auto i64Ty = IntegerType::get(ctx, 64);

    Value ptr = adaptor.getRc();

    // Get the converted payload type and compute proper offset
    auto resultTy = getTypeConverter()->convertType(op.getValue().getType());
    int64_t payloadAlign = getTypeAlignmentInBytes(*getTypeConverter(), resultTy);
    // Offset = refcount (4 bytes) aligned up to payload alignment
    int64_t payloadOffset = (4 + payloadAlign - 1) & ~(payloadAlign - 1);

    // Get pointer to payload
    auto offsetVal = rewriter.create<LLVM::ConstantOp>(
        loc, i64Ty, rewriter.getI64IntegerAttr(payloadOffset));
    auto payloadPtr = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, IntegerType::get(ctx, 8), ptr, ValueRange{offsetVal});

    // Load the payload
    auto loaded = rewriter.create<LLVM::LoadOp>(loc, resultTy, payloadPtr);

    rewriter.replaceOp(op, loaded);
    return success();
  }
};

/// Lowers cal.rc.store to store payload at proper offset after refcount.
struct RCStoreOpLowering : public ConvertOpToLLVMPattern<RCStoreOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(RCStoreOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto *ctx = rewriter.getContext();
    auto ptrTy = LLVM::LLVMPointerType::get(ctx);
    auto i64Ty = IntegerType::get(ctx, 64);

    Value ptr = adaptor.getRc();
    Value newValue = adaptor.getValue();

    // Get proper offset based on payload alignment
    Type payloadTy = newValue.getType();
    int64_t payloadAlign = getTypeAlignmentInBytes(*getTypeConverter(), payloadTy);
    int64_t payloadOffset = (4 + payloadAlign - 1) & ~(payloadAlign - 1);

    // Get pointer to payload
    auto offsetVal = rewriter.create<LLVM::ConstantOp>(
        loc, i64Ty, rewriter.getI64IntegerAttr(payloadOffset));
    auto payloadPtr = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, IntegerType::get(ctx, 8), ptr, ValueRange{offsetVal});

    // Store the new value
    rewriter.create<LLVM::StoreOp>(loc, newValue, payloadPtr);

    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// Token Operation Lowering
//===----------------------------------------------------------------------===//

/// Lowers cal.token.wrap to malloc + store.
struct TokenWrapOpLowering : public ConvertOpToLLVMPattern<TokenWrapOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(TokenWrapOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto *ctx = rewriter.getContext();
    auto module = op->getParentOfType<ModuleOp>();
    auto i64Ty = IntegerType::get(ctx, 64);

    // Compute actual size based on the value's LLVM type
    Type valueLLVMType = adaptor.getValue().getType();
    int64_t size = getTypeSizeInBytes(*getTypeConverter(), valueLLVMType);

    auto mallocFn = getOrInsertMalloc(module, rewriter);
    auto sizeVal = rewriter.create<LLVM::ConstantOp>(
        loc, i64Ty, rewriter.getI64IntegerAttr(size));
    auto allocResult = rewriter.create<LLVM::CallOp>(loc, mallocFn, ValueRange{sizeVal});
    Value ptr = allocResult.getResult();

    // Store the value
    rewriter.create<LLVM::StoreOp>(loc, adaptor.getValue(), ptr);

    rewriter.replaceOp(op, ptr);
    return success();
  }
};

/// Lowers cal.token.unwrap to load (ownership transfer, no deallocation).
struct TokenUnwrapOpLowering : public ConvertOpToLLVMPattern<TokenUnwrapOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(TokenUnwrapOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();

    Value ptr = adaptor.getToken();

    // Load the value from the token
    auto resultTy = getTypeConverter()->convertType(op.getValue().getType());
    auto loaded = rewriter.create<LLVM::LoadOp>(loc, resultTy, ptr);

    // Note: We don't free here because ownership is transferred to the arena.
    // The arena will free all memory when destroyed.

    rewriter.replaceOp(op, loaded);
    return success();
  }
};

/// Lowers cal.token.consume to free.
struct TokenConsumeOpLowering : public ConvertOpToLLVMPattern<TokenConsumeOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(TokenConsumeOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto module = op->getParentOfType<ModuleOp>();

    Value ptr = adaptor.getToken();

    // Free the token memory
    auto freeFn = getOrInsertFree(module, rewriter);
    rewriter.create<LLVM::CallOp>(loc, freeFn, ValueRange{ptr});

    rewriter.eraseOp(op);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// Boxing Operation Lowering
//===----------------------------------------------------------------------===//

/// Lowers cal.box.in_arena to arena allocation + store with bounds checking.
/// Now correctly updates the arena offset via the pointer-to-struct arena.
struct BoxInArenaOpLowering : public ConvertOpToLLVMPattern<BoxInArenaOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(BoxInArenaOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto *ctx = rewriter.getContext();
    auto module = op->getParentOfType<ModuleOp>();
    auto i64Ty = IntegerType::get(ctx, 64);
    auto i32Ty = IntegerType::get(ctx, 32);
    auto ptrTy = LLVM::LLVMPointerType::get(ctx);
    auto arenaStructTy = getArenaStructType(ctx);

    // adaptor.getArena() is now a pointer to the arena struct
    Value arenaPtr = adaptor.getArena();

    // Compute actual size/alignment based on value type
    Type valueLLVMType = adaptor.getValue().getType();
    int64_t valueSize = getTypeSizeInBytes(*getTypeConverter(), valueLLVMType);
    int64_t align = getTypeAlignmentInBytes(*getTypeConverter(), valueLLVMType);

    auto zero32 = rewriter.create<LLVM::ConstantOp>(loc, i32Ty, rewriter.getI32IntegerAttr(0));
    auto one32 = rewriter.create<LLVM::ConstantOp>(loc, i32Ty, rewriter.getI32IntegerAttr(1));
    auto two32 = rewriter.create<LLVM::ConstantOp>(loc, i32Ty, rewriter.getI32IntegerAttr(2));

    // Load base pointer from arena struct (field 0)
    auto basePtrSlot = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, arenaStructTy, arenaPtr, ValueRange{zero32, zero32});
    auto basePtr = rewriter.create<LLVM::LoadOp>(loc, ptrTy, basePtrSlot);

    // Load current offset from arena struct (field 1)
    auto offsetSlot = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, arenaStructTy, arenaPtr, ValueRange{zero32, one32});
    auto currentOffset = rewriter.create<LLVM::LoadOp>(loc, i64Ty, offsetSlot);

    // Load capacity from arena struct (field 2)
    auto capacitySlot = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, arenaStructTy, arenaPtr, ValueRange{zero32, two32});
    auto capacity = rewriter.create<LLVM::LoadOp>(loc, i64Ty, capacitySlot);

    // Align the offset: aligned = (offset + align - 1) & ~(align - 1)
    auto alignVal = rewriter.create<LLVM::ConstantOp>(
        loc, i64Ty, rewriter.getI64IntegerAttr(align));
    auto one = rewriter.create<LLVM::ConstantOp>(
        loc, i64Ty, rewriter.getI64IntegerAttr(1));
    auto alignM1 = rewriter.create<LLVM::SubOp>(loc, alignVal, one);
    auto offsetPlusAlignM1 = rewriter.create<LLVM::AddOp>(loc, currentOffset, alignM1);
    auto negAlignM1 = rewriter.create<LLVM::XOrOp>(
        loc, alignM1,
        rewriter.create<LLVM::ConstantOp>(loc, i64Ty, rewriter.getI64IntegerAttr(-1)));
    auto alignedOffset = rewriter.create<LLVM::AndOp>(loc, offsetPlusAlignM1, negAlignM1);

    // Compute new offset: newOffset = alignedOffset + valueSize
    auto sizeVal = rewriter.create<LLVM::ConstantOp>(
        loc, i64Ty, rewriter.getI64IntegerAttr(valueSize));
    auto newOffset = rewriter.create<LLVM::AddOp>(loc, alignedOffset, sizeVal);

    // Bounds check: if newOffset > capacity, call abort
    auto overflow = rewriter.create<LLVM::ICmpOp>(
        loc, LLVM::ICmpPredicate::ugt, newOffset, capacity);

    // Create blocks for bounds check
    Block *currentBlock = rewriter.getInsertionBlock();
    Block::iterator splitPoint = rewriter.getInsertionPoint();
    Block *contBlock = rewriter.splitBlock(currentBlock, splitPoint);
    Block *abortBlock = rewriter.createBlock(contBlock);

    // In abort block: call abort() (does not return)
    rewriter.setInsertionPointToStart(abortBlock);
    auto abortFn = getOrInsertAbort(module, rewriter);
    rewriter.create<LLVM::CallOp>(loc, abortFn, ValueRange{});
    rewriter.create<LLVM::UnreachableOp>(loc);

    // In current block: conditional branch based on overflow check
    rewriter.setInsertionPointToEnd(currentBlock);
    rewriter.create<LLVM::CondBrOp>(loc, overflow, abortBlock, contBlock);

    // Continue in contBlock after the bounds check passes
    rewriter.setInsertionPointToStart(contBlock);

    // Store new offset back to arena struct (IN-PLACE UPDATE - this is the critical fix!)
    rewriter.create<LLVM::StoreOp>(loc, newOffset, offsetSlot);

    // Compute result pointer: base + alignedOffset
    auto resultPtr = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, IntegerType::get(ctx, 8), basePtr, ValueRange{alignedOffset});

    // Store the value
    rewriter.create<LLVM::StoreOp>(loc, adaptor.getValue(), resultPtr);

    rewriter.replaceOp(op, resultPtr);
    return success();
  }
};

/// Lowers cal.unbox to load from pointer.
struct UnboxOpLowering : public ConvertOpToLLVMPattern<UnboxOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(UnboxOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();

    Value ptr = adaptor.getBoxed();
    auto resultTy = getTypeConverter()->convertType(op.getValue().getType());

    auto loaded = rewriter.create<LLVM::LoadOp>(loc, resultTy, ptr);

    rewriter.replaceOp(op, loaded);
    return success();
  }
};

/// Lowers cal.deep_copy to arena allocation + copy with bounds checking.
///
/// For recursive types containing boxed pointers, a true deep copy would need
/// to recursively copy each boxed field. However, full recursive deep copy
/// requires type introspection that's complex to implement in a general way.
///
/// Current implementation:
/// - Allocates space in the target arena for the value
/// - Checks bounds before allocation
/// - Copies the value to the new location (shallow struct copy)
/// - For simple types, this is a complete deep copy
/// - For types with boxed pointers, those pointers are copied as-is
///
/// TODO: For full deep copy of recursive types, consider:
/// 1. Generating type-specific copy functions during dialect lowering
/// 2. Or using a runtime copy function that walks the type structure
struct DeepCopyOpLowering : public ConvertOpToLLVMPattern<DeepCopyOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(DeepCopyOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto *ctx = rewriter.getContext();
    auto module = op->getParentOfType<ModuleOp>();
    auto i64Ty = IntegerType::get(ctx, 64);
    auto i32Ty = IntegerType::get(ctx, 32);
    auto ptrTy = LLVM::LLVMPointerType::get(ctx);
    auto arenaStructTy = getArenaStructType(ctx);

    Value arenaPtr = adaptor.getTargetArena();
    Value srcValue = adaptor.getValue();

    // Get the LLVM type of the value and compute size/alignment
    Type valueLLVMType = srcValue.getType();
    int64_t valueSize = getTypeSizeInBytes(*getTypeConverter(), valueLLVMType);
    int64_t align = getTypeAlignmentInBytes(*getTypeConverter(), valueLLVMType);

    auto zero32 = rewriter.create<LLVM::ConstantOp>(loc, i32Ty, rewriter.getI32IntegerAttr(0));
    auto one32 = rewriter.create<LLVM::ConstantOp>(loc, i32Ty, rewriter.getI32IntegerAttr(1));
    auto two32 = rewriter.create<LLVM::ConstantOp>(loc, i32Ty, rewriter.getI32IntegerAttr(2));

    // Load base pointer from arena struct (field 0)
    auto basePtrSlot = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, arenaStructTy, arenaPtr, ValueRange{zero32, zero32});
    auto basePtr = rewriter.create<LLVM::LoadOp>(loc, ptrTy, basePtrSlot);

    // Load current offset from arena struct (field 1)
    auto offsetSlot = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, arenaStructTy, arenaPtr, ValueRange{zero32, one32});
    auto currentOffset = rewriter.create<LLVM::LoadOp>(loc, i64Ty, offsetSlot);

    // Load capacity from arena struct (field 2)
    auto capacitySlot = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, arenaStructTy, arenaPtr, ValueRange{zero32, two32});
    auto capacity = rewriter.create<LLVM::LoadOp>(loc, i64Ty, capacitySlot);

    // Align the offset: aligned = (offset + align - 1) & ~(align - 1)
    auto alignVal = rewriter.create<LLVM::ConstantOp>(
        loc, i64Ty, rewriter.getI64IntegerAttr(align));
    auto one = rewriter.create<LLVM::ConstantOp>(
        loc, i64Ty, rewriter.getI64IntegerAttr(1));
    auto alignM1 = rewriter.create<LLVM::SubOp>(loc, alignVal, one);
    auto offsetPlusAlignM1 = rewriter.create<LLVM::AddOp>(loc, currentOffset, alignM1);
    auto negAlignM1 = rewriter.create<LLVM::XOrOp>(
        loc, alignM1,
        rewriter.create<LLVM::ConstantOp>(loc, i64Ty, rewriter.getI64IntegerAttr(-1)));
    auto alignedOffset = rewriter.create<LLVM::AndOp>(loc, offsetPlusAlignM1, negAlignM1);

    // Compute new offset: newOffset = alignedOffset + valueSize
    auto sizeVal = rewriter.create<LLVM::ConstantOp>(
        loc, i64Ty, rewriter.getI64IntegerAttr(valueSize));
    auto newOffset = rewriter.create<LLVM::AddOp>(loc, alignedOffset, sizeVal);

    // Bounds check: if newOffset > capacity, call abort
    auto overflow = rewriter.create<LLVM::ICmpOp>(
        loc, LLVM::ICmpPredicate::ugt, newOffset, capacity);

    // Create blocks for bounds check
    Block *currentBlock = rewriter.getInsertionBlock();
    Block::iterator splitPoint = rewriter.getInsertionPoint();
    Block *contBlock = rewriter.splitBlock(currentBlock, splitPoint);
    Block *abortBlock = rewriter.createBlock(contBlock);

    // In abort block: call abort() (does not return)
    rewriter.setInsertionPointToStart(abortBlock);
    auto abortFn = getOrInsertAbort(module, rewriter);
    rewriter.create<LLVM::CallOp>(loc, abortFn, ValueRange{});
    rewriter.create<LLVM::UnreachableOp>(loc);

    // In current block: conditional branch based on overflow check
    rewriter.setInsertionPointToEnd(currentBlock);
    rewriter.create<LLVM::CondBrOp>(loc, overflow, abortBlock, contBlock);

    // Continue in contBlock after the bounds check passes
    rewriter.setInsertionPointToStart(contBlock);

    // Store new offset back to arena struct
    rewriter.create<LLVM::StoreOp>(loc, newOffset, offsetSlot);

    // Compute destination pointer: base + alignedOffset
    auto dstPtr = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, IntegerType::get(ctx, 8), basePtr, ValueRange{alignedOffset});

    // Store the value to the arena (this is a shallow struct copy)
    rewriter.create<LLVM::StoreOp>(loc, srcValue, dstPtr);

    // Load the value back from the new location
    // This ensures the result is a proper SSA value, not a pointer
    auto copiedValue = rewriter.create<LLVM::LoadOp>(loc, valueLLVMType, dstPtr);

    rewriter.replaceOp(op, copiedValue);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// Type Converter Setup
//===----------------------------------------------------------------------===//

/// Helper function to compute the LLVM struct type for a VariantType.
/// The layout is: { i32 tag, array<N x i8> payload } where N is the max payload size.
static LLVM::LLVMStructType getVariantLLVMType(MLIRContext *ctx, VariantType varTy,
                                               const LLVMTypeConverter &converter) {
  int64_t maxPayloadSize = 0;
  for (Attribute variantAttr : varTy.getVariants()) {
    auto dict = cast<DictionaryAttr>(variantAttr);
    auto fieldTypesAttr = dict.getAs<ArrayAttr>("types");
    if (!fieldTypesAttr)
      continue;

    int64_t thisPayloadSize = 0;
    for (Attribute fieldTypeAttr : fieldTypesAttr) {
      Type fieldType = cast<TypeAttr>(fieldTypeAttr).getValue();
      Type llvmType = converter.convertType(fieldType);
      if (!llvmType)
        continue;
      // Get size from DataLayout if available, otherwise estimate
      auto dataLayout = DataLayout();
      if (auto structTy = dyn_cast<LLVM::LLVMStructType>(llvmType)) {
        // Estimate struct size as sum of field sizes
        unsigned sz = 0;
        for (Type ft : structTy.getBody())
          sz += llvm::divideCeil(dataLayout.getTypeSizeInBits(ft), 8);
        thisPayloadSize += sz;
      } else {
        thisPayloadSize += llvm::divideCeil(dataLayout.getTypeSizeInBits(llvmType), 8);
      }
    }
    maxPayloadSize = std::max(maxPayloadSize, thisPayloadSize);
  }

  // Ensure at least some minimum payload size for alignment
  if (maxPayloadSize < 4)
    maxPayloadSize = 4;

  auto i32Ty = IntegerType::get(ctx, 32);
  auto i8Ty = IntegerType::get(ctx, 8);
  auto payloadTy = LLVM::LLVMArrayType::get(i8Ty, maxPayloadSize);

  return LLVM::LLVMStructType::getLiteral(ctx, {i32Ty, payloadTy});
}

class CalMemoryTypeConverter : public LLVMTypeConverter {
public:
  CalMemoryTypeConverter(MLIRContext *ctx) : LLVMTypeConverter(ctx) {
    // Convert !cal.arena to a POINTER to the arena struct type.
    // This enables in-place updates of the offset field when allocating.
    // The arena struct { ptr base, i64 offset, i64 capacity } is heap-allocated
    // and the !cal.arena value is a pointer to it.
    addConversion([ctx](ArenaType type) -> Type {
      return LLVM::LLVMPointerType::get(ctx);
    });

    // Convert !cal.rc<T> to opaque pointer
    addConversion([ctx](RCType type) -> Type {
      return LLVM::LLVMPointerType::get(ctx);
    });

    // Convert !cal.token<T> to opaque pointer
    addConversion([ctx](TokenType type) -> Type {
      return LLVM::LLVMPointerType::get(ctx);
    });

    // Convert !cal.variant to struct { i32 tag, i8[N] payload }
    addConversion([this](VariantType type) -> Type {
      return getVariantLLVMType(type.getContext(), type, *this);
    });

    // Convert !cal.product to struct { field1, field2, ... }
    addConversion([this](ProductType type) -> Type {
      SmallVector<Type> llvmFieldTypes;
      for (Attribute attr : type.getFields()) {
        auto dict = cast<DictionaryAttr>(attr);
        auto fieldType = dict.getAs<TypeAttr>("type").getValue();
        Type llvmType = this->convertType(fieldType);
        if (!llvmType)
          return Type(); // Conversion failed
        llvmFieldTypes.push_back(llvmType);
      }
      return LLVM::LLVMStructType::getLiteral(type.getContext(), llvmFieldTypes);
    });
  }
};

//===----------------------------------------------------------------------===//
// Pass Implementation
//===----------------------------------------------------------------------===//

class ConvertCalMemoryToLLVMPass
    : public impl::ConvertCalMemoryToLLVMBase<ConvertCalMemoryToLLVMPass> {
public:
  void runOnOperation() override {
    ModuleOp module = getOperation();
    MLIRContext *ctx = &getContext();

    CalMemoryTypeConverter typeConverter(ctx);

    ConversionTarget target(*ctx);
    target.addLegalDialect<LLVM::LLVMDialect>();
    target.addIllegalOp<
        ArenaCreateOp, ArenaDestroyOp, ArenaAllocOp,
        RCAllocOp, RCRetainOp, RCReleaseOp, RCLoadOp, RCStoreOp,
        TokenWrapOp, TokenUnwrapOp, TokenConsumeOp,
        BoxInArenaOp, UnboxOp, DeepCopyOp>();

    RewritePatternSet patterns(ctx);

    // Arena patterns
    patterns.add<ArenaCreateOpLowering>(typeConverter);
    patterns.add<ArenaDestroyOpLowering>(typeConverter);
    patterns.add<ArenaAllocOpLowering>(typeConverter);

    // RC patterns
    patterns.add<RCAllocOpLowering>(typeConverter);
    patterns.add<RCRetainOpLowering>(typeConverter);
    patterns.add<RCReleaseOpLowering>(typeConverter);
    patterns.add<RCLoadOpLowering>(typeConverter);
    patterns.add<RCStoreOpLowering>(typeConverter);

    // Token patterns
    patterns.add<TokenWrapOpLowering>(typeConverter);
    patterns.add<TokenUnwrapOpLowering>(typeConverter);
    patterns.add<TokenConsumeOpLowering>(typeConverter);

    // Boxing patterns
    patterns.add<BoxInArenaOpLowering>(typeConverter);
    patterns.add<UnboxOpLowering>(typeConverter);
    patterns.add<DeepCopyOpLowering>(typeConverter);

    if (failed(applyPartialConversion(module, target, std::move(patterns))))
      signalPassFailure();
  }
};

} // namespace mlir
