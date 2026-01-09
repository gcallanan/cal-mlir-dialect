//===- BufferizableOpInterfaceImpl.cpp - Impl. of BufferizableOpInterface -===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Dialect/Fifo/BufferizableOpInterfaceImpl.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "mlir/Dialect/Bufferization/IR/BufferizableOpInterface.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Bufferization/IR/UnstructuredControlFlow.h"
#include "mlir/Dialect/Bufferization/Transforms/Bufferize.h"
#include "mlir/Dialect/Bufferization/Transforms/OneShotAnalysis.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/Dialect/Utils/StaticValueUtils.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/Operation.h"
#include "mlir/IR/PatternMatch.h"

namespace mlir {
namespace fifo {
namespace {
/// BufferizableOpInterface implementation for PrintTensorOp.
struct PrintTensorOpInterface
    : public mlir::bufferization::BufferizableOpInterface::ExternalModel<
          PrintTensorOpInterface, PrintTensorOp> {

  bool bufferizesToMemoryRead(
      Operation *op, OpOperand &opOperand,
      const mlir::bufferization::AnalysisState &state) const {
    return false;
  }

  bool bufferizesToMemoryWrite(
      Operation *op, OpOperand &opOperand,
      const mlir::bufferization::AnalysisState &state) const {
    return false;
  }

  mlir::bufferization::AliasingValueList
  getAliasingValues(Operation *op, OpOperand &opOperand,
                    const mlir::bufferization::AnalysisState &state) const {
    return {};
  }

  bool hasTensorSemantics(Operation *op) const {
    // Consider this operation to have tensor semantics if the input argument is
    // a tensor type.
    auto fifoPrintTensorOp = cast<fifo::PrintTensorOp>(op);
    return mlir::isa<mlir::TensorType>(fifoPrintTensorOp.getTensor().getType());
  }

  LogicalResult
  bufferize(Operation *op, RewriterBase &rewriter,
            const mlir::bufferization::BufferizationOptions &options) const {
    auto fifoPrintTensorOp = cast<fifo::PrintTensorOp>(op);
    auto tensorArgType = fifoPrintTensorOp.getTensor().getType();

    // If not a tensor type, nothing to do. But it should be a
    // tensor type if its got this far
    if (!mlir::isa<mlir::TensorType>(tensorArgType))
      return success();

    // Bufferize the tensor value to a memref.
    Value tensorValue = fifoPrintTensorOp.getTensor();
    FailureOr<Value> bufferizedValue =
        bufferization::getBuffer(rewriter, tensorValue, options);
    if (failed(bufferizedValue))
      return failure();
    auto newValue = *bufferizedValue;

    auto newOp = rewriter.create<fifo::PrintTensorOp>(op->getLoc(), newValue);

    rewriter.replaceOp(op, newOp);
    return success();
  }
};

} // namespace
} // namespace fifo
} // namespace mlir

void mlir::fifo::registerBufferizableOpInterfaceExternalModels(
    DialectRegistry &registry) {

  registry.addExtension(
      +[](MLIRContext *ctx, mlir::fifo::FifoDialect *dialect) {
        PrintTensorOp::attachInterface<PrintTensorOpInterface>(*ctx);
      });
}
