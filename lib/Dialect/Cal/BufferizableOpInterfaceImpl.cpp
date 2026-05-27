//===- BufferizableOpInterfaceImpl.cpp - Impl. of BufferizableOpInterface -===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Dialect/Cal/BufferizableOpInterfaceImpl.h"
#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalTypes.h"
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
namespace cal {
namespace {

/// BufferizableOpInterface implementation for CreateStateVarOp.
struct CreateStateVarOpInterface
    : public mlir::bufferization::BufferizableOpInterface::ExternalModel<
          CreateStateVarOpInterface, CreateStateVarOp> {

  bool bufferizesToAllocation(Operation *op, Value value) const { return true; }

  bool bufferizesToMemoryRead(
      Operation *op, OpOperand &opOperand,
      const mlir::bufferization::AnalysisState &state) const {
    // CreateStateVar operations don't have operands
    return false;
  }

  bool bufferizesToMemoryWrite(
      Operation *op, OpOperand &opOperand,
      const mlir::bufferization::AnalysisState &state) const {
    // CreateStateVar operations don't have operands
    return false;
  }

  bool hasTensorSemantics(Operation *op) const {
    // Consider this operation to have tensor semantics if the state type is a
    // tensor type.
    auto createStateVarOp = cast<cal::CreateStateVarOp>(op);
    return mlir::isa<mlir::TensorType>(createStateVarOp.getStateType());
  }

  LogicalResult
  bufferize(Operation *op, RewriterBase &rewriter,
            const mlir::bufferization::BufferizationOptions &options) const {
    auto createStateVarOp = cast<cal::CreateStateVarOp>(op);
    Type stateType = createStateVarOp.getStateType();

    // If not a tensor type, nothing to do. But it should be a tensor type
    // if it's got this far
    if (!mlir::isa<mlir::TensorType>(stateType))
      return success();

    auto tensorType = mlir::cast<mlir::TensorType>(stateType);
    auto memrefType =
        bufferization::getMemRefTypeWithStaticIdentityLayout(tensorType);

    auto newOp = rewriter.create<cal::CreateStateVarOp>(
      op->getLoc(), cal::StateVarRefType::get(op->getContext(), memrefType),
      ValueRange{}, TypeAttr::get(memrefType));

    rewriter.replaceOp(op, newOp.getResult());
    return success();
  }
};

/// BufferizableOpInterface implementation for StateGetOp.
struct StateGetOpInterface
    : public mlir::bufferization::BufferizableOpInterface::ExternalModel<
          StateGetOpInterface, StateGetOp> {

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

  bool hasTensorSemantics(Operation *op) const {
    // Consider this operation to have tensor semantics if the state type is a
    // tensor type.
    auto stateGetOp = cast<cal::StateGetOp>(op);
    return mlir::isa<mlir::TensorType>(stateGetOp.getStateValue().getType());
  }

  LogicalResult
  bufferize(Operation *op, RewriterBase &rewriter,
            const mlir::bufferization::BufferizationOptions &options) const {
    auto stateGetOp = cast<cal::StateGetOp>(op);
    auto stateType = stateGetOp.getStateValue().getType();

    // If not a tensor type, nothing to do. But it should be a
    // tensor type if its got this far
    if (!mlir::isa<mlir::TensorType>(stateType))
      return success();

    auto tensorType = mlir::cast<mlir::TensorType>(stateType);
    auto memrefType =
        bufferization::getMemRefTypeWithStaticIdentityLayout(tensorType);

    auto newStateRef = stateGetOp.getStateRef();
    auto newOp =
        rewriter.create<cal::StateGetOp>(op->getLoc(), memrefType, newStateRef);

    bufferization::replaceOpWithBufferizedValues(rewriter, op,
                                                 newOp.getResult());
    // rewriter.replaceOp(op, newOp.getResult());
    return success();
  }
};

/// BufferizableOpInterface implementation for StateSetOp.
struct StateSetOpInterface
    : public mlir::bufferization::BufferizableOpInterface::ExternalModel<
          StateSetOpInterface, StateSetOp> {

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

  SmallVector<OpResult>
  getAliasingOpResults(Operation *op, OpOperand &opOperand,
                       const mlir::bufferization::AnalysisState &state) const {
    return {};
  }

  mlir::bufferization::AliasingValueList
  getAliasingValues(Operation *op, OpOperand &opOperand,
                    const mlir::bufferization::AnalysisState &state) const {
    if (opOperand.getOperandNumber() == 0)
      return {
          {opOperand.get(), mlir::bufferization::BufferRelation::Equivalent}};
    return {};
  }

  bool hasTensorSemantics(Operation *op) const {
    // Consider this operation to have tensor semantics if the state type is a
    // tensor type.
    auto stateSetOp = cast<cal::StateSetOp>(op);
    return mlir::isa<mlir::TensorType>(stateSetOp.getStateValue().getType());
  }

  LogicalResult
  bufferize(Operation *op, RewriterBase &rewriter,
            const mlir::bufferization::BufferizationOptions &options) const {
    auto stateSetOp = cast<cal::StateSetOp>(op);
    auto stateType = stateSetOp.getStateValue().getType();

    // If not a tensor type, nothing to do. But it should be a
    // tensor type if its got this far
    if (!mlir::isa<mlir::TensorType>(stateType))
      return success();

    auto newStateRef = stateSetOp.getStateRef();

    // Bufferize the tensor value to a memref.
    Value tensorValue = stateSetOp.getStateValue();
    FailureOr<Value> bufferizedValue =
        bufferization::getBuffer(rewriter, tensorValue, options);
    if (failed(bufferizedValue))
      return failure();
    auto newValue = *bufferizedValue;

    auto newOp =
        rewriter.create<cal::StateSetOp>(op->getLoc(), newValue, newStateRef);

    rewriter.replaceOp(op, newOp);
    return success();
  }
};

} // namespace
} // namespace cal
} // namespace mlir

void mlir::cal::registerBufferizableOpInterfaceExternalModels(
    DialectRegistry &registry) {

  // Emit an error to indicate this pass is out of date.
  llvm::report_fatal_error(
      "mlir::cal::registerBufferizableOpInterfaceExternalModels is out of date "
      "with the current MLIR bufferization infrastructure. Please update this "
      "pass.");

  registry.addExtension(+[](MLIRContext *ctx, mlir::cal::CalDialect *dialect) {
    CreateStateVarOp::attachInterface<CreateStateVarOpInterface>(*ctx);
    StateGetOp::attachInterface<StateGetOpInterface>(*ctx);
    StateSetOp::attachInterface<StateSetOpInterface>(*ctx);
  });
}
