//===- CalVariantToLLVM.cpp - Lower CAL variant/product ops to LLVM -------===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements lowering of CAL variant and product type operations
// to the LLVM dialect. Variants are represented as tagged unions (tag + payload)
// and products as simple structs with fields in declaration order.
//
//===----------------------------------------------------------------------===//

#include "Conversion/CalVariantToLLVM/CalVariantToLLVM.h"
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

#define GEN_PASS_DEF_CONVERTCALVARIANTTOLLVM
#include "Conversion/Passes.h.inc"

using namespace cal;

//===----------------------------------------------------------------------===//
// Helper Functions
//===----------------------------------------------------------------------===//

/// Compute the size in bytes for a given MLIR type.
/// Returns 0 for types we can't size (e.g., unknown types).
static int64_t getTypeSizeInBytes(Type type, const DataLayout &dataLayout) {
  if (auto intTy = dyn_cast<IntegerType>(type))
    return (intTy.getWidth() + 7) / 8;
  if (auto floatTy = dyn_cast<FloatType>(type))
    return floatTy.getWidth() / 8;
  if (isa<IndexType>(type))
    return 8; // Assume 64-bit index
  if (isa<LLVM::LLVMPointerType>(type))
    return 8; // Assume 64-bit pointers
  // For complex types, try using the data layout
  // Fall back to a reasonable default
  return 8;
}

/// Get the type of a specific field in a variant.
/// Returns the field types as a vector for the given variant name.
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

/// Get the index of a variant by name (0-based).
static int64_t getVariantIndex(VariantType varTy, StringRef variantName) {
  int64_t idx = 0;
  for (Attribute attr : varTy.getVariants()) {
    auto dict = cast<DictionaryAttr>(attr);
    auto name = dict.getAs<StringAttr>("name").getValue();
    if (name == variantName)
      return idx;
    idx++;
  }
  return -1; // Not found
}

/// Compute the maximum payload size across all variants.
static int64_t getMaxPayloadSize(VariantType varTy, const LLVMTypeConverter &converter) {
  int64_t maxSize = 0;
  for (Attribute attr : varTy.getVariants()) {
    auto dict = cast<DictionaryAttr>(attr);
    auto fields = dict.getAs<ArrayAttr>("fields");
    int64_t variantSize = 0;
    for (Attribute fieldAttr : fields) {
      Type fieldTy = cast<TypeAttr>(fieldAttr).getValue();
      Type llvmTy = converter.convertType(fieldTy);
      // Rough size estimation - could be improved with proper data layout
      if (auto intTy = dyn_cast<IntegerType>(llvmTy))
        variantSize += (intTy.getWidth() + 7) / 8;
      else if (auto floatTy = dyn_cast<FloatType>(llvmTy))
        variantSize += floatTy.getWidth() / 8;
      else
        variantSize += 8; // Default to pointer size
    }
    maxSize = std::max(maxSize, variantSize);
  }
  // Minimum payload size of 1 byte for variants with no fields
  return std::max(maxSize, (int64_t)1);
}

/// Get the LLVM struct type for a variant.
/// Layout: { i32 tag, [max_payload_size x i8] payload }
static LLVM::LLVMStructType getVariantLLVMType(MLIRContext *ctx, 
                                                VariantType varTy,
                                                const LLVMTypeConverter &converter) {
  auto i32Ty = IntegerType::get(ctx, 32);
  int64_t payloadSize = getMaxPayloadSize(varTy, converter);
  auto payloadTy = LLVM::LLVMArrayType::get(IntegerType::get(ctx, 8), payloadSize);
  return LLVM::LLVMStructType::getLiteral(ctx, {i32Ty, payloadTy});
}

/// Get product field types from the product type definition.
static SmallVector<Type> getProductFieldTypes(ProductType prodTy) {
  SmallVector<Type> result;
  for (Attribute attr : prodTy.getFields()) {
    auto dict = cast<DictionaryAttr>(attr);
    auto fieldType = dict.getAs<TypeAttr>("type").getValue();
    result.push_back(fieldType);
  }
  return result;
}

