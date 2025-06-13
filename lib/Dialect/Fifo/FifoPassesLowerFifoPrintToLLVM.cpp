//===- FifoPasses.cpp - Fifo passes -----------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// @author Gareth Callanan
// Disclaimer - I have wrote the code myself but used ChatGPT to generate
// top level comments describing each class with the hope that it will make
// the code easier to understand.

#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoPasses.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Rewrite/FrozenRewritePatternSet.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include <iostream>

namespace mlir::fifo {
#define GEN_PASS_DEF_LOWERFIFOPRINTTOLLVM
#include "Dialect/Fifo/FifoPasses.h.inc"

// This class defines a conversion pattern that lowers the `fifo.print`
// operation to a `printf` call in the LLVM dialect. The conversion involves
// several steps:
//
// 1. **Format String Handling**: It retrieves the format string from the
//    `fifo.print` operation and creates a global constant string in the module.
//    This string is used as the format specifier for the `printf` call.
//
// 2. **Variadic Argument Handling**: It combines the format string with the
//    variadic arguments passed to the `fifo.print` operation into a single
//    operand list, which will be passed to the `printf` function.
//
// 3. **Function Insertion**: The conversion checks whether the `printf`
//    function is already declared in the module. If not, it inserts a
//    declaration for `printf` with the correct function signature
//    (`i32 (i8*, ...)`).
//
// 4. **Global String Handling**: A helper function ensures the creation of a
//    unique, global string representing the format specifier. This string is
//    necessary to ensure that the format is available at runtime for the
//    `printf` call.
//
// 5. **Final Call**: It creates a `LLVM::CallOp` to call `printf` with the
//    combined operands (the format specifier and the variadic arguments) and
//    then erases the original `fifo.print` operation from the IR.
//
// This class borrows heavily from the `PrintOpLowering` class from the
// toy-ch6 example found in llvm-project/mlir/examples/toy/LowerToLLVM.cpp. I
// just extended it to take a format string and variable number of parameters
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

    // Create a vecotr of operands to the printf, including the format string
    // All f32 need to be converted to f64 or else printf does not generate nice data
    llvm::SmallVector<mlir::Value, 8> combinedOperands;
    combinedOperands.push_back(formatSpecifierCst);
    for (auto arg : args) {
      if (mlir::isa<FloatType>(arg.getType()) &&
          mlir::cast<FloatType>(arg.getType()).getWidth() == 32) {
        auto f64Ty = rewriter.getF64Type();
        arg = rewriter.create<LLVM::FPExtOp>(loc, f64Ty, arg);
      }
      combinedOperands.push_back(arg);
    }

    rewriter.create<LLVM::CallOp>(loc, getPrintfType(getContext()), printfRef,
                                  combinedOperands);

    rewriter.eraseOp(op);

    return success();
  }

private:
  static inline int global_string_counter;
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
    // TODO: This while loops is a bit of a hack to get a unique name, worth
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
          IntegerType::get(builder.getContext(), 8), value.size());
      global = builder.create<LLVM::GlobalOp>(
          loc, type, /*isConstant=*/true, LLVM::Linkage::Internal, uniqueName,
          builder.getStringAttr(value),
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

//int ConvertPrintToLLVMPrint::global_string_counter = 0;

// This pass lowers the `fifo.print` operation to an equivalent `printf`
// operation in the LLVM dialect. The `fifo.print` operation, which prints
// formatted output with variadic arguments, is converted into calls to the
// `printf` function in LLVM IR. This conversion ensures compatibility with
// LLVM-based backends while properly handling the variadic arguments,
class LowerFifoPrintToLLVMPass
    : public impl::LowerFifoPrintToLLVMBase<LowerFifoPrintToLLVMPass> {
public:
  void runOnOperation() final {
    ConversionTarget target(getContext());

    // Something about this being a stack
    RewritePatternSet patterns(&getContext());
    patterns.add<ConvertPrintToLLVMPrint>(&getContext());

    // Set the legal and illegal dialects after this conversion
    target.addIllegalOp<fifo::PrintOp>();
    target.addLegalDialect<LLVM::LLVMDialect>();

    // Run the conversion
    if (failed(applyPartialConversion(getOperation(), target,
                                      std::move(patterns)))) {
      signalPassFailure();
    }
  }
};

} // namespace mlir::fifo

// Creates and returns a new instance of the `LowerFifoPrintToLLVMPass`.
// This function serves as the entry point for applying the pass that converts
// `fifo.print` operations into equivalent `printf` calls in the LLVM dialect
std::unique_ptr<mlir::Pass> mlir::fifo::lowerFifoPrintToLLVM() {
  return std::make_unique<mlir::fifo::LowerFifoPrintToLLVMPass>();
}
