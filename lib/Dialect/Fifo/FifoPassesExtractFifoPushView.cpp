//===- FifoPassesExtractFifoPushView.cpp --- Extract FIFO push view -*- C++ -*-===//
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
#define GEN_PASS_DEF_EXTRACTFIFOPUSHVIEWPASS
#include "Dialect/Fifo/FifoPasses.h.inc"

namespace {

// Returns true if `v` is an arith.constant of index type equal to `expected`.
static bool isConstantIndexEqualTo(Value v, int64_t expected) {
  auto cst = v.getDefiningOp<arith::ConstantIndexOp>();
  return cst && cst.value() == expected;
}

// Returns true if `v` is a constant equal to `expected`, either directly as
// an arith.constant of index type, or as an integer constant fed through a
// single arith.index_cast -- the shape produced by frontends that compute
// sizes in a fixed-width integer type and cast them to index for loop bounds.
static bool matchesConstantBound(Value v, int64_t expected) {
  if (auto cst = v.getDefiningOp<arith::ConstantIndexOp>())
    return cst.value() == expected;

  if (auto cast = v.getDefiningOp<arith::IndexCastOp>()) {
    if (auto cst = cast.getIn().getDefiningOp<arith::ConstantOp>()) {
      if (auto intAttr = mlir::dyn_cast<IntegerAttr>(cst.getValue()))
        return intAttr.getValue().getSExtValue() == expected;
    }
  }
  return false;
}

// Returns true if no operation appearing strictly after `afterOp` in its
// parent block -- including operations nested in regions of those later ops
// -- uses `value`.
static bool hasNoUsesAfter(Value value, Operation *afterOp) {
  Block *block = afterOp->getBlock();
  bool seenAfterOp = false;
  bool usedAfter = false;
  for (auto &op : *block) {
    if (&op == afterOp) {
      seenAfterOp = true;
      continue;
    }
    if (!seenAfterOp)
      continue;
    op.walk([&](Operation *nested) {
      for (Value operand : nested->getOperands())
        if (operand == value)
          usedAfter = true;
    });
  }
  return !usedAfter;
}

struct ExtractFifoPushViewPass
    : public impl::ExtractFifoPushViewPassBase<ExtractFifoPushViewPass> {

  // Returns the scf.for that drains alloca via a single fifo.push loop and
  // the push op itself. Returns nullptrs if the pattern does not match.
  static std::pair<scf::ForOp, Push>
  findPushDrainLoop(memref::AllocaOp alloca, Block *actionBlock) {
    auto allocaType = mlir::cast<MemRefType>(alloca.getType());
    if (allocaType.getRank() != 1 || allocaType.isDynamicDim(0))
      return {};
    int64_t N = allocaType.getDimSize(0);
    Type elemType = allocaType.getElementType();

    for (auto &op : *actionBlock) {
      auto forOp = dyn_cast<scf::ForOp>(&op);
      if (!forOp)
        continue;

      // The drain loop must come after the alloca: it is the alloca's
      // contents that get pushed, not the other way round.
      if (!alloca->isBeforeInBlock(forOp))
        continue;

      if (!isConstantIndexEqualTo(forOp.getLowerBound(), 0) ||
          !isConstantIndexEqualTo(forOp.getStep(), 1) ||
          !matchesConstantBound(forOp.getUpperBound(), N))
        continue;

      // The loop body must be exactly: load alloca[iv]; push(port, val);
      // yield -- nothing else, so we know precisely what flows into the FIFO.
      Block *loopBody = &forOp.getRegion().front();
      Value iv = forOp.getInductionVar();

      memref::LoadOp foundLoad;
      Push foundPush;
      bool unexpectedOp = false;

      for (auto &bodyOp : *loopBody) {
        if (isa<scf::YieldOp>(&bodyOp))
          continue;
        if (auto load = dyn_cast<memref::LoadOp>(&bodyOp)) {
          if (load.getMemref() == alloca.getResult() &&
              load.getIndices().size() == 1 && load.getIndices()[0] == iv) {
            foundLoad = load;
            continue;
          }
        } else if (auto push = dyn_cast<Push>(&bodyOp)) {
          if (foundLoad && push.getInputToken() == foundLoad.getResult() &&
              push.getInputToken().getType() == elemType) {
            foundPush = push;
            continue;
          }
        }
        unexpectedOp = true;
        break;
      }

      if (unexpectedOp || !foundLoad || !foundPush)
        continue;

      // The drain loop must be the alloca's last use: every byte that ever
      // gets written into it must be in place before we hand the buffer to
      // the FIFO and advance the write counter.
      if (!hasNoUsesAfter(alloca.getResult(), forOp))
        continue;

      // No other fifo.push targeting the same port may appear anywhere in
      // the action: it would consume slots and bump the write counter out
      // from under the base offset we are about to capture.
      Value port = foundPush.getInputPort();
      bool otherPushOnPort = false;
      actionBlock->getParentOp()->walk([&](Push other) {
        if (other != foundPush && other.getInputPort() == port)
          otherPushOnPort = true;
      });
      if (otherPushOnPort)
        continue;

      return {forOp, foundPush};
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
        auto [drainLoop, pushOp] = findPushDrainLoop(alloca, body);
        if (!drainLoop)
          continue;

        auto allocaType = mlir::cast<MemRefType>(alloca.getType());
        int64_t N = allocaType.getDimSize(0);
        Type elemType = allocaType.getElementType();

        Value port = pushOp.getInputPort();

        // Result type: memref<N x T, strided<[1], offset: ?>>, the natural
        // type of a 1-D subview with a dynamic offset (the runtime
        // write-pointer) and static size N and stride 1.
        auto stridedLayout = StridedLayoutAttr::get(
            &getContext(), ShapedType::kDynamic, {1});
        auto viewType = MemRefType::get({N}, elemType, stridedLayout);

        // Reserve the view where the alloca used to be: this is the
        // earliest point any of the alloca's uses occur, and the view must
        // exist (backed by real FIFO storage) before any of them run.
        OpBuilder reserveBuilder(alloca);
        Value reserveCount = reserveBuilder.create<arith::ConstantIndexOp>(
            alloca.getLoc(), N);
        auto viewOp = reserveBuilder.create<PushBulkView>(
            alloca.getLoc(), viewType, port, reserveCount);
        alloca.getResult().replaceAllUsesWith(viewOp.getView());

        // Publish where the drain loop used to be: only once every slot has
        // actually been written do we advance the write counter, so a
        // concurrently running consumer can never observe a half-filled
        // region.
        OpBuilder commitBuilder(drainLoop);
        Value commitCount = commitBuilder.create<arith::ConstantIndexOp>(
            drainLoop.getLoc(), N);
        commitBuilder.create<PushBulkCommit>(drainLoop.getLoc(), port,
                                             commitCount);

        // The drain loop is now dead; erase it before the alloca.
        drainLoop.erase();
        alloca.erase();
      }
    });
  }
};

} // namespace
} // namespace mlir::fifo