/// Get the index of a field by name in a product type.
static int64_t getProductFieldIndex(ProductType prodTy, StringRef fieldName) {
  int64_t idx = 0;
  for (Attribute attr : prodTy.getFields()) {
    auto dict = cast<DictionaryAttr>(attr);
    auto name = dict.getAs<StringAttr>("name").getValue();
    if (name == fieldName)
      return idx;
    idx++;
  }
  return -1; // Not found
}

//===----------------------------------------------------------------------===//
// Type Converter
//===----------------------------------------------------------------------===//

class CalVariantTypeConverter : public LLVMTypeConverter {
public:
  CalVariantTypeConverter(MLIRContext *ctx) : LLVMTypeConverter(ctx) {
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
// Variant Operation Lowering
//===----------------------------------------------------------------------===//

/// Lower cal.variant.create to LLVM struct construction.
struct VariantCreateOpLowering : public ConvertOpToLLVMPattern<VariantCreateOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(VariantCreateOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto *ctx = rewriter.getContext();
    
    auto varTy = cast<VariantType>(op.getResult().getType());
    auto llvmStructTy = cast<LLVM::LLVMStructType>(
        getTypeConverter()->convertType(varTy));
    
    // Get the variant index for the tag
    StringRef variantName = op.getVariantName();
    int64_t tagValue = getVariantIndex(varTy, variantName);
    if (tagValue < 0)
      return op.emitError("unknown variant name: ") << variantName;

    // Create undef struct
    Value result = rewriter.create<LLVM::UndefOp>(loc, llvmStructTy);

    // Insert tag (field 0)
    auto i32Ty = IntegerType::get(ctx, 32);
    auto tagConst = rewriter.create<LLVM::ConstantOp>(
        loc, i32Ty, rewriter.getI32IntegerAttr(tagValue));
    result = rewriter.create<LLVM::InsertValueOp>(
        loc, result, tagConst, ArrayRef<int64_t>{0});

    // Store fields into the payload
    // We need to get a pointer to the payload and store each field
    if (!adaptor.getFields().empty()) {
      // Allocate temporary storage on stack for the struct
      auto one = rewriter.create<LLVM::ConstantOp>(
          loc, IntegerType::get(ctx, 64), rewriter.getI64IntegerAttr(1));
      auto ptrTy = LLVM::LLVMPointerType::get(ctx);
      auto structPtr = rewriter.create<LLVM::AllocaOp>(
          loc, ptrTy, llvmStructTy, one);
      
      // Store the result so far
      rewriter.create<LLVM::StoreOp>(loc, result, structPtr);
      
      // Get pointer to payload (field 1 of the struct)
      auto zero32 = rewriter.create<LLVM::ConstantOp>(
          loc, IntegerType::get(ctx, 32), rewriter.getI32IntegerAttr(0));
      auto one32 = rewriter.create<LLVM::ConstantOp>(
          loc, IntegerType::get(ctx, 32), rewriter.getI32IntegerAttr(1));
      auto payloadPtr = rewriter.create<LLVM::GEPOp>(
          loc, ptrTy, llvmStructTy, structPtr, ValueRange{zero32, one32});
      
      // Store each field at its offset in the payload
      int64_t offset = 0;
      auto i8Ty = IntegerType::get(ctx, 8);
      for (auto [idx, field] : llvm::enumerate(adaptor.getFields())) {
        Type fieldLLVMTy = field.getType();
        
        // Compute field pointer at current offset
        auto offsetVal = rewriter.create<LLVM::ConstantOp>(
            loc, IntegerType::get(ctx, 64), rewriter.getI64IntegerAttr(offset));
        auto fieldPtr = rewriter.create<LLVM::GEPOp>(
            loc, ptrTy, i8Ty, payloadPtr, ValueRange{offsetVal});
        
        // Store the field
        rewriter.create<LLVM::StoreOp>(loc, field, fieldPtr);
        
        // Update offset for next field
        if (auto intTy = dyn_cast<IntegerType>(fieldLLVMTy))
          offset += (intTy.getWidth() + 7) / 8;
        else if (auto floatTy = dyn_cast<FloatType>(fieldLLVMTy))
          offset += floatTy.getWidth() / 8;
        else
          offset += 8; // Default pointer size
      }
      
      // Load back the complete struct
      result = rewriter.create<LLVM::LoadOp>(loc, llvmStructTy, structPtr);
    }

    rewriter.replaceOp(op, result);
    return success();
  }
};

/// Lower cal.variant.get_tag to extractvalue of the tag field.
struct VariantGetTagOpLowering : public ConvertOpToLLVMPattern<VariantGetTagOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(VariantGetTagOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto *ctx = rewriter.getContext();
    
    // Extract the i32 tag from field 0
    auto tagI32 = rewriter.create<LLVM::ExtractValueOp>(
        loc, adaptor.getVariant(), ArrayRef<int64_t>{0});
    
    // Convert i32 to index
    auto indexTy = IndexType::get(ctx);
    auto tag = rewriter.create<LLVM::ZExtOp>(
        loc, IntegerType::get(ctx, 64), tagI32);
    
    // Use unrealized_conversion_cast to convert i64 to index
    auto indexVal = rewriter.create<UnrealizedConversionCastOp>(
        loc, indexTy, ValueRange{tag});
    
    rewriter.replaceOp(op, indexVal.getResult(0));
    return success();
  }
};

