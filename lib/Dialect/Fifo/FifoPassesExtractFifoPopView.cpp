//===- FifoPassesExtractFifoPopView.cpp ---- Extract FIFO pop view -*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// @author Gareth Callanan

#include "Dialect/Cal/CalOps.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoPasses.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/Pass/Pass.h"

namespace mlir::fifo {
#define GEN_PASS_DEF_EXTRACTFIFOPOPVIEWPASS
#include "Dialect/Fifo/FifoPasses.h.inc"

namespace {

struct ExtractFifoPopViewPass
    : public impl::ExtractFifoPopViewPassBase<ExtractFifoPopViewPass> {

  // Returns the scf.for that fills alloca from a single fifo.pop loop and the
  // pop op itself. Returns nullptrs if the pattern does not match.
  static std::pair<scf::ForOp, Pop>
  findPopFillLoop(memref::AllocaOp alloca, Block *actionBlock) {
    auto allocaType = mlir::cast<MemRefType>(alloca.getType());
    if (allocaType.getRank() != 1 || allocaType.isDynamicDim(0))
      return {};
    int64_t N = allocaType.getDimSize(0);
    Type elemType = allocaType.getElementType();

    for (auto &op : *actionBlock) {
      auto forOp = dyn_cast<scf::ForOp>(&op);
      if (!forOp)
        continue;

      // All three bounds must be arith.constant index ops.
      auto lbConst =
          forOp.getLowerBound().getDefiningOp<arith::ConstantIndexOp>();
      auto ubConst =
          forOp.getUpperBound().getDefiningOp<arith::ConstantIndexOp>();
      auto stepConst =
          forOp.getStep().getDefiningOp<arith::ConstantIndexOp>();
      if (!lbConst || !ubConst || !stepConst)
        continue;
      if (lbConst.value() != 0 || stepConst.value() != 1)
        continue;
      if (ubConst.value() != N)
        continue;

      // The loop body must contain exactly one fifo.pop whose result is stored
      // into %alloca[%iv] and whose element type matches the alloca's element
      // type.
      Block *loopBody = &forOp.getRegion().front();
      Value iv = forOp.getInductionVar();

      Pop foundPop;
      bool storeFound = false;

      for (auto &bodyOp : *loopBody) {
        if (isa<scf::YieldOp>(&bodyOp))
          continue;
        if (auto pop = dyn_cast<Pop>(&bodyOp)) {
          if (pop.getOutputToken().getType() != elemType)
            continue;
          foundPop = pop;
        } else if (auto store = dyn_cast<memref::StoreOp>(&bodyOp)) {
          if (store.getMemref() == alloca.getResult() &&
              store.getIndices().size() == 1 &&
              store.getIndices()[0] == iv && foundPop &&
              store.getValue() == foundPop.getOutputToken()) {
            storeFound = true;
          }
        }
      }

      if (!foundPop || !storeFound)
        continue;

      // No other fifo.pop targeting the same port may appear anywhere in the
      // action: with the counter advance deferred to the end of the action,
      // such a pop would race with ours -- either it advances the read
      // counter out from under the base offset we are about to capture, or it
      // captures a base offset that overlaps the region we are about to
      // reserve.
      Value port = foundPop.getOutputPort();
      bool otherPopOnPort = false;
      actionBlock->getParentOp()->walk([&](Pop other) {
        if (other != foundPop && other.getOutputPort() == port)
          otherPopOnPort = true;
      });
      if (otherPopOnPort)
        continue;

      return {forOp, foundPop};
    }
    return {};
  }

  void runOnOperation() override {
    ModuleOp module = getOperation();

    module.walk([&](cal::ActionOp action) {
      Block *body = &action.getBody().front();

      // Collect allocas upfront since we modify the block during the loop.
      SmallVector<memref::AllocaOp> allocas;
      for (auto &op : *body)
        if (auto alloca = dyn_cast<memref::AllocaOp>(&op))
          allocas.push_back(alloca);

      for (auto alloca : allocas) {
        auto [fillLoop, popOp] = findPopFillLoop(alloca, body);
        if (!fillLoop)
          continue;

        auto allocaType = mlir::cast<MemRefType>(alloca.getType());
        int64_t N = allocaType.getDimSize(0);
        Type elemType = allocaType.getElementType();

        Value port = popOp.getOutputPort();

        // Result type: memref<N x T, strided<[1], offset: ?>>
        // This is the natural result type of a 1-D subview with a dynamic
        // offset (the runtime read-pointer) and static size N and stride 1.
        auto stridedLayout = StridedLayoutAttr::get(
            &getContext(), ShapedType::kDynamic, {1});
        auto viewType = MemRefType::get({N}, elemType, stridedLayout);

        // Acquire the view where the fill loop used to be: this is the
        // earliest point any of the alloca's uses occur, and the view must
        // exist (backed by real FIFO storage) before any of them run. This op
        // deliberately does not touch the read counter.
        OpBuilder acquireBuilder(fillLoop);
        Value acquireCount = acquireBuilder.create<arith::ConstantIndexOp>(
            fillLoop.getLoc(), N);
        auto viewOp = acquireBuilder.create<PopBulkView>(
            fillLoop.getLoc(), viewType, port, acquireCount);

        // Replace all uses of the alloca (loads, stores from other loops) with
        // the view. memref.load and memref.store accept any MemRefType layout.
        alloca.getResult().replaceAllUsesWith(viewOp.getView());

        // Release at the end of the action body: cal.action has no
        // terminator, so the last position in the block is guaranteed to run
        // after every other op in the block -- including any later loops that
        // read (or write back through) the view. Only once every element has
        // been read is it safe to advance the read counter and let a
        // concurrently running producer reuse these slots.
        OpBuilder releaseBuilder(body, body->end());
        Value releaseCount = releaseBuilder.create<arith::ConstantIndexOp>(
            fillLoop.getLoc(), N);
        releaseBuilder.create<PopBulkRelease>(fillLoop.getLoc(), port,
                                              releaseCount);

        // The fill loop is now dead; erase it before the alloca.
        fillLoop.erase();
        alloca.erase();
      }
    });
  }
};

} // namespace
} // namespace mlir::fifo
