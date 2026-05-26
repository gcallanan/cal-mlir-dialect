//===- CalPassesInferCalDynamicStateShapes.cpp ----------------*- C++ -*-===//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//===----------------------------------------------------------------------===//

#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalPasses.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

namespace mlir::cal {
#define GEN_PASS_DEF_INFERCALDYNAMICSTATESHAPES
#include "Dialect/Cal/CalPasses.h.inc"

namespace {

/// Try to peel trivial casts to reach a constant integer/index value.
static std::optional<int64_t> getConstantExtent(Value v) {
  Operation *def = v.getDefiningOp();
  if (!def)
    return std::nullopt;
  // Direct constant (index or integer).
  if (auto c = dyn_cast<arith::ConstantOp>(def)) {
    if (auto attr = dyn_cast<IntegerAttr>(c.getValue()))
      return attr.getInt();
  }
  // index_cast chain.
  if (auto ic = dyn_cast<arith::IndexCastOp>(def))
    return getConstantExtent(ic.getIn());
  // fptosi/sitofp not expected for size in current patterns; ignore.
  return std::nullopt;
}

/// Pattern: specialize memref<?xT> state var + alloc(%c) to memref<NxT>.
class SpecializeRank1DynamicState final : public OpRewritePattern<cal::CreateStateVarOp> {
public:
  using OpRewritePattern::OpRewritePattern;
  LogicalResult matchAndRewrite(cal::CreateStateVarOp op, PatternRewriter &rewriter) const override {
    Type t = op.getStateType();
    auto memrefTy = dyn_cast<MemRefType>(t);
    if (!memrefTy)
      return failure();
    if (memrefTy.getRank() != 1)
      return failure();
    if (!memrefTy.isDynamicDim(0))
      return failure(); // already static

    // Find unique cal.set using this state ref and sourcing an alloc.
    cal::StateSetOp setOp = nullptr;
    for (Operation *user : op->getUsers()) {
      auto possibleSet = dyn_cast<cal::StateSetOp>(user);
      if (!possibleSet)
        continue;
      if (setOp)
        return failure(); // more than one initializer
      setOp = possibleSet;
    }
    if (!setOp)
      return failure();

    Operation *defValOp = setOp.getStateValue().getDefiningOp();
    if (!defValOp)
      return failure();
    auto allocOp = dyn_cast<memref::AllocOp>(defValOp);
    if (!allocOp)
      return failure();
    // Expect exactly one dynamic operand for rank-1.
    if (allocOp.getDynamicSizes().size() != 1)
      return failure();
    Value dynSize = allocOp.getDynamicSizes()[0];
    auto maybeExtent = getConstantExtent(dynSize);
    if (!maybeExtent.has_value())
      return failure();
    int64_t extent = maybeExtent.value();
    if (extent <= 0)
      return failure();

    // Build new static memref type.
    auto newMemRefTy = MemRefType::get({extent}, memrefTy.getElementType(), memrefTy.getLayout(), memrefTy.getMemorySpace());

    // Replace alloc with static alloc (no dynamic operand).
    rewriter.setInsertionPoint(allocOp);
    auto newAlloc = rewriter.create<memref::AllocOp>(allocOp.getLoc(), newMemRefTy);
    rewriter.replaceOp(allocOp, newAlloc.getResult());

    // Replace create_state_var with new type.
    rewriter.setInsertionPoint(op);
    auto newState = rewriter.create<cal::CreateStateVarOp>(op.getLoc(), newMemRefTy, ValueRange{}, TypeAttr::get(newMemRefTy));
    op.getStateVarRef().replaceAllUsesWith(newState.getStateVarRef());
    rewriter.eraseOp(op);

    // Update the cal.set to use new alloc result (type already matches).
    // Its operands remain valid; no action needed besides ensuring type compatibility.
    return success();
  }
};

class InferCalDynamicStateShapesPass : public impl::InferCalDynamicStateShapesBase<InferCalDynamicStateShapesPass> {
public:
  void runOnOperation() final {
    RewritePatternSet patterns(&getContext());
    patterns.add<SpecializeRank1DynamicState>(&getContext());
    if (failed(applyPatternsGreedily(getOperation(), std::move(patterns)))) {
      signalPassFailure();
    }
  }
};

} // namespace

std::unique_ptr<mlir::Pass> inferCalDynamicStateShapes() {
  return std::make_unique<InferCalDynamicStateShapesPass>();
}

} // namespace mlir::cal