/// Lower cal.variant.get_field to loading from the payload.
struct VariantGetFieldOpLowering : public ConvertOpToLLVMPattern<VariantGetFieldOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(VariantGetFieldOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    auto *ctx = rewriter.getContext();
    
    auto varTy = cast<VariantType>(op.getVariant().getType());
    auto llvmStructTy = cast<LLVM::LLVMStructType>(
        getTypeConverter()->convertType(varTy));
    
    // Get the field types for this variant
    StringRef variantName = op.getVariantName();
    auto fieldTypes = getVariantFieldTypes(varTy, variantName);
    int64_t fieldIndex = op.getFieldIndex();
    
    if (fieldIndex >= (int64_t)fieldTypes.size())
      return op.emitError("field index out of bounds");
    
    Type resultTy = getTypeConverter()->convertType(op.getResult().getType());
    if (!resultTy)
      return op.emitError("failed to convert result type");
    
    // Allocate stack storage for the variant
    auto ptrTy = LLVM::LLVMPointerType::get(ctx);
    auto one = rewriter.create<LLVM::ConstantOp>(
        loc, IntegerType::get(ctx, 64), rewriter.getI64IntegerAttr(1));
    auto structPtr = rewriter.create<LLVM::AllocaOp>(
        loc, ptrTy, llvmStructTy, one);
    
    // Store the variant
    rewriter.create<LLVM::StoreOp>(loc, adaptor.getVariant(), structPtr);
    
    // Get pointer to payload (field 1)
    auto zero32 = rewriter.create<LLVM::ConstantOp>(
        loc, IntegerType::get(ctx, 32), rewriter.getI32IntegerAttr(0));
    auto one32 = rewriter.create<LLVM::ConstantOp>(
        loc, IntegerType::get(ctx, 32), rewriter.getI32IntegerAttr(1));
    auto payloadPtr = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, llvmStructTy, structPtr, ValueRange{zero32, one32});
    
    // Compute offset to the desired field
    int64_t offset = 0;
    for (int64_t i = 0; i < fieldIndex; i++) {
      Type fieldTy = getTypeConverter()->convertType(fieldTypes[i]);
      if (auto intTy = dyn_cast<IntegerType>(fieldTy))
        offset += (intTy.getWidth() + 7) / 8;
      else if (auto floatTy = dyn_cast<FloatType>(fieldTy))
        offset += floatTy.getWidth() / 8;
      else
        offset += 8;
    }
    
    // Get pointer to field and load
    auto i8Ty = IntegerType::get(ctx, 8);
    auto offsetVal = rewriter.create<LLVM::ConstantOp>(
        loc, IntegerType::get(ctx, 64), rewriter.getI64IntegerAttr(offset));
    auto fieldPtr = rewriter.create<LLVM::GEPOp>(
        loc, ptrTy, i8Ty, payloadPtr, ValueRange{offsetVal});
    
    auto result = rewriter.create<LLVM::LoadOp>(loc, resultTy, fieldPtr);
    
    rewriter.replaceOp(op, result);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// Product Operation Lowering
