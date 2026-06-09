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

  // Finds a top-level loop of the canonical drain shape -- lb=0, step=1,
  // body exactly {load X[iv]; push(port, loadedVal); yield} -- and returns
  // it together with the matched push and the source buffer X (nulls if no
  // such loop exists).
  //
  // X is discovered from the load itself rather than assumed up front, so it
  // may be *any* rank-1, statically-shaped memref of matching size and
  // element type: a local memref.alloca (the common case, eligible for the
  // zero-copy redirect-and-erase rewrite below), a heap memref.alloc, the
  // result of a fifo.pop_bulk_view on a *different* port -- the "relay" shape
  // where an actor pops a bulk region and immediately drains it into another
  // FIFO -- a function argument, etc. The two rewrite strategies in
  // runOnOperation adapt to whichever it turns out to be.
  static std::tuple<scf::ForOp, Push, Value>
  findPushDrainLoop(Block *actionBlock) {
    for (auto &op : *actionBlock) {
      auto forOp = dyn_cast<scf::ForOp>(&op);
      if (!forOp)
        continue;

      if (!isConstantIndexEqualTo(forOp.getLowerBound(), 0) ||
          !isConstantIndexEqualTo(forOp.getStep(), 1))
        continue;

      // The loop body must be exactly: load X[iv]; push(port, val); yield --
      // nothing else, so we know precisely what flows into the FIFO.
      Block *loopBody = &forOp.getRegion().front();
      Value iv = forOp.getInductionVar();

      memref::LoadOp foundLoad;
      Push foundPush;
      bool unexpectedOp = false;

      for (auto &bodyOp : *loopBody) {
        if (isa<scf::YieldOp>(&bodyOp))
          continue;
        if (auto load = dyn_cast<memref::LoadOp>(&bodyOp)) {
          if (!foundLoad && load.getIndices().size() == 1 &&
              load.getIndices()[0] == iv) {
            foundLoad = load;
            continue;
          }
        } else if (auto push = dyn_cast<Push>(&bodyOp)) {
          if (foundLoad && push.getInputToken() == foundLoad.getResult()) {
            foundPush = push;
            continue;
          }
        }
        unexpectedOp = true;
        break;
      }

      if (unexpectedOp || !foundLoad || !foundPush)
        continue;

      Value buffer = foundLoad.getMemref();
      auto bufferType = mlir::dyn_cast<MemRefType>(buffer.getType());
      if (!bufferType || bufferType.getRank() != 1 ||
          bufferType.isDynamicDim(0))
        continue;
      int64_t N = bufferType.getDimSize(0);
      if (!matchesConstantBound(forOp.getUpperBound(), N))
        continue;

      // The buffer must already be available by the time the loop runs: if
      // it has a defining op, that op must live in this same block, before
      // the loop -- this is what "the contents that get pushed, not the
      // other way round" comes down to once the buffer isn't necessarily an
      // alloca local to this block (e.g. a block argument trivially
      // qualifies; an op nested in some other region does not).
      if (Operation *def = buffer.getDefiningOp())
        if (def->getBlock() != actionBlock || !def->isBeforeInBlock(forOp))
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

      return {forOp, foundPush, buffer};
    }
    return {};
  }

  void runOnOperation() override {
    ModuleOp module = getOperation();

    module.walk([&](cal::ActionOp action) {
      Block *body = &action.getBody().front();

      // Search to a fixed point: every successful match below either erases
      // the drain loop outright (redirect-and-erase) or erases the
      // fifo.push inside it (generic rewrite), so a loop can never match
      // twice -- the search is guaranteed to terminate, and re-running it
      // from scratch sidesteps any iterator invalidation from the rewrite.
      while (true) {
        auto [drainLoop, pushOp, buffer] = findPushDrainLoop(body);
        if (!drainLoop)
          break;

        auto bufferType = mlir::cast<MemRefType>(buffer.getType());
        int64_t N = bufferType.getDimSize(0);
        Type elemType = bufferType.getElementType();
        Value port = pushOp.getInputPort();
        Value iv = drainLoop.getInductionVar();

        // Result type: memref<N x T, strided<[1], offset: ?>>, the natural
        // type of a 1-D subview with a dynamic offset (the runtime
        // write-pointer) and static size N and stride 1.
        auto stridedLayout = StridedLayoutAttr::get(
            &getContext(), ShapedType::kDynamic, {1});
        auto viewType = MemRefType::get({N}, elemType, stridedLayout);

        auto alloca = buffer.getDefiningOp<memref::AllocaOp>();
        if (alloca && hasNoUsesAfter(buffer, drainLoop)) {
          // Zero-copy: the buffer is a local scratch alloca about to be
          // drained for the last time. Reserve the view where the alloca
          // used to be -- the earliest point any of its uses occur -- and
          // redirect every one of those uses (loads, stores from other
          // loops feeding it) onto the reserved FIFO region directly, so
          // whatever filled the buffer now writes straight into the FIFO.
          // That makes the drain loop redundant (its loads now read back
          // the FIFO's own data, and its pushes would double-publish it),
          // and the alloca dead; erase both.
          OpBuilder reserveBuilder(alloca);
          Value reserveCount = reserveBuilder.create<arith::ConstantIndexOp>(
              alloca.getLoc(), N);
          auto viewOp = reserveBuilder.create<PushBulkView>(
              alloca.getLoc(), viewType, port, reserveCount);
          buffer.replaceAllUsesWith(viewOp.getView());

          OpBuilder commitBuilder(drainLoop);
          Value commitCount = commitBuilder.create<arith::ConstantIndexOp>(
              drainLoop.getLoc(), N);
          commitBuilder.create<PushBulkCommit>(drainLoop.getLoc(), port,
                                               viewOp.getView(), commitCount);

          drainLoop.erase();
          alloca.erase();
        } else {
          // Generic: the buffer is not ours to redirect or discard -- a
          // heap allocation with its own lifetime (and, typically, a paired
          // memref.dealloc that erasing the alloc would orphan), a bulk view
          // into another port's FIFO (the relay shape), a function
          // argument, an alloca that's still live afterwards, ... Leave it
          // exactly as it is: reserve the view where the loop sits, rewrite
          // the loop in place to copy element-by-element from the buffer
          // into the view instead of pushing scalar-by-scalar, and commit
          // immediately afterwards -- the view has no uses beyond this loop,
          // so (unlike the redirected case) there is nothing to defer for.
          OpBuilder reserveBuilder(drainLoop);
          Value reserveCount = reserveBuilder.create<arith::ConstantIndexOp>(
              drainLoop.getLoc(), N);
          auto viewOp = reserveBuilder.create<PushBulkView>(
              drainLoop.getLoc(), viewType, port, reserveCount);

          OpBuilder bodyBuilder(pushOp);
          bodyBuilder.create<memref::StoreOp>(
              pushOp.getLoc(), pushOp.getInputToken(), viewOp.getView(), iv);
          pushOp.erase();

          OpBuilder commitBuilder(drainLoop);
          commitBuilder.setInsertionPointAfter(drainLoop);
          Value commitCount = commitBuilder.create<arith::ConstantIndexOp>(
              drainLoop.getLoc(), N);
          commitBuilder.create<PushBulkCommit>(drainLoop.getLoc(), port,
                                               viewOp.getView(), commitCount);
        }
      }
    });
  }
};

} // namespace
} // namespace mlir::fifo
