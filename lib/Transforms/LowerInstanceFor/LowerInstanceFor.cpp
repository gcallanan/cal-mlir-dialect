#include "mlir/Pass/Pass.h"
#include "Transforms/Passes.h"

//===- LowerInstanceFor.cpp - Lower cal.instance_for ---------------------===//
//
// This pass lowers cal.instance_for comprehensions with static bounds by
// unrolling the body region and rewriting users to direct handles. It clones
// the region body once per iteration and collects the yielded values. Then it
// updates:
//  - cal.instance_at %result[%c]  -> replaced with the corresponding yielded
//    handle when %c is a constant within bounds
//  - cal.connect that uses array-index sugar on %result[%c] with constant %c
//    -> operand is rewritten to the direct handle and the index operand is
//       cleared
// If all uses are rewritten, the original cal.instance_for op is erased.
// Dynamic bounds or dynamic indices are left unchanged for later passes.
//
//===----------------------------------------------------------------------===//

#include "Dialect/Cal/CalOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/IRMapping.h"

using namespace mlir;
using namespace mlir::cal;

namespace mlir {
#define GEN_PASS_DEF_LOWERINSTANCEFORPASS
#include "Transforms/Passes.h.inc"

namespace {
struct LowerInstanceForPass : public impl::LowerInstanceForPassBase<LowerInstanceForPass> {
  void runOnOperation() override {
    ModuleOp module = getOperation();
    SmallVector<cal::InstanceForOp, 8> fors;
    module.walk([&](cal::InstanceForOp op){ fors.push_back(op); });

    for (cal::InstanceForOp instFor : fors) {
      OpBuilder b(instFor);

      auto constIndex = [&](Value v) -> std::optional<int64_t> {
        if (auto c = v.getDefiningOp<arith::ConstantOp>()) {
          if (auto idxAttr = dyn_cast<IntegerAttr>(c.getValue()))
            return idxAttr.getInt();
        }
        return std::nullopt;
      };

      auto lbOpt = constIndex(instFor.getLb());
      auto ubOpt = constIndex(instFor.getUb());
      auto stOpt = constIndex(instFor.getStep());
      if (!lbOpt || !ubOpt || !stOpt || *stOpt <= 0) {
        // Leave dynamic or invalid step untouched.
        continue;
      }
      int64_t lb = *lbOpt, ub = *ubOpt, step = *stOpt;
      int64_t trip = 0;
      if (ub > lb)
        trip = (ub - lb + step - 1) / step;

      if (trip == 0) {
        // Nothing to produce; if there are users, we cannot satisfy them.
        if (!instFor->use_empty()) {
          instFor.emitOpError("cannot lower cal.instance_for with zero trip count when result is used");
          signalPassFailure();
          return;
        }
        instFor.erase();
        continue;
      }

      // Collect yielded values per unrolled iteration by cloning the body.
      SmallVector<Value, 8> yielded;
      yielded.reserve(static_cast<size_t>(trip));

      // Body is a single block region; clone its ops per iteration.
      Region &body = instFor.getBody();
      if (body.empty() || body.front().empty()) {
        instFor.emitOpError("malformed cal.instance_for body");
        signalPassFailure();
        return;
      }

      // Insert clones just before the instance_for op for determinism.
      b.setInsertionPoint(instFor);
      for (int64_t i = 0; i < trip; ++i) {
        IRMapping map;
        // Clone each operation in the region block, capturing the yield value.
        Value yieldedVal;
        for (Operation &op : body.front()) {
          if (auto y = dyn_cast<cal::InstanceYieldOp>(&op)) {
            yieldedVal = map.lookupOrDefault(y.getValue());
          } else {
            Operation *clone = b.clone(op, map);
            // Map results for subsequent ops in this iteration.
            for (auto [orig, neu] : llvm::zip(op.getResults(), clone->getResults()))
              map.map(orig, neu);
          }
        }
        if (!yieldedVal) {
          instFor.emitOpError("instance_for body did not yield a value");
          signalPassFailure();
          return;
        }
        yielded.push_back(yieldedVal);
      }

      // Helper to decode a constant index from an SSA Value (index type).
      auto getConstIdx = [&](Value idxVal) -> std::optional<unsigned> {
        if (auto c = idxVal.getDefiningOp<arith::ConstantOp>()) {
          if (auto attr = dyn_cast<IntegerAttr>(c.getValue())) {
            int64_t v = attr.getInt();
            if (v >= 0 && v < trip)
              return static_cast<unsigned>(v);
          }
        }
        return std::nullopt;
      };

      // Rewrite users: handle cal.instance_at with constant index, and cal.connect
      // with array-index sugar and constant index on the side that references this result.
      SmallVector<Operation*, 8> toErase;
      for (OpOperand &use : llvm::make_early_inc_range(instFor->getUses())) {
        Operation *user = use.getOwner();
        // case 1: instance_at %res[%c]
        if (auto at = dyn_cast<cal::InstanceAtOp>(user)) {
          if (auto idx = getConstIdx(at.getIndex())) {
            at.replaceAllUsesWith(yielded[*idx]);
            toErase.push_back(at);
          }
          continue;
        }
        // case 2: connect using this result as src or dst with constant index
        if (auto conn = dyn_cast<cal::ConnectOp>(user)) {
          bool srcChanged = false, dstChanged = false;
          Value newSrc, newDst;
          // If our result is used as src and the srcIndex is a constant within bounds, rewrite
          if (conn.getSrc() == instFor.getResult()) {
            if (Value idxV = conn.getSrcIndex()) {
              if (auto idx = getConstIdx(idxV)) {
                if (*idx < yielded.size()) {
                  newSrc = yielded[*idx];
                  srcChanged = true;
                }
              }
            }
          }
          // If our result is used as dst and the dstIndex is a constant within bounds, rewrite
          if (conn.getDst() == instFor.getResult()) {
            if (Value idxV = conn.getDstIndex()) {
              if (auto idx = getConstIdx(idxV)) {
                if (*idx < yielded.size()) {
                  newDst = yielded[*idx];
                  dstChanged = true;
                }
              }
            }
          }
          if (srcChanged || dstChanged) {
            OpBuilder::InsertionGuard g(b);
            b.setInsertionPoint(conn);
            // Build a replacement connect with updated endpoints; drop index on rewritten side(s).
            auto replacement = b.create<cal::ConnectOp>(
                conn.getLoc(),
                srcChanged ? newSrc : conn.getSrc(),
                srcChanged ? Value() : conn.getSrcIndex(),
                conn.getSrcPortAttr(),
                dstChanged ? newDst : conn.getDst(),
                dstChanged ? Value() : conn.getDstIndex(),
                conn.getDstPortAttr(),
                conn.getCapacityAttr());
            // No results to replace; just erase the old op.
            (void)replacement; // silence unused warning in some builds
            toErase.push_back(conn);
          }
        }
      }
      for (Operation *op : toErase) op->erase();

      if (instFor->use_empty()) {
        instFor.erase();
      } else {
        // Leave remaining uses intact for later passes.
        instFor.emitRemark("lowering left non-rewritable uses; expected only instance_at/array-index connects with constant indices");
      }
    }
  }
};
} // namespace

} // namespace mlir

std::unique_ptr<mlir::Pass> mlir::createLowerInstanceForPass() {
  return std::make_unique<mlir::LowerInstanceForPass>();
}
 
