//===- FifoPassesLowerFifoPrintToLLVM.cpp - Fifo passes -*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// @author Gareth Callanan
// Disclaimer - I have written the code myself but used ChatGPT to generate
// top level comments describing each class with the hope that it will make
// the code easier to understand.
//
//===----------------------------------------------------------------------===//

#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoPasses.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Rewrite/FrozenRewritePatternSet.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include <iostream>

namespace mlir::fifo {
#define GEN_PASS_DEF_LOWERFIFOPRINTTOLLVM
#include "Dialect/Fifo/FifoPasses.h.inc"

/// ConvertTensorPrintToPrint - Conversion pattern that lowers fifo.print_tensor
/// operations to nested scf.for loops with fifo.print operations.
///
/// This pattern handles tensors of arbitrary dimensions by:
/// 1. Converting tensors to memrefs using bufferization.to_memref for efficient
///    element access
/// 2. Creating nested loops for all dimensions, treating the last two
///    dimensions as a matrix
/// 3. Printing index indicators for tensors with more than 2 dimensions to show
///    which slice of the higher-dimensional tensor is being displayed
/// 4. Using matrix-style printing for the innermost two dimensions with
///    elements separated by spaces and rows separated by newlines
/// 5. Applying type-aware formatting using appropriate printf format specifiers
///    ("%f" for floats, "%d" for integers)
///
/// Example transformation:
///   Input: fifo.print_tensor(%tensor) : tensor<2x3x4xf32>
///   Output: Nested scf.for loops that print:
///     At index [0][][]:
///     [elem00 elem01 elem02 elem03]
///     [elem10 elem11 elem12 elem13]
///     [elem20 elem21 elem22 elem23]
///     At index [1][][]:
///     [elem30 elem31 elem32 elem33]
///     [elem40 elem41 elem42 elem43]
///     [elem50 elem51 elem52 elem53]
///
/// For 1D tensors, elements are printed in a single row. For 2D tensors,
/// they are printed as a matrix without index indicators.
class ConvertTensorPrintToPrint : public OpConversionPattern<PrintTensorOp> {
private:
  bool tensorsOnGpu;

public:
  ConvertTensorPrintToPrint(MLIRContext *context, bool tensorsOnGpu = false)
      : OpConversionPattern<PrintTensorOp>(context),
        tensorsOnGpu(tensorsOnGpu) {}