//===----------------------------------------------------------------------===//

/// Lower cal.product.create to LLVM struct construction.
struct ProductCreateOpLowering : public ConvertOpToLLVMPattern<ProductCreateOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(ProductCreateOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    
    auto prodTy = cast<ProductType>(op.getResult().getType());
    auto llvmStructTy = cast<LLVM::LLVMStructType>(
        getTypeConverter()->convertType(prodTy));
    
    // Create undef struct and insert each field
    Value result = rewriter.create<LLVM::UndefOp>(loc, llvmStructTy);
    
    for (auto [idx, field] : llvm::enumerate(adaptor.getFields())) {
      result = rewriter.create<LLVM::InsertValueOp>(
          loc, result, field, ArrayRef<int64_t>{static_cast<int64_t>(idx)});
    }

    rewriter.replaceOp(op, result);
    return success();
  }
};

/// Lower cal.product.get_field to extractvalue.
struct ProductGetFieldOpLowering : public ConvertOpToLLVMPattern<ProductGetFieldOp> {
  using ConvertOpToLLVMPattern::ConvertOpToLLVMPattern;

  LogicalResult
  matchAndRewrite(ProductGetFieldOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto loc = op.getLoc();
    
    auto prodTy = cast<ProductType>(op.getProduct().getType());
    StringRef fieldName = op.getFieldName();
    
    int64_t fieldIndex = getProductFieldIndex(prodTy, fieldName);
    if (fieldIndex < 0)
      return op.emitError("unknown field name: ") << fieldName;
    
    auto result = rewriter.create<LLVM::ExtractValueOp>(
        loc, adaptor.getProduct(), ArrayRef<int64_t>{fieldIndex});

    rewriter.replaceOp(op, result);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// Pass Implementation
//===----------------------------------------------------------------------===//

class ConvertCalVariantToLLVMPass
    : public impl::ConvertCalVariantToLLVMBase<ConvertCalVariantToLLVMPass> {
public:
  void runOnOperation() override {
    ModuleOp module = getOperation();
    MLIRContext *ctx = &getContext();

    CalVariantTypeConverter typeConverter(ctx);

    ConversionTarget target(*ctx);
    target.addLegalDialect<LLVM::LLVMDialect>();
    target.addLegalOp<UnrealizedConversionCastOp>();
    target.addIllegalOp<VariantCreateOp, VariantGetTagOp, VariantGetFieldOp,
                        ProductCreateOp, ProductGetFieldOp>();
    
    // Also mark the variant.match and variant.yield as illegal
    // (they should be lowered to scf.if in an earlier pass)
    target.addIllegalOp<VariantMatchOp, VariantYieldOp>();

    RewritePatternSet patterns(ctx);

    // Variant patterns
    patterns.add<VariantCreateOpLowering>(typeConverter);
    patterns.add<VariantGetTagOpLowering>(typeConverter);
    patterns.add<VariantGetFieldOpLowering>(typeConverter);

    // Product patterns
    patterns.add<ProductCreateOpLowering>(typeConverter);
    patterns.add<ProductGetFieldOpLowering>(typeConverter);

    if (failed(applyPartialConversion(module, target, std::move(patterns))))
      signalPassFailure();
  }
};

} // namespace mlir

/// Creates a pass to lower CAL variant and product type operations to LLVM.
std::unique_ptr<mlir::Pass> mlir::createConvertCalVariantToLLVMPass() {
  return std::make_unique<mlir::ConvertCalVariantToLLVMPass>();
}
