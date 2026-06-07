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

struct ExtractFifoPopViewPass
    : public impl::ExtractFifoPopViewPassBase<ExtractFifoPopViewPass> {

  // Finds a top-level loop of the canonical fill shape -- lb=0, step=1, body
  // exactly {poppedVal = pop(port); store poppedVal, X[iv]; yield} -- and
  // returns it together with the matched pop and the destination buffer X
  // (nulls if no such loop exists).
  //
  // X is discovered from the store itself rather than assumed up front, so it
  // may be *any* rank-1, statically-shaped memref of matching size and
  // element type: a local memref.alloca (the common case, eligible for the
  // zero-copy redirect-and-erase rewrite below), a heap memref.alloc, the
  // result of a fifo.push_bulk_view on a *different* port -- the "relay"
  // shape where an actor immediately forwards a popped bulk region into
  // another FIFO -- a function argument, etc. The two rewrite strategies in
  // runOnOperation adapt to whichever it turns out to be.
  static std::tuple<scf::ForOp, Pop, Value>
  findPopFillLoop(Block *actionBlock) {
    for (auto &op : *actionBlock) {
      auto forOp = dyn_cast<scf::ForOp>(&op);
      if (!forOp)
        continue;

      if (!isConstantIndexEqualTo(forOp.getLowerBound(), 0) ||
          !isConstantIndexEqualTo(forOp.getStep(), 1))
        continue;

      // The loop body must be exactly: poppedVal = pop(port);
      // store poppedVal, X[iv]; yield -- nothing else, so we know precisely
      // what flows out of the FIFO and where it lands.
      Block *loopBody = &forOp.getRegion().front();
      Value iv = forOp.getInductionVar();

      Pop foundPop;
      memref::StoreOp foundStore;
      bool unexpectedOp = false;

      for (auto &bodyOp : *loopBody) {
        if (isa<scf::YieldOp>(&bodyOp))
          continue;
        if (auto pop = dyn_cast<Pop>(&bodyOp)) {
          if (!foundPop) {
            foundPop = pop;
            continue;
          }
        } else if (auto store = dyn_cast<memref::StoreOp>(&bodyOp)) {
          if (foundPop && !foundStore && store.getIndices().size() == 1 &&
              store.getIndices()[0] == iv &&
              store.getValue() == foundPop.getOutputToken()) {
            foundStore = store;
            continue;
          }
        }
        unexpectedOp = true;
        break;
      }

      if (unexpectedOp || !foundPop || !foundStore)
        continue;

      Value buffer = foundStore.getMemref();
      auto bufferType = mlir::dyn_cast<MemRefType>(buffer.getType());
      if (!bufferType || bufferType.getRank() != 1 ||
          bufferType.isDynamicDim(0))
        continue;
      int64_t N = bufferType.getDimSize(0);
      if (!matchesConstantBound(forOp.getUpperBound(), N))
        continue;

      // The buffer must already be available by the time the loop runs: if
      // it has a defining op, that op must live in this same block, before
      // the loop (a block argument trivially qualifies; an op nested in some
      // other region does not).
      if (Operation *def = buffer.getDefiningOp())
        if (def->getBlock() != actionBlock || !def->isBeforeInBlock(forOp))
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

      return {forOp, foundPop, buffer};
    }
    return {};
  }

  void runOnOperation() override {
    ModuleOp module = getOperation();

    module.walk([&](cal::ActionOp action) {
      Block *body = &action.getBody().front();

      // Search to a fixed point: every successful match below either erases
      // the fill loop outright (redirect-and-erase) or erases the fifo.pop
      // inside it (generic rewrite), so a loop can never match twice -- the
      // search is guaranteed to terminate, and re-running it from scratch
      // sidesteps any iterator invalidation from the rewrite.
      while (true) {
        auto [fillLoop, popOp, buffer] = findPopFillLoop(body);
        if (!fillLoop)
          break;

        auto bufferType = mlir::cast<MemRefType>(buffer.getType());
        int64_t N = bufferType.getDimSize(0);
        Type elemType = bufferType.getElementType();
        Value port = popOp.getOutputPort();
        Value iv = fillLoop.getInductionVar();

        // Result type: memref<N x T, strided<[1], offset: ?>>
        // This is the natural result type of a 1-D subview with a dynamic
        // offset (the runtime read-pointer) and static size N and stride 1.
        auto stridedLayout = StridedLayoutAttr::get(
            &getContext(), ShapedType::kDynamic, {1});
        auto viewType = MemRefType::get({N}, elemType, stridedLayout);

        if (auto alloca = buffer.getDefiningOp<memref::AllocaOp>()) {
          // Zero-copy: acquire the view where the fill loop used to be --
          // the earliest point any of the alloca's uses occur -- and
          // redirect every one of those uses (loads, stores from later
          // loops that read or write back through it) onto the acquired
          // FIFO region directly (memref.load/memref.store accept any
          // MemRefType layout, so this is always legal). Deferring the
          // release to the end of the action body covers every redirected
          // use, however far downstream, so -- unlike the push side --
          // there is no "last use" precondition to check here: an alloca is
          // always eligible. That makes the fill loop redundant (its pops
          // would now double-consume data the view already exposes, and
          // its stores would corrupt that same view), and the alloca dead;
          // erase both.
          OpBuilder acquireBuilder(fillLoop);
          Value acquireCount = acquireBuilder.create<arith::ConstantIndexOp>(
              fillLoop.getLoc(), N);
          auto viewOp = acquireBuilder.create<PopBulkView>(
              fillLoop.getLoc(), viewType, port, acquireCount);
          buffer.replaceAllUsesWith(viewOp.getView());

          OpBuilder releaseBuilder(body, body->end());
          Value releaseCount = releaseBuilder.create<arith::ConstantIndexOp>(
              fillLoop.getLoc(), N);
          releaseBuilder.create<PopBulkRelease>(fillLoop.getLoc(), port,
                                                releaseCount);

          fillLoop.erase();
          alloca.erase();
        } else {
          // Generic: the buffer is not ours to redirect or discard -- a
          // heap allocation with its own lifetime (and, typically, a paired
          // memref.dealloc that erasing the alloc would orphan), a bulk view
          // reserved on another port's FIFO (the relay shape), a function
          // argument, ... Leave it exactly as it is: acquire the view where
          // the loop sits, rewrite the loop in place to copy
          // element-by-element from the view into the buffer instead of
          // popping scalar-by-scalar, and release immediately afterwards --
          // the view has no uses beyond this loop, so (unlike the
          // redirected case) there is nothing to defer for.
          OpBuilder acquireBuilder(fillLoop);
          Value acquireCount = acquireBuilder.create<arith::ConstantIndexOp>(
              fillLoop.getLoc(), N);
          auto viewOp = acquireBuilder.create<PopBulkView>(
              fillLoop.getLoc(), viewType, port, acquireCount);

          OpBuilder bodyBuilder(popOp);
          Value loaded = bodyBuilder.create<memref::LoadOp>(
              popOp.getLoc(), viewOp.getView(), iv);
          popOp.getOutputToken().replaceAllUsesWith(loaded);
          popOp.erase();

          OpBuilder releaseBuilder(fillLoop);
          releaseBuilder.setInsertionPointAfter(fillLoop);
          Value releaseCount = releaseBuilder.create<arith::ConstantIndexOp>(
              fillLoop.getLoc(), N);
          releaseBuilder.create<PopBulkRelease>(fillLoop.getLoc(), port,
                                                releaseCount);
        }
      }
    });
  }
};

} // namespace
} // namespace mlir::fifo