  LogicalResult
  matchAndRewrite(PrintTensorOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    mlir::Location loc = op.getLoc();

    Type tensorType = mlir::getType(op.getTensor());
    Type elementType;
    llvm::SmallVector<int64_t, 4> shape;
    Value tensorVal = adaptor.getTensor();
    if (auto memrefType = dyn_cast<MemRefType>(tensorType)) {
      shape.append(memrefType.getShape().begin(), memrefType.getShape().end());
      elementType = memrefType.getElementType();
    } else if (auto rankedTensorType = dyn_cast<RankedTensorType>(tensorType)) {
      shape.append(rankedTensorType.getShape().begin(),
                   rankedTensorType.getShape().end());
      elementType = rankedTensorType.getElementType();
      // Convert tensor to memref using bufferization.to_memref
      auto memrefTy = MemRefType::get(rankedTensorType.getShape(),
                                      rankedTensorType.getElementType());
      tensorVal = rewriter.create<mlir::bufferization::ToMemrefOp>(
          loc, memrefTy, tensorVal);
    } else {
      return rewriter.notifyMatchFailure(
          op, "Expected memref or ranked tensor type");
    }

    if (tensorsOnGpu) {
      Value memrefHost = rewriter.create<memref::AllocOp>(
          loc, MemRefType::get(shape, elementType));
      rewriter.create<gpu::MemcpyOp>(loc,
                                     /*asyncToken=*/Type(),
                                     /*asyncDependencies=*/ValueRange(),
                                     /*dst=*/memrefHost,
                                     /*src=*/tensorVal);
      tensorVal = memrefHost;
    }

    // Add scalar check
    if (shape.empty()) {
      return rewriter.notifyMatchFailure(op, "Scalar tensors not supported");
    }

    // Support tensors of arbitrary dimension
    // The last two dimensions are printed as a matrix
    // Outer dimensions print index indicators

    Value zero = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    Value one = rewriter.create<arith::ConstantIndexOp>(loc, 1);

    // Create nested loops for outer dimensions (all except last two)
    llvm::SmallVector<Value, 4> inductionVars;
    llvm::SmallVector<scf::ForOp, 4> outerLoops;

    for (size_t dim = 0; dim < shape.size(); ++dim) {
      Value dimSize = rewriter.create<arith::ConstantIndexOp>(loc, shape[dim]);

      if (dim < shape.size() - 2) {
        // For outer dimensions, create loops and print index indicators
        auto forOp = rewriter.create<scf::ForOp>(loc, zero, dimSize, one);
        outerLoops.push_back(forOp);
        inductionVars.push_back(forOp.getInductionVar());

        rewriter.setInsertionPointToStart(forOp.getBody());

        // Print index indicator for this dimension level
        std::string indexStr = "At index [";
        for (size_t i = 0; i <= dim; ++i) {
          if (i == dim) {
            indexStr += "%d";
          } else {
            indexStr += "%d][";
          }
        }
        for (size_t i = dim + 1; i < shape.size(); ++i) {
          indexStr += "][";
        }
        indexStr += "]:\n";

        llvm::SmallVector<Value, 4> printArgs;
        for (size_t i = 0; i <= dim; ++i) {
          printArgs.push_back(inductionVars[i]);
        }

        rewriter.create<fifo::PrintOp>(loc, StringRef(indexStr), printArgs);
      }
    }

    // Handle the last two dimensions as a matrix
    if (shape.size() >= 2) {
      auto rowDim = shape[shape.size() - 2];
      auto colDim = shape[shape.size() - 1];

      Value mVal = rewriter.create<arith::ConstantIndexOp>(loc, rowDim);
      Value nVal = rewriter.create<arith::ConstantIndexOp>(loc, colDim);

      // Row loop (outer matrix loop)
      auto outerLoop = rewriter.create<scf::ForOp>(loc, zero, mVal, one);
      rewriter.setInsertionPointToStart(outerLoop.getBody());

      // Column loop (inner matrix loop)
      auto innerLoop = rewriter.create<scf::ForOp>(loc, zero, nVal, one);
      rewriter.setInsertionPointToStart(innerLoop.getBody());

      // Load and print each element
      auto rowIdx = outerLoop.getInductionVar();
      auto colIdx = innerLoop.getInductionVar();

      // Build indices for memref.load - combine outer dimension indices with
      // matrix indices
      llvm::SmallVector<Value, 4> indices;
      indices.append(inductionVars.begin(), inductionVars.end());
      indices.push_back(rowIdx);
      indices.push_back(colIdx);

      auto loadOp =
          rewriter.create<memref::LoadOp>(loc, tensorVal, ValueRange(indices));

      // Print the element with format based on type
      if (mlir::isa<FloatType>(elementType)) {
        rewriter.create<fifo::PrintOp>(loc, StringRef("%f "),
                                       ArrayRef<Value>{loadOp});
      } else if (mlir::isa<IntegerType>(elementType)) {
        rewriter.create<fifo::PrintOp>(loc, StringRef("%d "),
                                       ArrayRef<Value>{loadOp});
      }

      // After inner loop, print newline
      rewriter.setInsertionPointAfter(innerLoop);
      rewriter.create<fifo::PrintOp>(loc, StringRef("\n"), ArrayRef<Value>{});

      // Set insertion point after the matrix loops
      rewriter.setInsertionPointAfter(outerLoop);
    } else if (shape.size() == 1) {
      // Handle 1D case - just print as a single row
      Value nVal = rewriter.create<arith::ConstantIndexOp>(loc, shape[0]);

      auto loop = rewriter.create<scf::ForOp>(loc, zero, nVal, one);
      rewriter.setInsertionPointToStart(loop.getBody());

      auto idx = loop.getInductionVar();
      auto loadOp =
          rewriter.create<memref::LoadOp>(loc, tensorVal, ValueRange{idx});

      if (mlir::isa<FloatType>(elementType)) {
        rewriter.create<fifo::PrintOp>(loc, StringRef("%f "),
                                       ArrayRef<Value>{loadOp});
      } else if (mlir::isa<IntegerType>(elementType)) {
        rewriter.create<fifo::PrintOp>(loc, StringRef("%d "),
                                       ArrayRef<Value>{loadOp});
      }

      rewriter.setInsertionPointAfter(loop);
      rewriter.create<fifo::PrintOp>(loc, StringRef("\n"), ArrayRef<Value>{});
    }

    // Set insertion point after all loops for cleanup
    if (!outerLoops.empty()) {
      rewriter.setInsertionPointAfter(outerLoops[0]);
    }

    rewriter.eraseOp(op);

    return success();
  }
};

/// ConvertPrintToLLVMPrint - Conversion pattern that lowers fifo.print
/// operations to printf calls in the LLVM dialect.
///
/// This pattern handles the conversion through several steps:
/// 1. Format String Handling: Retrieves the format string from the fifo.print
///    operation and creates a global constant string in the module for use
///    as the printf format specifier
/// 2. Variadic Argument Handling: Combines the format string with variadic
///    arguments into a single operand list for the printf function
/// 3. Function Insertion: Checks if printf is declared in the module and
///    inserts a declaration with signature i32 (i8*, ...) if necessary
/// 4. Global String Handling: Creates unique global strings for format
///    specifiers to ensure runtime availability
/// 5. Final Call: Creates LLVM::CallOp to call printf with combined operands
///    and erases the original fifo.print operation
///
/// This implementation is based on the PrintOpLowering class from the
/// toy-ch6 example in llvm-project/mlir/examples/toy/LowerToLLVM.cpp,
/// extended to handle format strings and variable parameters.
class ConvertPrintToLLVMPrint : public OpConversionPattern<PrintOp> {
  using OpConversionPattern<PrintOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(PrintOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {

    mlir::Location loc = op.getLoc();

    ModuleOp parentModule = op->getParentOfType<ModuleOp>();

    // Get a symbol reference to the printf function, inserting it if necessary.
    auto printfRef = getOrInsertPrintf(rewriter, parentModule);
    Value formatSpecifierCst =
        createGlobalString(loc, rewriter, "fmt_string",
                           StringRef(op.getFormat().str()), parentModule);

    mlir::Operation::operand_range args = op.getArgs();

    // Create a vector of operands to the printf, including the format string.
    // All f32 need to be converted to f64 or else printf does not generate nice
    // data.
    llvm::SmallVector<mlir::Value, 8> combinedOperands;
    combinedOperands.push_back(formatSpecifierCst);
    for (auto arg : args) {
      if (mlir::isa<FloatType>(arg.getType()) &&
          mlir::cast<FloatType>(arg.getType()).getWidth() == 32) {
        auto f64Ty = rewriter.getF64Type();
        arg = rewriter.create<LLVM::FPExtOp>(loc, f64Ty, arg);
      } else if (mlir::isa<IndexType>(arg.getType())) {
        auto i32Ty = rewriter.getI32Type();
        arg = rewriter.create<arith::IndexCastOp>(loc, i32Ty, arg);
      }
      combinedOperands.push_back(arg);
    }

    rewriter.create<LLVM::CallOp>(loc, getPrintfType(getContext()), printfRef,
                                  combinedOperands);

    rewriter.eraseOp(op);

    return success();
  }

private:
  static inline std::atomic<int> global_string_counter{0};
  /// Create a function declaration for printf, the signature is:
  ///   * `i32 (i8*, ...)`
  static LLVM::LLVMFunctionType getPrintfType(MLIRContext *context) {
    auto llvmI32Ty = IntegerType::get(context, 32);
    auto llvmPtrTy = LLVM::LLVMPointerType::get(context);
    auto llvmFnType = LLVM::LLVMFunctionType::get(llvmI32Ty, llvmPtrTy,
                                                  /*isVarArg=*/true);
    return llvmFnType;
  }

  /// Return a symbol reference to the printf function, inserting it into the
  /// module if necessary.
  static FlatSymbolRefAttr getOrInsertPrintf(PatternRewriter &rewriter,
                                             ModuleOp module) {
    auto *context = module.getContext();
    if (module.lookupSymbol<LLVM::LLVMFuncOp>("printf"))
      return SymbolRefAttr::get(context, "printf");

    // Insert the printf function into the body of the parent module.
    PatternRewriter::InsertionGuard insertGuard(rewriter);
    rewriter.setInsertionPointToStart(module.getBody());
    rewriter.create<LLVM::LLVMFuncOp>(module.getLoc(), "printf",
                                      getPrintfType(context));
    return SymbolRefAttr::get(context, "printf");
  }

  /// Return a value representing an access into a global string with the given
  /// name, creating the string if necessary.
  static Value createGlobalString(Location loc, OpBuilder &builder,
                                  StringRef name, StringRef value,
                                  ModuleOp module) {
    // Check if the very last character is the null terminator
    std::string updatedValue = value.str();
    if (updatedValue.empty() || updatedValue.back() != '\0') {
      updatedValue.push_back('\0');
    }
    StringRef valueWithNull(updatedValue);

    // TODO: This while loop is a bit of a hack to get a unique name, worth
    // fixing later, just in a hurry right now
    std::string uniqueName;
    do {
      uniqueName = name.str() + "_" + std::to_string(global_string_counter++);
    } while (module.lookupSymbol<LLVM::GlobalOp>(uniqueName));

    // Create the global at the entry of the module.
    LLVM::GlobalOp global;
    if (!(global = module.lookupSymbol<LLVM::GlobalOp>(uniqueName))) {
      OpBuilder::InsertionGuard insertGuard(builder);
      builder.setInsertionPointToStart(module.getBody());
      auto type = LLVM::LLVMArrayType::get(
          IntegerType::get(builder.getContext(), 8), updatedValue.size());
      global = builder.create<LLVM::GlobalOp>(
          loc, type, /*isConstant=*/true, LLVM::Linkage::Internal, uniqueName,
          builder.getStringAttr(updatedValue),
          /*alignment=*/0);
    }

    // Get the pointer to the first character in the global string.
    Value globalPtr = builder.create<LLVM::AddressOfOp>(loc, global);
    Value cst0 = builder.create<LLVM::ConstantOp>(loc, builder.getI64Type(),
                                                  builder.getIndexAttr(0));
    return builder.create<LLVM::GEPOp>(
        loc, LLVM::LLVMPointerType::get(builder.getContext()), global.getType(),
        globalPtr, ArrayRef<Value>({cst0, cst0}));
  }
};

/// LowerFifoPrintToLLVMPass - This pass lowers the `fifo.print` operation to an
/// equivalent `printf` operation in the LLVM dialect. The `fifo.print`
/// operation, which prints formatted output with variadic arguments, is
/// converted into calls to the `printf` function in LLVM IR. This conversion
/// ensures compatibility with LLVM-based backends while properly handling the
/// variadic arguments.
class LowerFifoPrintToLLVMPass
    : public impl::LowerFifoPrintToLLVMBase<LowerFifoPrintToLLVMPass> {
public:
  LowerFifoPrintToLLVMPass(const LowerFifoPrintToLLVMOptions &options)
      : impl::LowerFifoPrintToLLVMBase<LowerFifoPrintToLLVMPass>(options) {}

  LowerFifoPrintToLLVMPass() {}

  void runOnOperation() final {
    ConversionTarget target(getContext());

    RewritePatternSet patterns(&getContext());
    patterns.add<ConvertPrintToLLVMPrint>(&getContext());
    patterns.add<ConvertTensorPrintToPrint>(&getContext(), tensors_on_gpu);

    // Set the legal and illegal dialects after this conversion
    target.addIllegalOp<fifo::PrintOp, fifo::PrintTensorOp>();
    target.addLegalDialect<LLVM::LLVMDialect,
                           mlir::bufferization::BufferizationDialect,
                           mlir::scf::SCFDialect, mlir::memref::MemRefDialect,
                           mlir::arith::ArithDialect, mlir::gpu::GPUDialect>();

    // Run the conversion
    if (failed(applyPartialConversion(getOperation(), target,
                                      std::move(patterns)))) {
      signalPassFailure();
    }
  }
};

} // namespace mlir::fifo
