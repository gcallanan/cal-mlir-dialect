//===- CalOps.cpp - Cal dialect ops ---------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalTypes.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/Block.h"
#include "mlir/IR/Region.h"
#include "mlir/IR/PatternMatch.h"

using namespace mlir;
using namespace mlir::cal;

#define GET_OP_CLASSES
#include "Dialect/Cal/CalOps.cpp.inc"
//===----------------------------------------------------------------------===//
// Helpers
//===----------------------------------------------------------------------===//

static LogicalResult verifyPortNames(Operation *op, ArrayAttr names, StringRef which) {
  if (!names)
    return success();
  llvm::SmallDenseSet<StringRef, 8> seen;
  for (Attribute a : names) {
    auto s = dyn_cast<StringAttr>(a);
    if (!s || s.getValue().empty())
      return op->emitOpError() << which << " port names must be non-empty strings";
    if (!seen.insert(s.getValue()).second)
      return op->emitOpError() << which << " port names must be unique; duplicate '" << s.getValue() << "'";
  }
  return success();
}

// Returns success if the operation has an ancestor cal.network. This allows
// structural construction ops to appear nested under scf.if/for as long as
// they are within some network.
static LogicalResult requireNetworkAncestor(Operation *op, StringRef opname) {
  for (Operation *cur = op->getParentOp(); cur; cur = cur->getParentOp()) {
    if (llvm::isa<mlir::cal::NetworkOp>(cur))
      return success();
  }
  return op->emitOpError() << "'" << opname
                           << "' must be nested within a cal.network (ancestor),"
                           << " potentially under scf.if/scf.for";
}

template <typename PortTy>
static bool isPortTypeOf(Type t) {
  return isa<PortTy>(t);
}

// Legacy cal.instance_for op was removed; associated verifier deleted.
//===----------------------------------------------------------------------===//
// FSM op verifiers
//===----------------------------------------------------------------------===//

LogicalResult FsmOp::verify() {
  // Region must have exactly one block.
  if (!getBody().hasOneBlock())
    return emitOpError() << "expected fsm region to have exactly one block";

  // Body must contain only cal.state ops; count initials.
  int initialCount = 0;
  for (Operation &op : getBody().front()) {
    if (!llvm::isa<StateOp>(op))
      return emitOpError() << "fsm body may only contain cal.state ops";
    auto st = llvm::cast<StateOp>(&op);
    // Be permissive: consider either the typed accessor or the raw attribute
    // to account for minor assembly/printer differences across versions.
    bool hasInitial = false;
    if (auto init = st.getInitial())
      hasInitial = true;
    else if (st->getAttr("initial"))
      hasInitial = true;
    if (hasInitial)
      initialCount++;
  }
  // Accept 0 or 1 initial states to avoid over-strict rejection on legacy IR;
  // still reject ambiguous FSMs with multiple initials.
  if (initialCount > 1)
    return emitOpError() << "expected at most one initial state, found " << initialCount;
  return success();
}

LogicalResult StateOp::verify() {
  // Allow an empty state body to represent a terminal/dead state.
  if (getBody().empty())
    return success();
  // State body may contain only cal.transition ops.
  for (Operation &op : getBody().front()) {
    if (!llvm::isa<TransitionOp>(op))
      return emitOpError() << "state body may only contain cal.transition ops";
  }
  return success();
}

LogicalResult TransitionOp::verify() {
  // Validate that target refers to a sibling cal.state within the same cal.fsm.
  SymbolTableCollection symbolTable;
  auto targetRef = getTargetAttr();
  if (!symbolTable.lookupNearestSymbolFrom<StateOp>(*this, targetRef))
    return emitOpError() << "target state '" << targetRef.getValue()
                         << "' not found in enclosing cal.fsm";

  // Validate that actionName names a cal.action in the same cal.actor.
  auto actor = getOperation()->getParentOfType<ActorOp>();
  if (!actor)
    return emitOpError() << "cal.transition must be nested under cal.fsm within a cal.actor";

  StringRef wanted = getActionName();
  bool found = false;
  for (Operation &op : actor.getBody().front()) {
    if (auto action = llvm::dyn_cast<ActionOp>(&op)) {
      if (auto nameAttr = action.getActionNameAttr()) {
        if (nameAttr.getValue() == wanted) {
          found = true;
          break;
        }
      }
    }
  }
  if (!found)
    return emitOpError() << "action '" << wanted
                         << "' not found in enclosing cal.actor (actions must be named to be referenced)";

  return success();
}

// Ensure that the transition's target state symbol is a valid reference.
// Implementing this hook satisfies the SymbolUserOpInterface vtable and
// allows passes like SymbolDCE to recognize the reference and keep the
// targeted state alive.
LogicalResult TransitionOp::verifySymbolUses(SymbolTableCollection &symbolTable) {
  auto targetRef = getTargetAttr();
  if (!symbolTable.lookupNearestSymbolFrom<StateOp>(*this, targetRef)) {
    return emitOpError() << "target state '" << targetRef.getValue()
                         << "' not found in enclosing cal.fsm";
  }
  return success();
}
//===----------------------------------------------------------------------===//
// ConnectOp canonicalization: lower array+index sides to instance_at handles.
// This yields a handle-only connect in the IR (printer may still show sugar).
//===----------------------------------------------------------------------===//

namespace {
struct ConnectLowerArrayIndexToInstanceAt : ::mlir::OpRewritePattern<ConnectOp> {
  using ::mlir::OpRewritePattern<ConnectOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(ConnectOp op,
                                ::mlir::PatternRewriter &rewriter) const override {
    bool changed = false;
    Location loc = op.getLoc();

    // Lower src side if it is an array with indices.
    if ((isa<InstanceArrayType>(op.getSrc().getType()) ||
         isa<InterfaceInstanceArrayType>(op.getSrc().getType())) &&
        !op.getSrcIndices().empty()) {
      Value arr = op.getSrc();
      Type arrTy = arr.getType();
      Type handleTy;
      if (auto entArr = dyn_cast<InstanceArrayType>(arrTy))
        handleTy = InstanceType::get(op.getContext(), entArr.getActorRef());
      else if (auto ifArr = dyn_cast<InterfaceInstanceArrayType>(arrTy))
        handleTy = InterfaceInstanceType::get(op.getContext(), ifArr.getIfaceRef());
      else
        return failure();
      SmallVector<Value, 4> idxs(op.getSrcIndices().begin(), op.getSrcIndices().end());
      rewriter.setInsertionPoint(op);
      auto at = rewriter.create<InstanceAtOp>(loc, handleTy, arr, idxs);
      op.getSrcMutable().assign(at.getHandle());
      op.getSrcIndicesMutable().clear();
      changed = true;
    }

    // Lower dst side if it is an array with indices.
    if ((isa<InstanceArrayType>(op.getDst().getType()) ||
         isa<InterfaceInstanceArrayType>(op.getDst().getType())) &&
        !op.getDstIndices().empty()) {
      Value arr = op.getDst();
      Type arrTy = arr.getType();
      Type handleTy;
      if (auto entArr = dyn_cast<InstanceArrayType>(arrTy))
        handleTy = InstanceType::get(op.getContext(), entArr.getActorRef());
      else if (auto ifArr = dyn_cast<InterfaceInstanceArrayType>(arrTy))
        handleTy = InterfaceInstanceType::get(op.getContext(), ifArr.getIfaceRef());
      else
        return failure();
      SmallVector<Value, 4> idxs(op.getDstIndices().begin(), op.getDstIndices().end());
      rewriter.setInsertionPoint(op);
      auto at = rewriter.create<InstanceAtOp>(loc, handleTy, arr, idxs);
      op.getDstMutable().assign(at.getHandle());
      op.getDstIndicesMutable().clear();
      changed = true;
    }

    return success(changed);
  }
};

//===----------------------------------------------------------------------===//
// Canonicalization: Promote dynamic 1-D instance array fill loops to static.
// See detailed comment near the bottom registration for the handled pattern.
//===----------------------------------------------------------------------===//
struct PromoteDynamicInstanceArrayFillLoop : OpRewritePattern<cal::InstanceArraySetOp> {
  using OpRewritePattern::OpRewritePattern;
  LogicalResult matchAndRewrite(cal::InstanceArraySetOp setOp,
                                PatternRewriter &rewriter) const override {
    setOp.emitRemark("promote-instance-array: considering set op");
    // Must be inside an scf.for.
    auto forOp = dyn_cast<scf::ForOp>(setOp->getParentOp());
    if (!forOp) {
      setOp.emitRemark("promote-instance-array: not inside scf.for");
      return failure();
    }
    setOp.emitRemark("promote-instance-array: inside scf.for");

    // Single iter arg/result only.
    if (forOp.getInitArgs().size() != 1 || forOp.getNumResults() != 1) {
      setOp.emitRemark("promote-instance-array: loop does not have single iter_arg/result");
      return failure();
    }
    setOp.emitRemark("promote-instance-array: loop has single iter_arg/result");

    // The yielded value must be this setOp's result.
    auto yieldOp = dyn_cast<scf::YieldOp>(forOp.getBody()->getTerminator());
    if (!yieldOp || yieldOp.getNumOperands() != 1 || yieldOp.getOperand(0) != setOp.getResult()) {
      setOp.emitRemark("promote-instance-array: scf.yield does not return the set result");
      return failure();
    }
    setOp.emitRemark("promote-instance-array: scf.yield returns set result");

    // Dynamic 1-D instance array type check.
    auto dynArrTy = dyn_cast<cal::InstanceArrayType>(forOp.getResult(0).getType());
    if (!dynArrTy) {
      setOp.emitRemark("promote-instance-array: for result is not an instance array");
      return failure();
    }
    ArrayAttr shapeAttr = dynArrTy.getShape();
    if (!shapeAttr || shapeAttr.size() != 1) {
      setOp.emitRemark("promote-instance-array: array rank is not 1 (only 1-D supported)");
      return failure();
    }
    auto dimAttr = dyn_cast<IntegerAttr>(shapeAttr[0]);
    if (!dimAttr || dimAttr.getInt() != -1) {
      setOp.emitRemark("promote-instance-array: array shape is already static or missing dynamic marker (-1)");
      return failure(); // already static or not dynamic marker
    }
    setOp.emitRemark("promote-instance-array: dynamic 1-D instance array confirmed");

    // Initial value must come from a matching cal.instance.array.init with dynamic shape.
    auto initOp = forOp.getInitArgs()[0].getDefiningOp<cal::InstanceArrayInitOp>();
    if (!initOp) {
      setOp.emitRemark("promote-instance-array: init value is not from cal.instance.array.init");
      return failure();
    }
    auto initTy = dyn_cast<cal::InstanceArrayType>(initOp.getArray().getType());
    if (!initTy || initTy.getActorRef() != dynArrTy.getActorRef()) {
      setOp.emitRemark("promote-instance-array: init type mismatch with loop result type");
      return failure();
    }
    auto initShape = initTy.getShape();
    if (!initShape || initShape.size() != 1) {
      setOp.emitRemark("promote-instance-array: init array is not rank-1");
      return failure();
    }
    auto initDimAttr = dyn_cast<IntegerAttr>(initShape[0]);
    if (!initDimAttr || initDimAttr.getInt() != -1) {
      setOp.emitRemark("promote-instance-array: init already static (should have specialized earlier)");
      return failure(); // already static (another pattern should have handled this)
    }
    setOp.emitRemark("promote-instance-array: init is dynamic and matches actor type");

    // Loop bounds + step must be constant index.
    auto lbC = forOp.getLowerBound().getDefiningOp<arith::ConstantOp>();
    auto ubC = forOp.getUpperBound().getDefiningOp<arith::ConstantOp>();
    auto stC = forOp.getStep().getDefiningOp<arith::ConstantOp>();
    if (!lbC || !ubC || !stC) {
      setOp.emitRemark("promote-instance-array: loop bounds/step are not constants");
      return failure();
    }
    setOp.emitRemark("promote-instance-array: loop bounds/step are constants");
    auto lbIdx = dyn_cast<IntegerAttr>(lbC.getValue());
    auto ubIdx = dyn_cast<IntegerAttr>(ubC.getValue());
    auto stIdx = dyn_cast<IntegerAttr>(stC.getValue());
    if (!lbIdx || !ubIdx || !stIdx) {
      setOp.emitRemark("promote-instance-array: loop bound/step constants are not integer attrs");
      return failure();
    }
    int64_t lb = lbIdx.getInt();
    int64_t ub = ubIdx.getInt();
    int64_t step = stIdx.getInt();
    if (step != 1 || ub < lb) {
      setOp.emitRemark("promote-instance-array: step!=1 or ub<lb");
      return failure();
    }
    int64_t tripCount = ub - lb;
    if (tripCount < 0) {
      setOp.emitRemark("promote-instance-array: negative trip count");
      return failure();
    }
    setOp.emitRemark("promote-instance-array: computed tripCount");

    // Init op must have exactly one dim operand which is a constant equal to tripCount.
    if (initOp.getDims().size() != 1) {
      setOp.emitRemark("promote-instance-array: init has not exactly one dim operand");
      return failure();
    }
    auto dimValC = initOp.getDims()[0].getDefiningOp<arith::ConstantOp>();
    if (!dimValC) {
      setOp.emitRemark("promote-instance-array: init dim is not an arith.constant");
      return failure();
    }
    auto dimValAttr = dyn_cast<IntegerAttr>(dimValC.getValue());
    if (!dimValAttr || dimValAttr.getInt() != tripCount) {
      setOp.emitRemark("promote-instance-array: init dim constant does not equal trip count");
      return failure();
    }
    setOp.emitRemark("promote-instance-array: init dim matches trip count");

    setOp.emitRemark("promote-instance-array: begin scanning loop body");

  // Body must contain exactly: (optional) index arithmetic/casts, one or more cal.instantiate ops,
  // one cal.instance.array.set (the matched op), no other side-effecting ops.
    Value iv = forOp.getInductionVar();
    bool seenSet = false;
    for (Operation &op : *forOp.getBody()) {
      if (isa<scf::YieldOp>(op)) continue;
      if (&op == setOp.getOperation()) {
        if (seenSet) return failure();
        seenSet = true;
        continue;
      }
      if (isa<arith::SubIOp, arith::AddIOp, arith::IndexCastOp>(op)) {
        // Allow if results are only used by the setOp index chain or cal.instantiate params.
        for (Value res : op.getResults()) {
          for (Operation *user : res.getUsers()) {
            if (user != setOp.getOperation() && !isa<cal::InstantiateOp>(user)) {
              setOp.emitRemark("promote-instance-array: arithmetic/cast result has unsupported user: ")
                   .append(user->getName().getStringRef());
              return failure();
            }
          }
        }
        continue;
      }
      if (isa<cal::InstantiateOp>(op)) continue;
      // Disallow any other op types for now (keeps pattern conservative).
      setOp.emitRemark("promote-instance-array: encountered unsupported op in loop body: ").append(op.getName().getStringRef());
      return failure();
    }
    if (!seenSet) {
      setOp.emitRemark("promote-instance-array: did not see set op during body scan");
      return failure();
    }
    setOp.emitRemark("promote-instance-array: loop body scan passed");

    // Validate index expression maps iv -> [0..tripCount-1].
    if (setOp.getIndices().size() != 1)
      return failure();
    Value idxVal = setOp.getIndices()[0];
    setOp.emitRemark("promote-instance-array: validating index expression");
    auto asConstOffset = [&](Value v) -> std::optional<int64_t> {
      if (v == iv) {
        if (lb == 0) return 0; // idx = iv - lb
        return std::nullopt;   // iv alone with non-zero lb not supported
      }
      if (auto subi = v.getDefiningOp<arith::SubIOp>()) {
        if (subi.getLhs() == iv) {
          if (auto c = subi.getRhs().getDefiningOp<arith::ConstantOp>()) {
            if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) { if (lb == ia.getInt()) return 0; else return std::nullopt; }
          }
          if (auto cast = subi.getRhs().getDefiningOp<arith::IndexCastOp>()) {
            if (auto c2 = cast.getIn().getDefiningOp<arith::ConstantOp>()) {
              if (auto ia2 = dyn_cast<IntegerAttr>(c2.getValue())) { if (lb == ia2.getInt()) return 0; }
            }
          }
        }
      }
      return std::nullopt;
    };
    if (!asConstOffset(idxVal)) {
      setOp.emitRemark("promote-instance-array: index expr is not iv or (iv - lb)");
      return failure();
    }
    setOp.emitRemark("promote-instance-array: index expression validated");

    // All preconditions satisfied -> perform rewrite.
    Location loc = forOp.getLoc();
    MLIRContext *ctx = rewriter.getContext();
    auto i64Ty = rewriter.getIntegerType(64);
    auto newDimAttr = IntegerAttr::get(i64Ty, tripCount);
    auto newShape = ArrayAttr::get(ctx, ArrayRef<Attribute>{newDimAttr});
    auto staticArrTy = cal::InstanceArrayType::get(ctx, dynArrTy.getActorRef(), newShape);

    rewriter.setInsertionPoint(forOp);
    // New static init (no dynamic dims operands required for static shape).
    auto newInit = rewriter.create<cal::InstanceArrayInitOp>(loc, staticArrTy, ValueRange{});
    Value cur = newInit.getArray();

    // Gather instantiate ops (in original order) for cloning each iteration.
    SmallVector<cal::InstantiateOp, 4> instOps;
    for (Operation &op : *forOp.getBody()) {
      if (auto inst = dyn_cast<cal::InstantiateOp>(&op)) instOps.push_back(inst);
    }

    for (int64_t i = 0; i < tripCount; ++i) {
      // Clone instantiate ops for this iteration.
      SmallVector<Value> lastHandles; lastHandles.reserve(instOps.size());
      for (cal::InstantiateOp inst : instOps) {
        Operation *cloned = rewriter.clone(*inst.getOperation());
        lastHandles.push_back(cloned->getResult(0));
      }
      // Use last handle if multiple (common pattern is one). Otherwise, bail if none.
      if (lastHandles.empty()) return failure();
      Value handle = lastHandles.back();
      // Constant index i.
      auto idxConst = rewriter.create<arith::ConstantOp>(loc, rewriter.getIndexAttr(i));
      cur = rewriter.create<cal::InstanceArraySetOp>(loc, staticArrTy, cur, ValueRange{idxConst}, handle).getResult();
    }

    setOp.emitRemark("promote-instance-array: succeeded, specialized to static extent");
    rewriter.replaceOp(forOp, cur);
    return success();
  }
};
} // namespace

void ConnectOp::getCanonicalizationPatterns(::mlir::RewritePatternSet &results,
                                            ::mlir::MLIRContext *context) {
  results.add<ConnectLowerArrayIndexToInstanceAt>(context);
}

// Populate extra CAL canonicalization patterns (anchored on non-CAL ops too).
void mlir::cal::populateCalCanonicalizationPatterns(mlir::RewritePatternSet &results) {
  MLIRContext *context = results.getContext();
  // Reuse existing connect lowering pattern (already added via op interface when matching cal.connect).
  // Add scf.for anchored promotion pattern (safe version) replacing previous InstanceArraySetOp variant.
  struct PromoteDynamicInstanceArrayFillLoopFor : OpRewritePattern<scf::ForOp> {
    using OpRewritePattern<scf::ForOp>::OpRewritePattern;
    LogicalResult matchAndRewrite(scf::ForOp forOp, PatternRewriter &rewriter) const override {
      // Require single iter arg/result.
      if (forOp.getInitArgs().size() != 1 || forOp.getNumResults() != 1)
        return failure();
      auto arrTy = dyn_cast<cal::InstanceArrayType>(forOp.getResult(0).getType());
      if (!arrTy) return failure();
      ArrayAttr shapeAttr = arrTy.getShape();
      if (!shapeAttr || shapeAttr.size() != 1) return failure();
      auto dimAttr = dyn_cast<IntegerAttr>(shapeAttr[0]);
      if (!dimAttr || dimAttr.getInt() != -1) return failure(); // only dynamic marker

      // Init must be array.init of same actor with dynamic shape and one dim operand constant.
      auto initOp = forOp.getInitArgs()[0].getDefiningOp<cal::InstanceArrayInitOp>();
      if (!initOp) return failure();
      auto initTy = dyn_cast<cal::InstanceArrayType>(initOp.getArray().getType());
      if (!initTy || initTy.getActorRef() != arrTy.getActorRef()) return failure();
      auto initShape = initTy.getShape();
      if (!initShape || initShape.size() != 1) return failure();
      auto initDimAttr = dyn_cast<IntegerAttr>(initShape[0]);
      if (!initDimAttr || initDimAttr.getInt() != -1) return failure();
      if (initOp.getDims().size() != 1) return failure();
      auto dimConst = initOp.getDims()[0].getDefiningOp<arith::ConstantOp>();
      if (!dimConst) return failure();
      auto dimConstAttr = dyn_cast<IntegerAttr>(dimConst.getValue());
      if (!dimConstAttr) return failure();

      // Bounds must be constant; step must be 1.
      auto lbC = forOp.getLowerBound().getDefiningOp<arith::ConstantOp>();
      auto ubC = forOp.getUpperBound().getDefiningOp<arith::ConstantOp>();
      auto stC = forOp.getStep().getDefiningOp<arith::ConstantOp>();
      if (!lbC || !ubC || !stC) return failure();
      auto lbAttr = dyn_cast<IntegerAttr>(lbC.getValue());
      auto ubAttr = dyn_cast<IntegerAttr>(ubC.getValue());
      auto stAttr = dyn_cast<IntegerAttr>(stC.getValue());
      if (!lbAttr || !ubAttr || !stAttr) return failure();
      int64_t lb = lbAttr.getInt();
      int64_t ub = ubAttr.getInt();
      int64_t step = stAttr.getInt();
      if (step != 1 || ub < lb) return failure();
      int64_t tripCount = ub - lb;
      if (tripCount < 0) return failure();
      if (dimConstAttr.getInt() != tripCount) return failure();

      // Scan body: need exactly one cal.instance.array.set writing iter arg; any number of cal.instantiate; optional arithmetic/casts for index/params.
      Value iv = forOp.getInductionVar();
      cal::InstanceArraySetOp setOpInLoop = nullptr;
      SmallVector<cal::InstantiateOp, 4> instOps;
      for (Operation &op : *forOp.getBody()) {
        if (isa<scf::YieldOp>(op)) continue;
        if (auto set = dyn_cast<cal::InstanceArraySetOp>(&op)) {
          if (setOpInLoop) return failure();
          // Must update the same evolving array value.
          if (set.getArray() != forOp.getRegionIterArgs()[0]) return failure();
          setOpInLoop = set;
          continue;
        }
        if (auto inst = dyn_cast<cal::InstantiateOp>(&op)) { instOps.push_back(inst); continue; }
        if (isa<arith::SubIOp, arith::AddIOp, arith::IndexCastOp>(op)) continue; // conservative allow
        return failure();
      }
      if (!setOpInLoop) return failure();
      auto yieldOp = dyn_cast<scf::YieldOp>(forOp.getBody()->getTerminator());
      if (!yieldOp || yieldOp.getOperand(0) != setOpInLoop.getResult()) return failure();

      // Index must be iv or iv - lb.
      if (setOpInLoop.getIndices().size() != 1) return failure();
      Value idxVal = setOpInLoop.getIndices()[0];
      auto isValidIndex = [&]()->bool {
        if (idxVal == iv && lb == 0) return true;
        if (auto sub = idxVal.getDefiningOp<arith::SubIOp>()) {
          if (sub.getLhs() == iv) {
            if (auto c = sub.getRhs().getDefiningOp<arith::ConstantOp>()) {
              if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) return ia.getInt() == lb; }
            if (auto cast = sub.getRhs().getDefiningOp<arith::IndexCastOp>()) {
              if (auto c2 = cast.getIn().getDefiningOp<arith::ConstantOp>()) {
                if (auto ia2 = dyn_cast<IntegerAttr>(c2.getValue())) return ia2.getInt() == lb; }
            }
          }
        }
        return false;
      };
      if (!isValidIndex()) return failure();

      // Perform rewrite: build static array, clone instantiate ops per iteration, set elements.
  auto i64Ty = rewriter.getIntegerType(64);
  auto newDimAttr = IntegerAttr::get(i64Ty, tripCount);
  auto newShape = ArrayAttr::get(rewriter.getContext(), ArrayRef<Attribute>{newDimAttr});
  auto staticArrTy = cal::InstanceArrayType::get(rewriter.getContext(), arrTy.getActorRef(), newShape);

      rewriter.setInsertionPoint(forOp);
      auto newInit = rewriter.create<cal::InstanceArrayInitOp>(forOp.getLoc(), staticArrTy, ValueRange{});
      Value cur = newInit.getArray();
      for (int64_t i = 0; i < tripCount; ++i) {
        // Clone instantiate ops for this iteration (preserve order).
        SmallVector<Value> handles;
        for (cal::InstantiateOp inst : instOps) {
          Operation *cloned = rewriter.clone(*inst.getOperation());
          handles.push_back(cloned->getResult(0));
        }
        if (handles.empty()) return failure();
        Value handle = handles.back();
        auto idxConst = rewriter.create<arith::ConstantOp>(forOp.getLoc(), rewriter.getIndexAttr(i));
        cur = rewriter.create<cal::InstanceArraySetOp>(forOp.getLoc(), staticArrTy, cur, ValueRange{idxConst}, handle).getResult();
      }

      // Replace external uses explicitly before erasing the loop. This avoids
      // triggering replaceOp assertions on region operations with internal
      // self references.
      forOp.getResult(0).replaceAllUsesWith(cur);
      rewriter.eraseOp(forOp);
      return success();
    }
  };
  results.add<PromoteDynamicInstanceArrayFillLoopFor>(context);
}

// Custom assembly for cal.connect supporting either handle or array+index per side.
mlir::ParseResult ConnectOp::parse(OpAsmParser &parser, OperationState &result) {
  auto parseSide = [&](OpAsmParser::UnresolvedOperand &base,
                       Type &ty,
                       llvm::SmallVectorImpl<OpAsmParser::UnresolvedOperand> &indices,
                       bool allowOutputPort, bool allowInputPort) -> ParseResult {
    if (parser.parseOperand(base))
      return failure();
    // Optional sugar: [%idx]
    if (succeeded(parser.parseOptionalLSquare())) {
      OpAsmParser::UnresolvedOperand idxOp;
      if (parser.parseOperand(idxOp))
        return failure();
      indices.push_back(idxOp);
      while (succeeded(parser.parseOptionalComma())) {
        OpAsmParser::UnresolvedOperand nextIdx;
        if (parser.parseOperand(nextIdx))
          return failure();
        indices.push_back(nextIdx);
      }
      if (parser.parseRSquare()) return failure();
    }
    if (parser.parseColon() || parser.parseType(ty))
      return failure();
    // If index was provided, require array type.
    if (!indices.empty() &&
        !(mlir::isa<InstanceArrayType>(ty) || mlir::isa<InterfaceInstanceArrayType>(ty)))
      return parser.emitError(parser.getCurrentLocation(),
                              "index form requires !cal.instance.array<...> type");
    // If no index, require either a handle type or a permitted fifo port type.
    if (indices.empty() &&
        !(mlir::isa<InstanceType>(ty) || mlir::isa<InterfaceInstanceType>(ty))) {
      bool ok = false;
      if (allowOutputPort && mlir::isa<mlir::fifo::OutputPortType>(ty)) ok = true;
      if (allowInputPort && mlir::isa<mlir::fifo::InputPortType>(ty)) ok = true;
      if (!ok)
        return parser.emitError(parser.getCurrentLocation(),
                                "expected !cal.instance<...>"
                                " or !cal.instance.iface<...> or an allowed fifo port type for this side");
    }
    return success();
  };

  OpAsmParser::UnresolvedOperand srcBase, dstBase;
  Type srcTy, dstTy;
  llvm::SmallVector<OpAsmParser::UnresolvedOperand,4> srcIdx, dstIdx;
  StringAttr srcPortAttr, dstPortAttr;

  if (failed(parseSide(srcBase, srcTy, srcIdx, /*allowOutputPort=*/true, /*allowInputPort=*/false)))
    return failure();
  if (parser.parseAttribute(srcPortAttr))
    return failure();
  if (parser.parseArrow())
    return failure();
  if (failed(parseSide(dstBase, dstTy, dstIdx, /*allowOutputPort=*/false, /*allowInputPort=*/true)))
    return failure();
  if (parser.parseAttribute(dstPortAttr))
    return failure();

  // Optional: capacity(<i64>)
  IntegerAttr capacityAttr;
  if (succeeded(parser.parseOptionalKeyword("capacity"))) {
    if (parser.parseLParen() || parser.parseAttribute(capacityAttr) || parser.parseRParen())
      return failure();
    result.addAttribute("capacity", capacityAttr);
  }

  (void)parser.parseOptionalAttrDict(result.attributes);

  // Resolve src and optional index
  if (parser.resolveOperand(srcBase, srcTy, result.operands))
    return failure();
  int32_t numSrcIdx = 0;
  if (mlir::isa<InstanceArrayType>(srcTy) || mlir::isa<InterfaceInstanceArrayType>(srcTy)) {
    if (srcIdx.empty())
      return parser.emitError(parser.getCurrentLocation(), "missing index for source array operand");
    numSrcIdx = static_cast<int32_t>(srcIdx.size());
    for (auto &opd : srcIdx) {
      if (parser.resolveOperand(opd, parser.getBuilder().getIndexType(), result.operands))
        return failure();
    }
  }

  // Resolve dst and optional index
  if (parser.resolveOperand(dstBase, dstTy, result.operands))
    return failure();
  int32_t numDstIdx = 0;
  if (mlir::isa<InstanceArrayType>(dstTy) || mlir::isa<InterfaceInstanceArrayType>(dstTy)) {
    if (dstIdx.empty())
      return parser.emitError(parser.getCurrentLocation(), "missing index for destination array operand");
    numDstIdx = static_cast<int32_t>(dstIdx.size());
    for (auto &opd : dstIdx) {
      if (parser.resolveOperand(opd, parser.getBuilder().getIndexType(), result.operands))
        return failure();
    }
  }

  result.addAttribute("srcPort", srcPortAttr);
  result.addAttribute("dstPort", dstPortAttr);

  // Record operand segment sizes for variadic indices: [src, srcIndices..., dst, dstIndices...]
  auto sizes = llvm::SmallVector<int32_t, 4>{1, numSrcIdx, 1, numDstIdx};
  result.addAttribute("operand_segment_sizes",
                      parser.getBuilder().getDenseI32ArrayAttr(sizes));
  return success();
}

void ConnectOp::print(OpAsmPrinter &printer) {
  auto printHandleWithOptionalIndex = [&](Value handle) {
    if (auto at = handle.getDefiningOp<InstanceAtOp>()) {
      // Print as %array[idx0, idx1, ...] : !cal.instance.array<...>
      Value array = at.getArray();
      printer.printOperand(array);
      printer << '[';
      bool first = true;
      for (Value index : at.getIndices()) {
        if (!first) printer << ", ";
        first = false;
        printer.printOperand(index);
      }
      printer << "] : ";
      printer.printType(array.getType());
    } else {
      // Fallback: explicit handle form
      printer.printOperand(handle);
      printer << " : ";
      printer.printType(handle.getType());
    }
  };

  printer << ' ';
  // Print src in sugar if array+index provided; otherwise handle
  if (!getSrcIndices().empty()) {
    printer.printOperand(getSrc());
    printer << '[';
    bool first = true;
    for (Value v : getSrcIndices()) { if (!first) printer << ", "; first = false; printer.printOperand(v); }
    printer << "] : ";
    printer.printType(getSrc().getType());
  } else {
    printHandleWithOptionalIndex(getSrc());
  }
  printer << ' ';
  printer.printAttributeWithoutType(getSrcPortAttr());
  printer << " -> ";
  if (!getDstIndices().empty()) {
    printer.printOperand(getDst());
    printer << '[';
    bool first = true;
    for (Value v : getDstIndices()) { if (!first) printer << ", "; first = false; printer.printOperand(v); }
    printer << "] : ";
    printer.printType(getDst().getType());
  } else {
    printHandleWithOptionalIndex(getDst());
  }
  printer << ' ';
  printer.printAttributeWithoutType(getDstPortAttr());
  if (auto cap = getCapacityAttr()) {
    printer << " capacity(" << cap.getInt() << ")";
  }
  printer.printOptionalAttrDict(getOperation()->getAttrs(),
                                {"srcPort", "dstPort", "capacity",
                                 "operand_segment_sizes", "operandSegmentSizes",
                                 "operand_segment_sizes__", "operandSegmentSizes__"});
}

/// Prints a labeled list of block arguments whose types match a given MLIR
/// type.
///
/// This templated function filters the provided block arguments (`args`) to
/// include only those whose type matches the type `T`. If any matching
/// arguments are found, it prints them under the specified `label`, formatted
/// with indentation and type annotations using the provided `OpAsmPrinter`.
///
/// Template Parameter:
///   T - The MLIR type to filter arguments by (e.g., fifo::InputPortType).
///
/// Parameters:
///   printer - The printer used to emit the formatted output.
///   args    - The list of block arguments to filter and print.
///   label   - A string label (e.g., "ports_in") used as a prefix in the
///             output.
template <typename T>
void collectAndPrintArgumentsByType(OpAsmPrinter &printer,
                                    mlir::Block::BlockArgListType args,
                                    StringRef label) {
  SmallVector<Value> filteredArgs;
  for (Value arg : args) {
    if (mlir::isa<T>(arg.getType())) {
      filteredArgs.push_back(arg);
    }
  }

  if (filteredArgs.size() > 0) {
    printer.printNewline();
    printer << label << " (";
    printer.increaseIndent();
    interleaveComma(filteredArgs, printer, [&](Value v) {
      printer.printNewline();
      printer.printOperand(v);
      printer << ": ";
      printer.printType(v.getType());
    });
    printer.decreaseIndent();
    printer.printNewline();
    printer << ")";
  }
}

/// Parses a list of arguments and checks if they are of the expected port type.
///
/// This templated function attempts to parse a list of arguments specified by
/// the given `keyword`, and ensures that each argument is of the expected port
/// type. If any argument's type does not match the expected `PortType`, an
/// error is emitted with a specified error message.
///
/// Template Parameter:
///   PortType - The type that the arguments are expected to have (e.g.,
///   OutputPortType or InputPortType).
///
/// Parameters:
///   parser   - The OpAsmParser used to parse the arguments.
///   args     - A vector to store the parsed arguments (either `ports_in` or
///              `ports_out`).
///   keyword  - The keyword in the ASM (e.g., "ports_in" or
///              "ports_out") to trigger parsing.
///   errorMsg - The error message to display
///   if any argument doesn't match the expected type.
///
/// Returns:
///   `success` if all arguments are of the expected type; otherwise, `failure`.
template <typename PortType>
ParseResult parseAndCheckPorts(OpAsmParser &parser,
                               SmallVectorImpl<OpAsmParser::Argument> &args,
                               StringRef keyword, StringRef errorMsg) {
  auto location = parser.getCurrentLocation();
  if (succeeded(parser.parseOptionalKeyword(keyword))) {
    if (failed(parser.parseArgumentList(args, OpAsmParser::Delimiter::Paren,
                                        /*allowType=*/true,
                                        /*allowAttrs=*/false)))
      return failure();

    for (auto &arg : args) {
      if (!mlir::isa<PortType>(arg.type)) {
        return parser.emitError(location, errorMsg);
      }
    }
  }
  return success();
}

ParseResult ActorOp::parse(OpAsmParser &parser, OperationState &result) {
  SmallVector<OpAsmParser::Argument> inVals, outVals, standardArgs;

  auto location = parser.getCurrentLocation();

  // Get the symbol name
  mlir::StringAttr symNameAttr;
  if (failed(
          parser.parseSymbolName(symNameAttr, "sym_name", result.attributes)))
    return failure();

  // Get list of arguments if they exist
  if (failed(parser.parseArgumentList(standardArgs,
                                      OpAsmParser::Delimiter::Paren,
                                      /*allowType=*/true,
                                      /*allowAttrs=*/false)))
    return failure();

  // Optionally parse port name attributes before the port lists:
  //   in_names(["in","in1"]) out_names(["out0","out1"]) ports_in(...) ports_out(...)
  // These attributes are stored as ArrayAttr on the op.
  ArrayAttr inNamesParsed;
  ArrayAttr outNamesParsed;
  if (succeeded(parser.parseOptionalKeyword("in_names"))) {
    if (parser.parseAttribute(inNamesParsed)) return failure();
    result.addAttribute("inPortNames", inNamesParsed);
  }
  if (succeeded(parser.parseOptionalKeyword("out_names"))) {
    if (parser.parseAttribute(outNamesParsed)) return failure();
    result.addAttribute("outPortNames", outNamesParsed);
  }

  // Parse the input and output arguments.
  if (failed(parseAndCheckPorts<mlir::fifo::OutputPortType>(
    parser, inVals, "ports_in",
    "expected fifo.output_port<...> for ports_in argument"))) {
    return failure();
  }

  if (failed(parseAndCheckPorts<mlir::fifo::InputPortType>(
    parser, outVals, "ports_out",
    "expected fifo.input_port<...> for ports_out argument"))) {
    return failure();
  }

  // Combine the input and output arguments into a single list
  SmallVector<OpAsmParser::Argument> entryArgs;
  entryArgs.reserve(inVals.size() + outVals.size() + standardArgs.size());
  entryArgs.append(standardArgs.begin(), standardArgs.end());
  entryArgs.append(inVals.begin(), inVals.end());
  entryArgs.append(outVals.begin(), outVals.end());

  // Attach the arguments to the region
  Region &bodyRegion = *result.addRegion();
  if (parser.parseRegion(bodyRegion, entryArgs,
                         /*enableNameShadowing=*/true))
    return failure();

  // Check that the last operations in a region are all of cal.action
  // auto beginIt = bodyRegion.op_begin();
  // auto endIt = bodyRegion.op_end();
  // bool firstActionFound = false;
  // for (auto it = beginIt; it != endIt; ++it) {
  //   Operation &op = *it; // reference to the operation
  //   if (llvm::isa<ActionOp>(op)) {
  //     firstActionFound = true; // first action found
  //   } else {
  //     if (firstActionFound) { // We found a non-action operation after an
  //     action
  //                             // operation
  //       return parser.emitError(
  //           location,
  //           "Expected all cal.action operations in the cal.actor to appear at
  //           " "the end of the region. In this cal.actor, some non-action "
  //           "operations were found after a cal.action operation.");
  //     }
  //   }
  // }

  // Here we perform a few checks to enforce that cal.actor body is formatted
  // how we expect it to be:
  // 1. If the last operation is a cal.execution_body then there can only be
  // one of these operations in the region (it must be last) and there
  // can be no cal.action operations in the actor.
  // 2. cal.action and cal.execution_body are mutually exclusive operations in a
  // cal.actor. If one is present, the other must not be present.
  // 3. cal.action operations must be the last operations in the region.
  auto beginIt = bodyRegion.op_begin();
  auto endIt = bodyRegion.op_end();
  bool executionBodyFound = false;
  bool firstActionFound = false;
  for (auto it = beginIt; it != endIt; ++it) {
    Operation &op = *it; // reference to the operation
    if (llvm::isa<ActionOp>(op)) {
      firstActionFound = true; // first action found
      if (executionBodyFound) {
        return parser.emitError(
            location,
            ". Within a cal.actor, there can either be a single cal.execution "
            "body or one or more cal.actions. Both of the operations may not "
            "appear in the same cal.actor.");
      }
    } else if (llvm::isa<ExecutionBody>(op)) {
      if (executionBodyFound) {
        return parser.emitError(
            location,
            ". The cal.execution_body operation in the cal.actor is "
            "required to be unique and the last operation in the region. You "
            "may not have more than one cal.execution_body in this region");
      }

      if (firstActionFound) {
        return parser.emitError(
            location,
            ". Within a cal.actor, there can either be a single cal.execution "
            "body or one or more cal.actions. Both of the operations may not "
            "appear in the same cal.actor.");
      }
      executionBodyFound = true; // first action found
    } else {
      if (executionBodyFound) { // We found a non-action operation after an
                                // action
                                // operation
        return parser.emitError(
            location, "The cal.execution_body operation in the cal.actor is "
                      "required to be the last operation in the region.");
      }
      if (firstActionFound) { // We found a non-action operation after an action
                              // operation
        return parser.emitError(
            location,
            "expected all cal.action operations in the cal.actor to appear at "
            "the end of the region. In this cal.actor, some non - action "
            "operations were found after a cal.action operation.");
      }
    }
  }

  // Validate provided port-name arrays, if present.
  auto checkNames = [&](ArrayAttr arr, unsigned expect, StringRef which) -> LogicalResult {
    if (!arr) return success();
    if (arr.size() != expect)
      return parser.emitError(location) << which << " name count (" << arr.size()
                                        << ") does not match " << which
                                        << " port count (" << expect << ")";
    llvm::SmallDenseSet<StringRef, 8> seen;
    for (Attribute a : arr) {
      auto s = dyn_cast<StringAttr>(a);
      if (!s || s.getValue().empty())
        return parser.emitError(location) << which << " names must be non-empty strings";
      if (!seen.insert(s.getValue()).second)
        return parser.emitError(location) << which << " names must be unique; duplicate '"
                                          << s.getValue() << "'";
    }
    return success();
  };
  if (failed(checkNames(inNamesParsed, inVals.size(), "input"))) return failure();
  if (failed(checkNames(outNamesParsed, outVals.size(), "output"))) return failure();

  return success();
}

void ActorOp::print(OpAsmPrinter &printer) {
  Operation *op = getOperation();
  auto actorName =
      op->getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName()).getValue();
  printer << ' ';
  printer.printSymbolName(actorName);

  // Separate parameters vs ports.
  SmallVector<Value> params;
  for (Value arg : getBody().getArguments()) {
    if (!mlir::isa<mlir::fifo::OutputPortType>(arg.getType()) &&
        !mlir::isa<mlir::fifo::InputPortType>(arg.getType())) {
      params.push_back(arg);
    }
  }

  printer << '(';
  if (!params.empty()) {
    interleaveComma(params, printer, [&](Value v) {
      printer.printOperand(v);
      printer << ": ";
      printer.printType(v.getType());
    });
  }
  printer << ')';

  printer.increaseIndent();
  // If port names exist, print them before the port groups for readability.
  if (auto inNames = op->getAttrOfType<ArrayAttr>("inPortNames")) {
    printer.printNewline();
    printer << "in_names " << inNames;
  }
  if (auto outNames = op->getAttrOfType<ArrayAttr>("outPortNames")) {
    printer.printNewline();
    printer << "out_names " << outNames;
  }
  collectAndPrintArgumentsByType<mlir::fifo::OutputPortType>(
      printer, getBody().getArguments(), "ports_in");
  collectAndPrintArgumentsByType<mlir::fifo::InputPortType>(
      printer, getBody().getArguments(), "ports_out");
  printer.decreaseIndent();
  printer.printNewline();
  printer.printRegion(getBody(), /*printEntryBlockArgs=*/false,
                      /*printBlockTerminators=*/false);
  printer.printNewline();
}

// Minimal verifier: detailed port-name validation is performed during parse.
LogicalResult ActorOp::verify() { return success(); }

// (Verifier moved into parser for immediate diagnostics when present.)


//===----------------------------------------------------------------------===//
// Cal_NetworkOp (symbolic hierarchical network)
//===----------------------------------------------------------------------===//

ParseResult NetworkOp::parse(OpAsmParser &parser, OperationState &result) {
  SmallVector<OpAsmParser::Argument> inVals, outVals, standardArgs;

  auto location = parser.getCurrentLocation();

  // Parse symbol name @id
  StringAttr symNameAttr;
  if (failed(parser.parseSymbolName(symNameAttr, "sym_name", result.attributes)))
    return failure();

  // Parse parameter list (may be empty but required parens for consistency)
  if (failed(parser.parseArgumentList(standardArgs, OpAsmParser::Delimiter::Paren,
                                      /*allowType=*/true, /*allowAttrs=*/false)))
    return failure();

  // Optionally parse port name attributes before the port lists:
  //   in_names(["in","in1"]) out_names(["out0","out1"]) ports_in(...) ports_out(...)
  // These attributes are stored as ArrayAttr on the op.
  ArrayAttr inNamesParsed;
  ArrayAttr outNamesParsed;
  if (succeeded(parser.parseOptionalKeyword("in_names"))) {
    if (parser.parseAttribute(inNamesParsed)) return failure();
    result.addAttribute("inPortNames", inNamesParsed);
  }
  if (succeeded(parser.parseOptionalKeyword("out_names"))) {
    if (parser.parseAttribute(outNamesParsed)) return failure();
    result.addAttribute("outPortNames", outNamesParsed);
  }

  // Reuse helper for ports
  if (failed(parseAndCheckPorts<mlir::fifo::OutputPortType>(
          parser, inVals, "ports_in",
          "expected fifo.output_port<...> for ports_in argument")))
    return failure();

  if (failed(parseAndCheckPorts<mlir::fifo::InputPortType>(
          parser, outVals, "ports_out",
          "expected fifo.input_port<...> for ports_out argument")))
    return failure();

  // Combine args in canonical order: params, ports_in, ports_out
  SmallVector<OpAsmParser::Argument> entryArgs;
  entryArgs.reserve(standardArgs.size() + inVals.size() + outVals.size());
  entryArgs.append(standardArgs.begin(), standardArgs.end());
  entryArgs.append(inVals.begin(), inVals.end());
  entryArgs.append(outVals.begin(), outVals.end());

  // Optionally parse an attribute dictionary with a keyword for additional markers (e.g., cal.top).
  // Using the keyword avoids ambiguity with the following region '{'.
  (void)parser.parseOptionalAttrDictWithKeyword(result.attributes);

  Region &bodyRegion = *result.addRegion();
  if (parser.parseRegion(bodyRegion, entryArgs, /*enableNameShadowing=*/true))
    return failure();

  // Validate provided port-name arrays, if present, against parsed port counts.
  // Use the location captured earlier at function entry for consistent diagnostics.
  auto checkNames = [&](ArrayAttr arr, unsigned expect, StringRef which) -> LogicalResult {
    if (!arr) return success();
    if (arr.size() != expect)
      return parser.emitError(location) << which << " name count (" << arr.size()
                                        << ") does not match " << which
                                        << " port count (" << expect << ")";
    llvm::SmallDenseSet<StringRef, 8> seen;
    for (Attribute a : arr) {
      auto s = dyn_cast<StringAttr>(a);
      if (!s || s.getValue().empty())
        return parser.emitError(location) << which << " names must be non-empty strings";
      if (!seen.insert(s.getValue()).second)
        return parser.emitError(location) << which << " names must be unique; duplicate '"
                                          << s.getValue() << "'";
    }
    return success();
  };
  if (failed(checkNames(inNamesParsed, inVals.size(), "input"))) return failure();
  if (failed(checkNames(outNamesParsed, outVals.size(), "output"))) return failure();

  // (Future) Verification can enforce only allowed ops / no nested networks yet
  // For now rely on general symbol / operand verification elsewhere.
  (void)location;
  return success();
}

void NetworkOp::print(OpAsmPrinter &printer) {
  Operation *op = getOperation();
  auto netName =
      op->getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName()).getValue();
  printer << ' ';
  printer.printSymbolName(netName);

  // Separate parameters vs ports (similar logic to ActorOp)
  SmallVector<Value> params;
  for (Value arg : getBody().getArguments()) {
    if (!mlir::isa<mlir::fifo::OutputPortType>(arg.getType()) &&
        !mlir::isa<mlir::fifo::InputPortType>(arg.getType())) {
      params.push_back(arg);
    }
  }

  printer << '(';
  if (!params.empty()) {
    interleaveComma(params, printer, [&](Value v) {
      printer.printOperand(v);
      printer << ": ";
      printer.printType(v.getType());
    });
  }
  printer << ')';

  printer.increaseIndent();
  // If port names exist, print them before the port groups for readability.
  if (auto inNames = op->getAttrOfType<ArrayAttr>("inPortNames")) {
    printer.printNewline();
    printer << "in_names " << inNames;
  }
  if (auto outNames = op->getAttrOfType<ArrayAttr>("outPortNames")) {
    printer.printNewline();
    printer << "out_names " << outNames;
  }
  collectAndPrintArgumentsByType<mlir::fifo::OutputPortType>(
      printer, getBody().getArguments(), "ports_in");
  collectAndPrintArgumentsByType<mlir::fifo::InputPortType>(
      printer, getBody().getArguments(), "ports_out");
  printer.decreaseIndent();

  // Print any additional attributes (e.g., cal.top) excluding the ones
  // already spelled structurally or implied by syntax. Use the 'attributes'
  // keyword to keep parsing unambiguous before the region.
  printer.printOptionalAttrDictWithKeyword(op->getAttrs(),
                                           {SymbolTable::getSymbolAttrName(),
                                            "inPortNames", "outPortNames"});

  printer.printNewline();
  printer.printRegion(getBody(), /*printEntryBlockArgs=*/false,
                      /*printBlockTerminators=*/false);
  printer.printNewline();
}

int NetworkOp::inDegree() {
  int portsIn = 0;
  for (Value arg : getBody().getArguments()) {
    if (mlir::isa<mlir::fifo::OutputPortType>(arg.getType()))
      portsIn++;
  }
  return portsIn;
}

int NetworkOp::outDegree() {
  int portsOut = 0;
  for (Value arg : getBody().getArguments()) {
    if (mlir::isa<mlir::fifo::InputPortType>(arg.getType()))
      portsOut++;
  }
  return portsOut;
}

LogicalResult NetworkOp::verify() {
  // Rule 1: Body must have exactly one block (ensured by parser but double-check)
  if (!getBody().hasOneBlock())
    return emitOpError() << "expected network region to have exactly one block";

  // Allowed top-level ops inside a network (structural / instantiation)
  // We allow: fifo.create / print / print_tensor, arith.constant, cal.create_instance,
  // linalg operations (which can be hoisted from actors), tensor operations,
  // other cal.network will appear only as symbol definitions (not nested definitions),
  // but disallow cal.actor definitions inside a network region.
  //static llvm::DenseSet<llvm::StringRef> allowedDialectPrefixes = {
  //    "arith", "fifo", "cal", "linalg", "tensor", "scf"};

  for (Operation &op : getBody().front()) {
    if (llvm::isa<NetworkOp>(op))
      return emitOpError() << "nested cal.network definitions are not allowed; define networks at top module scope";
    if (llvm::isa<ActorOp>(op))
      return emitOpError() << "actor definitions are not permitted inside a cal.network";
    // StringRef dialectNs = op.getDialect()->getNamespace();
    //if (!allowedDialectPrefixes.contains(dialectNs))
    //  return emitOpError() << "operation from unsupported dialect '" << dialectNs << "' inside cal.network";
  }

  return success();
}

//===----------------------------------------------------------------------===//
// cal.interface verifier
//===----------------------------------------------------------------------===//

LogicalResult InterfaceOp::verify() {
  auto inNames = getInPortNamesAttr();
  auto outNames = getOutPortNamesAttr();
  auto inTypes = getInPortTypesAttr();
  auto outTypes = getOutPortTypesAttr();

  // Names must be unique and non-empty when provided.
  if (failed(verifyPortNames(getOperation(), inNames, "input")))
    return failure();
  if (failed(verifyPortNames(getOperation(), outNames, "output")))
    return failure();

  // Types, when provided, must be arrays of TypeAttr of the correct fifo port kinds.
  auto checkTypes = [&](ArrayAttr arr, StringRef which, bool expectInputPorts) -> FailureOr<unsigned> {
    if (!arr)
      return 0u;
    unsigned n = 0;
    for (Attribute a : arr) {
      auto ta = dyn_cast<TypeAttr>(a);
      if (!ta)
        return emitOpError() << which << " port types must be a list of type attributes";
      Type ty = ta.getValue();
      bool ok = expectInputPorts ? isPortTypeOf<mlir::fifo::InputPortType>(ty)
                                 : isPortTypeOf<mlir::fifo::OutputPortType>(ty);
      if (!ok)
        return emitOpError() << which << " port type at index " << n << " must be a "
                             << (expectInputPorts ? "fifo.input_port<...>" : "fifo.output_port<...>");
      ++n;
    }
    return n;
  };

  FailureOr<unsigned> inCount = checkTypes(inTypes, "input", /*expectInputPorts=*/false);
  if (failed(inCount)) return failure();
  FailureOr<unsigned> outCount = checkTypes(outTypes, "output", /*expectInputPorts=*/true);
  if (failed(outCount)) return failure();

  // If names are provided, they must match the type counts.
  auto checkNameCount = [&](ArrayAttr names, unsigned expect, StringRef which) -> LogicalResult {
    if (!names)
      return success();
    if (names.size() != expect) {
      emitOpError() << which << " name count (" << names.size() << ") does not match "
                    << which << " port type count (" << expect << ")";
      return failure();
    }
    return success();
  };
  if (succeeded(inCount) && failed(checkNameCount(inNames, *inCount, "input")))
    return failure();
  if (succeeded(outCount) && failed(checkNameCount(outNames, *outCount, "output")))
    return failure();

  return success();
}

LogicalResult StateGetOp::verify() {
  Type stateValueType = getStateValue().getType();
  Type stateRefType = getStateRef().getType();

  if (!mlir::isa<StateVarRefType>(stateRefType)) {
    return emitOpError() << "expected stateVarRef to be of type "
                            "StateVarRefType (!cal.state_ref<"
                         << stateValueType << ">), but got " << stateRefType;
  }

  StateVarRefType stateRef = mlir::cast<StateVarRefType>(stateRefType);
  if (stateRef.getStateType() != stateValueType) {
    return emitOpError() << "expected stateVarRef state type to be "
                         << stateValueType << ", but got "
                         << stateRef.getStateType();
  }

  return success();
}

LogicalResult StateSetOp::verify() {
  Type stateValueType = getStateValue().getType();
  Type stateRefType = getStateRef().getType();

  if (!mlir::isa<StateVarRefType>(stateRefType)) {
    return emitOpError() << "expected stateVarRef to be of type "
                            "StateVarRefType (!cal.state_ref<"
                         << stateValueType << ">), but got " << stateRefType;
  }

  StateVarRefType stateRef = mlir::cast<StateVarRefType>(stateRefType);
  if (stateRef.getStateType() != stateValueType) {
    return emitOpError() << "expected stateVarRef state type to be "
                         << stateValueType << ", but got "
                         << stateRef.getStateType();
  }

  if (mlir::isa<Predicate>(getOperation()->getParentOp())) {
    return emitOpError() << "cannot modify state variable within cal.predicate";
  }

  return success();
}

LogicalResult CreateStateVarOp::verify() {
  // The result must be a !cal.state_ref<T> and the type parameter must match.
  Type resTy = getStateVarRef().getType();
  if (!mlir::isa<StateVarRefType>(resTy))
    return emitOpError() << "result must be !cal.state_ref<...>, but got "
                         << resTy;

  auto refTy = mlir::cast<StateVarRefType>(resTy);
  Type declared = getStateType();
  if (refTy.getStateType() != declared)
    return emitOpError() << "state_ref element type (" << refTy.getStateType()
                         << ") does not match declared <" << declared << ">";

  // If dynamic sizes are provided, they must match dynamic dims of the state
  // type when it is a memref/tensor. If sizes are provided for a scalar or a
  // fully static shaped type, that is invalid.
  auto sizes = getSizes();
  if (!sizes.empty()) {
    // Only memref or tensor element types can accept dynamic sizes.
    if (auto mt = declared.dyn_cast<MemRefType>()) {
      unsigned expected = mt.getNumDynamicDims();
      if (sizes.size() != expected)
        return emitOpError()
               << "expected " << expected
               << " dynamic size operands for memref type " << mt
               << ", but got " << sizes.size();
    } else if (auto tt = declared.dyn_cast<TensorType>()) {
      unsigned expected = tt.getNumDynamicDims();
      if (sizes.size() != expected)
        return emitOpError()
               << "expected " << expected
               << " dynamic size operands for tensor type " << tt
               << ", but got " << sizes.size();
    } else {
      return emitOpError()
             << "dynamic size operands are only valid for memref/tensor state types";
    }
  } else {
    // No sizes provided. For memref/tensor with dynamic dims, this is still
    // allowed at the dialect level; lowering may require sizes or inference.
    // No further checks here.
  }
  return success();
}

//===----------------------------------------------------------------------===//
// Verifiers for symbolic construction ops
//===----------------------------------------------------------------------===//

LogicalResult InstantiateArrayOp::verify() {
  if (failed(requireNetworkAncestor(getOperation(), "cal.instantiate_array")))
    return failure();
  // Result type must be !cal.instance.array<actorRef, count>
  Type resTy = getHandlesArray().getType();
  auto arrTy = mlir::dyn_cast<InstanceArrayType>(resTy);
  if (!arrTy)
    return emitOpError() << "result must be !cal.instance.array<@Entity, [...]>, got " << resTy;

  // Check actor symbol matches
  if (arrTy.getActorRef() != getActorRefAttr())
    return emitOpError() << "result entity '" << arrTy.getActorRef()
                         << "' does not match attribute '" << getActorRefAttr() << "'";

  // If the result type encodes a static 1-D extent, ensure it matches the count attribute.
  if (auto shapeAttr = arrTy.getShape()) {
    if (shapeAttr.size() == 1) {
      if (auto dimAttr = dyn_cast<IntegerAttr>(shapeAttr[0])) {
        int64_t dim = dimAttr.getInt();
        if (dim >= 0) {
          uint64_t cnt = getCount();
          if (static_cast<int64_t>(cnt) != dim)
            return emitOpError() << "static result type extent [" << dim
                                 << "] does not match count(" << cnt << ")";
        }
      }
    }
  }

  // Base name, if present, must be non-empty
  if (auto bn = getBaseNameAttr(); bn && bn.getValue().empty())
    return emitOpError() << "basename, if provided, must be non-empty";

  // Validate parameter arity/types match the entity's (actor or network) leading non-port parameters.
  SymbolTableCollection symbolTable;
  SmallVector<Type> formalParams;
  if (auto actor = symbolTable.lookupNearestSymbolFrom<ActorOp>(*this, getActorRefAttr())) {
    for (Value a : actor.getBody().getArguments()) {
      Type t = a.getType();
      if (isa<mlir::fifo::OutputPortType>(t) || isa<mlir::fifo::InputPortType>(t))
        break;
      formalParams.push_back(t);
    }
  } else if (auto net = symbolTable.lookupNearestSymbolFrom<NetworkOp>(*this, getActorRefAttr())) {
    for (Value a : net.getBody().getArguments()) {
      Type t = a.getType();
      if (isa<mlir::fifo::OutputPortType>(t) || isa<mlir::fifo::InputPortType>(t))
        break;
      formalParams.push_back(t);
    }
  } else {
    return emitOpError() << "entity symbol '" << getActorRefAttr().getValue() << "' not found";
  }
  auto actuals = getParams();
  if (actuals.size() != formalParams.size()) {
    return emitOpError() << "parameter count mismatch for entity '" << getActorRefAttr().getValue()
                         << "': expected " << formalParams.size() << ", got " << actuals.size();
  }
  for (size_t i = 0; i < actuals.size(); ++i) {
    if (actuals[i].getType() != formalParams[i]) {
      return emitOpError() << "parameter type mismatch at index " << i << ": expected "
                           << formalParams[i] << ", got " << actuals[i].getType();
    }
  }

  return success();
}

//===----------------------------------------------------------------------===//
// cal.instantiate_array canonicalizations
//  - Specialize result type from dynamic ['?'] to static [count] when possible.
//===----------------------------------------------------------------------===//

namespace {
struct SpecializeInstantiateArrayExtent : OpRewritePattern<InstantiateArrayOp> {
  using OpRewritePattern::OpRewritePattern;
  LogicalResult matchAndRewrite(InstantiateArrayOp op, PatternRewriter &rewriter) const override {
    auto arrTy = dyn_cast<InstanceArrayType>(op.getHandlesArray().getType());
    if (!arrTy)
      return failure();
    ArrayAttr shapeAttr = arrTy.getShape();
    if (!shapeAttr || shapeAttr.size() != 1)
      return failure();
    auto dimAttr = dyn_cast<IntegerAttr>(shapeAttr[0]);
    if (!dimAttr || dimAttr.getInt() != -1)
      return failure(); // already static or not the dynamic marker

    uint64_t cnt = op.getCount();
    MLIRContext *ctx = rewriter.getContext();
    auto i64Ty = IntegerType::get(ctx, 64);
    auto newDim = IntegerAttr::get(i64Ty, static_cast<int64_t>(cnt));
    auto newShape = ArrayAttr::get(ctx, ArrayRef<Attribute>{newDim});
    auto newArrTy = InstanceArrayType::get(ctx, arrTy.getActorRef(), newShape);

    auto newOp = rewriter.create<InstantiateArrayOp>(
        op.getLoc(), newArrTy, op.getActorRefAttr(), op.getCountAttr(),
        op.getBaseNameAttr(), op.getParams());
    rewriter.replaceOp(op, newOp.getHandlesArray());
    return success();
  }
};
} // namespace

void InstantiateArrayOp::getCanonicalizationPatterns(RewritePatternSet &patterns,
                                                     MLIRContext *context) {
  patterns.add<SpecializeInstantiateArrayExtent>(context);
}

//===----------------------------------------------------------------------===//
// cal.instance.array.init canonicalizations
//  - Specialize result type from dynamic ['?'] to static [dim] when the
//    provided extent operand is a constant index (1-D case).
//===----------------------------------------------------------------------===//

namespace {
struct SpecializeInstanceArrayInitExtent : OpRewritePattern<InstanceArrayInitOp> {
  using OpRewritePattern::OpRewritePattern;
  LogicalResult matchAndRewrite(InstanceArrayInitOp op, PatternRewriter &rewriter) const override {
    auto resTy = dyn_cast<InstanceArrayType>(op.getArray().getType());
    if (!resTy)
      return failure();
    ArrayAttr shape = resTy.getShape();
    if (!shape || shape.size() != 1)
      return failure();
    auto dimAttr = dyn_cast<IntegerAttr>(shape[0]);
    if (!dimAttr || dimAttr.getInt() != -1)
      return failure(); // already static or not dynamic marker

    // Do not specialize if this init feeds a scf.for iter_arg directly; a later
    // structural pass may unroll and construct a statically-sized array instead.
    for (Operation *user : op.getArray().getUsers()) {
      if (auto forOp = dyn_cast<scf::ForOp>(user)) {
        for (Value init : forOp.getInitArgs()) {
          if (init == op.getArray())
            return failure();
        }
      }
    }

    // Expect exactly one extent operand and it to be a constant index.
    auto dims = op.getDims();
    if (dims.size() != 1)
      return failure();
    auto cst = dims[0].getDefiningOp<arith::ConstantOp>();
    if (!cst)
      return failure();
    auto idx = dyn_cast_or_null<IntegerAttr>(cst.getValue());
    if (!idx)
      return failure();

    MLIRContext *ctx = rewriter.getContext();
    auto i64Ty = IntegerType::get(ctx, 64);
    auto newDim = IntegerAttr::get(i64Ty, idx.getInt());
    auto newShape = ArrayAttr::get(ctx, ArrayRef<Attribute>{newDim});
    auto newArrTy = InstanceArrayType::get(ctx, resTy.getActorRef(), newShape);

    auto newOp = rewriter.create<InstanceArrayInitOp>(op.getLoc(), newArrTy, op.getDims());
    rewriter.replaceOp(op, newOp.getArray());
    return success();
  }
};
} // namespace

void InstanceArrayInitOp::getCanonicalizationPatterns(RewritePatternSet &patterns,
                                                      MLIRContext *context) {
  patterns.add<SpecializeInstanceArrayInitExtent>(context);
  // Loop-promotion of dynamic fills is temporarily disabled due to rewrite
  // ordering issues when replacing ancestor scf.for from a descendant root.
}


// Note: No dedicated getCanonicalizationPatterns hook on InstanceArraySetOp; the
// pattern is registered above via InstanceArrayInitOp to keep this change local.

// Verify that a list of inputs are all instance handles of the same element
// kind and that the provided result array type matches the element and count.
LogicalResult InstanceArrayLiteralOp::verify() {
  if (failed(requireNetworkAncestor(getOperation(), "cal.instance_array.literal")))
    return failure();
  auto inputs = getInputs();
  if (inputs.empty())
    return emitOpError() << "expects at least one input handle";

  // Result must be an instance array (entity or interface typed).
  Type resTy = getArray().getType();
  if (auto entArr = dyn_cast<InstanceArrayType>(resTy)) {
    // All inputs must be !cal.instance<@Actor> with same actor symbol.
    FlatSymbolRefAttr actor = entArr.getActorRef();
    for (Value v : inputs) {
      auto h = dyn_cast<InstanceType>(v.getType());
      if (!h)
        return emitOpError() << "expects all inputs to be !cal.instance<@Actor> for result " << resTy;
      if (h.getActorRef() != actor)
        return emitOpError() << "input actor '" << h.getActorRef().getValue()
                             << "' does not match result actor '" << actor.getValue() << "'";
    }
    return success();
  }

  if (auto ifArr = dyn_cast<InterfaceInstanceArrayType>(resTy)) {
    // All inputs must be !cal.instance.iface<@Iface> with same interface.
    FlatSymbolRefAttr iface = ifArr.getIfaceRef();
    for (Value v : inputs) {
      auto h = dyn_cast<InterfaceInstanceType>(v.getType());
      if (!h)
        return emitOpError() << "expects all inputs to be !cal.instance.iface<@Iface> for result " << resTy;
      if (h.getIfaceRef() != iface)
        return emitOpError() << "input interface '" << h.getIfaceRef().getValue()
                             << "' does not match result interface '" << iface.getValue() << "'";
    }
    return success();
  }

  return emitOpError() << "result must be !cal.instance.array<@Actor,N> or !cal.instance.array.iface<@Iface,N>, got " << resTy;
}

LogicalResult InstanceArrayConcatOp::verify() {
  if (failed(requireNetworkAncestor(getOperation(), "cal.instance_array.concat")))
    return failure();
  Type lhsTy = getLhs().getType();
  Type rhsTy = getRhs().getType();
  Type resTy = getArray().getType();

  if (auto l = dyn_cast<InstanceArrayType>(lhsTy)) {
    auto r = dyn_cast<InstanceArrayType>(rhsTy);
    auto o = dyn_cast<InstanceArrayType>(resTy);
    if (!r || !o)
      return emitOpError() << "both inputs and result must be !cal.instance.array<@Actor,N>";
    if (l.getActorRef() != r.getActorRef() || l.getActorRef() != o.getActorRef())
      return emitOpError() << "actor symbol mismatch across lhs/rhs/result";
    return success();
  }

  if (auto l = dyn_cast<InterfaceInstanceArrayType>(lhsTy)) {
    auto r = dyn_cast<InterfaceInstanceArrayType>(rhsTy);
    auto o = dyn_cast<InterfaceInstanceArrayType>(resTy);
    if (!r || !o)
      return emitOpError() << "both inputs and result must be !cal.instance.array.iface<@Iface,N>";
    if (l.getIfaceRef() != r.getIfaceRef() || l.getIfaceRef() != o.getIfaceRef())
      return emitOpError() << "interface symbol mismatch across lhs/rhs/result";
    return success();
  }

  return emitOpError() << "lhs/rhs must be instance arrays (entity or interface), got "
                       << lhsTy << ", " << rhsTy;
}

LogicalResult InstantiateArrayIfaceOp::verify() {
  if (failed(requireNetworkAncestor(getOperation(), "cal.instantiate_array.iface")))
    return failure();
  // Result type must be !cal.instance.array.iface<@Iface, N>
  Type resTy = getHandlesArray().getType();
  auto arrTy = mlir::dyn_cast<InterfaceInstanceArrayType>(resTy);
  if (!arrTy)
    return emitOpError() << "result must be !cal.instance.array.iface<@Iface, N>, got " << resTy;

  // Check interface symbol exists and matches
  SymbolTableCollection symbolTable;
  if (!symbolTable.lookupNearestSymbolFrom<InterfaceOp>(*this, getIfaceRefAttr()))
    return emitOpError() << "interface symbol '" << getIfaceRefAttr().getValue() << "' not found";

  if (arrTy.getIfaceRef() != getIfaceRefAttr())
    return emitOpError() << "result interface '" << arrTy.getIfaceRef()
                         << "' does not match attribute '" << getIfaceRefAttr() << "'";

  // Note: array shape/count checks are relaxed for ND/dynamic shapes.

  // Params are not currently supported for interface arrays (no concrete entity to validate against)
  if (!getParams().empty())
    return emitOpError() << "parameters are not supported for interface arrays";

  // Base name, if present, must be non-empty
  if (auto bn = getBaseNameAttr(); bn && bn.getValue().empty())
    return emitOpError() << "basename, if provided, must be non-empty";

  return success();
}

LogicalResult InstanceAtOp::verify() {
  if (failed(requireNetworkAncestor(getOperation(), "cal.instance_at")))
    return failure();
  Type arrT = getArray().getType();
  Type hT = getHandle().getType();

  // Two supported pairs:
  //  - !cal.instance.array<@Actor, N>        -> !cal.instance<@Actor>
  //  - !cal.instance.array.iface<@Iface, N>  -> !cal.instance.iface<@Iface>
  if (auto entArr = mlir::dyn_cast<InstanceArrayType>(arrT)) {
    auto entHandle = mlir::dyn_cast<InstanceType>(hT);
    if (!entHandle)
      return emitOpError() << "result must be !cal.instance<@Actor> for entity array operand";
    if (entArr.getActorRef() != entHandle.getActorRef())
      return emitOpError() << "actor mismatch between array and result: "
                           << entArr.getActorRef() << " vs " << entHandle.getActorRef();
    // Verify index rank matches array rank (when shape rank is known).
    if (auto shape = entArr.getShape()) {
      if (getIndices().size() != shape.size())
        return emitOpError() << "expected " << shape.size() << " indices for array rank";
    }
    return success();
  }

  if (auto ifaceArr = mlir::dyn_cast<InterfaceInstanceArrayType>(arrT)) {
    auto ifaceHandle = mlir::dyn_cast<InterfaceInstanceType>(hT);
    if (!ifaceHandle)
      return emitOpError() << "result must be !cal.instance.iface<@Iface> for interface array operand";
    if (ifaceArr.getIfaceRef() != ifaceHandle.getIfaceRef())
      return emitOpError() << "interface mismatch between array and result: "
                           << ifaceArr.getIfaceRef() << " vs " << ifaceHandle.getIfaceRef();

    if (auto shape = ifaceArr.getShape()) {
      if (getIndices().size() != shape.size())
        return emitOpError() << "expected " << shape.size() << " indices for array rank";
    }
    return success();
  }

  return emitOpError() << "array must be !cal.instance.array<@Actor, [...]> or !cal.instance.array.iface<@Iface, [...]>";
}

LogicalResult ConnectOp::verify() {
  if (failed(requireNetworkAncestor(getOperation(), "cal.connect")))
    return failure();
  // Port names must be non-empty.
  if (getSrcPortAttr().getValue().empty() || getDstPortAttr().getValue().empty()) {
    return emitOpError() << "port names must be non-empty";
  }

  // Each side is either a handle (!cal.instance) or an array with index pair,
  // or a network port SSA value: src may be !fifo.output_port<...>, dst may be !fifo.input_port<...>.
  Type srcTy = getSrc().getType();
  Type dstTy = getDst().getType();
  bool srcIsArray = mlir::isa<InstanceArrayType>(srcTy) || mlir::isa<InterfaceInstanceArrayType>(srcTy);
  bool dstIsArray = mlir::isa<InstanceArrayType>(dstTy) || mlir::isa<InterfaceInstanceArrayType>(dstTy);
  bool srcIsHandle = mlir::isa<InstanceType>(srcTy) || mlir::isa<InterfaceInstanceType>(srcTy);
  bool dstIsHandle = mlir::isa<InstanceType>(dstTy) || mlir::isa<InterfaceInstanceType>(dstTy);
  bool srcIsNetOut = mlir::isa<mlir::fifo::OutputPortType>(srcTy);
  bool dstIsNetIn = mlir::isa<mlir::fifo::InputPortType>(dstTy);

  if (srcIsArray) {
    if (getSrcIndices().empty())
      return emitOpError() << "source is array but indices are missing (use 'handle[idx0,...]' or pass --allow-dynamic-indices to defer)";
  } else if (!srcIsHandle && !srcIsNetOut) {
    return emitOpError() << "source must be !cal.instance, !cal.instance.array[index], or !fifo.output_port<...>";
  } else if (!getSrcIndices().empty() && !srcIsArray) {
    return emitOpError() << "source index provided but source is not an array";
  }

  if (dstIsArray) {
    if (getDstIndices().empty())
      return emitOpError() << "destination is array but indices are missing (use 'handle[idx0,...]' or pass --allow-dynamic-indices to defer)";
  } else if (!dstIsHandle && !dstIsNetIn) {
    return emitOpError() << "destination must be !cal.instance, !cal.instance.array[index], or !fifo.input_port<...>";
  } else if (!getDstIndices().empty() && !dstIsArray) {
    return emitOpError() << "destination index provided but destination is not an array";
  }

  // Disallow network-to-network connect for now (no elaboration support).
  if (srcIsNetOut && dstIsNetIn)
    return emitOpError() << "connecting a network port to a network port is not supported";

  // Optional capacity must be non-negative if present.
  if (auto cap = getCapacityAttr()) {
    if (cap.getInt() < 0)
      return emitOpError() << "capacity, if provided, must be >= 0";
  }
  return success();
}

LogicalResult CreateInstanceOp::verifySymbolUses(
    SymbolTableCollection &symbolTable) {
  FlatSymbolRefAttr targetRef = getActorRefAttr();

  // Try resolve as Actor first
  if (auto actor =
          symbolTable.lookupNearestSymbolFrom<ActorOp>(*this, targetRef)) {
    auto formalArgs = actor.getBody().getArguments();
    auto actuals = getOperands();
    // Fast fail on count mismatch with focused diagnostic.
    if (actuals.size() != formalArgs.size()) {
      return emitOpError()
             << "operand count mismatch: expected " << formalArgs.size()
             << " operands (actor params+ports), but got " << actuals.size();
    }
    for (size_t i = 0; i < actuals.size(); ++i) {
      if (actuals[i].getType() != formalArgs[i].getType()) {
        return emitOpError()
               << "operand type mismatch for operand " << i << ": expected "
               << formalArgs[i].getType() << ", but got "
               << actuals[i].getType();
      }
    }
    return success();
  }

  // Try resolve as Network next
  if (auto network =
          symbolTable.lookupNearestSymbolFrom<NetworkOp>(*this, targetRef)) {
    auto formalArgs = network.getBody().getArguments();
    auto actuals = getOperands();
    if (actuals.size() != formalArgs.size()) {
      return emitOpError()
             << "operand count mismatch: expected " << formalArgs.size()
             << " operands (network params+ports), but got " << actuals.size();
    }
    for (size_t i = 0; i < actuals.size(); ++i) {
      if (actuals[i].getType() != formalArgs[i].getType()) {
        return emitOpError()
               << "operand type mismatch for operand " << i << ": expected "
               << formalArgs[i].getType() << ", but got "
               << actuals[i].getType();
      }
    }
    return success();
  }

  return emitOpError() << "'" << targetRef.getValue()
                       << "' does not reference a valid cal.actor or cal.network";
}

/// Prints a labeled group of operands along with their types in a structured
/// format.
///
/// This function outputs a group of operands under a specified label (e.g.,
/// "ports_in", "ports_out"), formatting them as follows:
///
///   label (%operand1, %operand2, ...) : type1, type2, ...
///
/// If the operand list is empty, the function performs no action.
///
/// Parameters:
/// - `printer`: The MLIR assembly printer used to emit the output.
/// - `label`: A string label describing the operand group.
/// - `operands`: The list of operands to be printed.
///
/// Behavior:
/// - Outputs a newline followed by the label and an opening parenthesis.
/// - Prints the operands as a comma-separated list.
/// - Prints a colon followed by the types of each operand, also as a
/// comma-separated list.
/// - Closes the group with a closing parenthesis.
///
/// Example Output:
///   ports_in (%in1, %in2 : !fifo.output_port<i32>, !fifo.output_port<f32>)
void printOperandGroup(OpAsmPrinter &printer, StringRef label,
                       ArrayRef<Value> operands) {
  if (operands.empty())
    return;
  printer.printNewline();
  printer << label << " (";
  printer.printOperands(operands);
  printer << " : ";
  llvm::interleaveComma(operands, printer,
                        [&](Value v) { printer.printType(v.getType()); });
  printer << ")";
}

void CreateInstanceOp::print(OpAsmPrinter &printer) {
  // 1. Print the symbol name
  printer << " ";
  printer.printSymbolName(getActorRefAttr().getValue());

  // 2. Print the optional instance name if it exists
  if (getInstanceNameAttr()) {
    printer << " ";
    printer.printString(getInstanceNameAttr().getValue());
    printer << " ";
  }

  // 3. Print the optional device affinity if it exists
  if (getDeviceAffinityAttr()) {
    printer << " ";
    printer << "device_affinity=";
    printer.printString(getDeviceAffinityAttr().getValue());
    printer << " ";
  }

  // 4. Sort the operands according to if they are ports or not
  SmallVector<Value> portsOut, portsIn, others;
  for (Value operand : getOperands()) {
    Type type = operand.getType();
    if (mlir::isa<fifo::InputPortType>(type))
      portsOut.push_back(operand);
    else if (mlir::isa<fifo::OutputPortType>(type))
      portsIn.push_back(operand);
    else
      others.push_back(operand);
  }

  // 3.1 Print out the standard operands
  printer << "(";
  if (!others.empty()) {
    printer.printOperands(others);
    printer << " : ";
    llvm::interleaveComma(others, printer,
                          [&](Value v) { printer.printType(v.getType()); });
  }
  printer << ")";

  printer.increaseIndent();
  printer.increaseIndent();
  // 3.2 Print out the ports_in
  printOperandGroup(printer, "ports_in", portsIn);
  // 3.3 Print out the ports_in
  printOperandGroup(printer, "ports_out", portsOut);
  printer.decreaseIndent();
  printer.decreaseIndent();
}

/// Parses an optional operand group with an associated type list and
/// validates each type against a provided constraint.
///
/// This function attempts to parse a group of operands prefixed by a specific
/// keyword (e.g., "ports_in", "ports_out"). The expected syntax is:
///
///   keyword (%operand1, %operand2, ...) : type1, type2, ...
///
/// - If the keyword is present:
///   - Parses the operand list enclosed in parentheses.
///   - If operands are present:
///     - Parses a colon followed by a comma-separated list of types.
///     - Validates each type using the provided `typeConstraint` function.
///   - Parses the closing parenthesis.
///
/// Parameters:
/// - `parser`: The MLIR assembly parser.
/// - `keyword`: The keyword indicating the start of the operand group.
/// - `operands`: Output vector to store the parsed operands.
/// - `types`: Output vector to store the parsed types.
/// - `typeConstraint`: A function that returns true if a type is valid.
/// - `typeConstraintMsg`: Error message to emit if a type fails validation.
///
/// Returns:
/// - `success()` if parsing and validation succeed.
/// - `failure()` if any parsing step fails or a type does not satisfy the
/// constraint.
static ParseResult
parseOperandGroup(OpAsmParser &parser, StringRef keyword,
                  SmallVectorImpl<OpAsmParser::UnresolvedOperand> &operands,
                  SmallVectorImpl<Type> &types,
                  llvm::function_ref<bool(Type)> typeConstraint,
                  StringRef typeConstraintMsg) {
  auto location = parser.getCurrentLocation();
  if (succeeded(parser.parseOptionalKeyword(keyword))) {
    if (failed(parser.parseLParen()) ||
        failed(parser.parseOperandList(operands, OpAsmParser::Delimiter::None)))
      return failure();

    if (!operands.empty()) {
      if (failed(parser.parseColon()) || failed(parser.parseTypeList(types)))
        return failure();
      for (Type &type : types) {
        if (!typeConstraint(type))
          return parser.emitError(location, typeConstraintMsg);
      }
    }
    if (failed(parser.parseRParen()))
      return failure();
  }
  return success();
}

ParseResult CreateInstanceOp::parse(OpAsmParser &parser,
                                    OperationState &result) {

  // 1. Parse the symbol name
  FlatSymbolRefAttr actorRef;
  if (failed(parser.parseAttribute<FlatSymbolRefAttr>(
          actorRef, /*type=*/{}, "actorRef", result.attributes)))
    return failure();

  // 2. Parse the optional instance name if it exists
  std::string instance_name;
  if (succeeded(parser.parseOptionalString(&instance_name))) {
    result.addAttribute("instanceName",
                        parser.getBuilder().getStringAttr(instance_name));
  }

  // 3. Parse the optional cpu_affinity if it exists
  if (succeeded(parser.parseOptionalKeyword("device_affinity"))) {
    if (failed(parser.parseEqual()))
      return failure();

    std::string cpu_affinity;
    if (failed(parser.parseString(&cpu_affinity)))
      return failure();

    result.addAttribute("deviceAffinity",
                        parser.getBuilder().getStringAttr(cpu_affinity));
  }

  if (failed(parser.parseLParen()))
    return failure();

  // 4. Parse standard operands
  SmallVector<OpAsmParser::UnresolvedOperand> standardOperands;
  SmallVector<Type> standardTypes;
  if (failed(parser.parseOperandList(standardOperands,
                                     OpAsmParser::Delimiter::None)))
    return failure();

  if (!standardOperands.empty()) {
    if (failed(parser.parseColon()) ||
        failed(parser.parseTypeList(standardTypes)))
      return failure();
    for (Type &type : standardTypes) {
      if (mlir::isa<fifo::InputPortType>(type) ||
          mlir::isa<fifo::OutputPortType>(type))
        return parser.emitError(parser.getCurrentLocation(),
                                "standard arguments may not include fifo "
                                "input/output port types");
    }
  }

  if (failed(parser.parseRParen()))
    return failure();

  // 4. Parse ports_in
  SmallVector<OpAsmParser::UnresolvedOperand> portsIn;
  SmallVector<Type> portsInTypes;
  if (failed(parseOperandGroup(
    parser, "ports_in", portsIn, portsInTypes,
    [](Type t) { return mlir::isa<fifo::OutputPortType>(t); },
    "expected fifo.output_port<...> for ports_in argument")))
    return failure();

  // 5. Parse ports_out
  SmallVector<OpAsmParser::UnresolvedOperand> portsOut;
  SmallVector<Type> portsOutTypes;
  if (failed(parseOperandGroup(
    parser, "ports_out", portsOut, portsOutTypes,
    [](Type t) { return mlir::isa<fifo::InputPortType>(t); },
    "expected fifo.input_port<...> for ports_out argument")))
    return failure();

  // 6. Combine all operands and assign them to the result so that they can be
  // be used to constuct the operation
  SmallVector<OpAsmParser::UnresolvedOperand> allOperands;
  SmallVector<Type> allTypes;
  allOperands.append(standardOperands);
  allOperands.append(portsIn);
  allOperands.append(portsOut);
  allTypes.append(standardTypes);
  allTypes.append(portsInTypes);
  allTypes.append(portsOutTypes);

  return parser.resolveOperands(allOperands, allTypes, parser.getNameLoc(),
                                result.operands);
}

ParseResult ActionOp::parse(OpAsmParser &parser, OperationState &result) {
  // Optional string: actionName
  std::string action_name;
  if (succeeded(parser.parseOptionalString(&action_name))) {
    result.addAttribute("actionName",
                        parser.getBuilder().getStringAttr(action_name));
  }

  // Optional keyword "priority = <int>"
  if (succeeded(parser.parseOptionalKeyword("priority"))) {
    IntegerAttr priorityAttr;
    if (parser.parseEqual() ||
        parser.parseAttribute(priorityAttr, parser.getBuilder().getI32Type(),
                              "priority", result.attributes))
      return failure();
  }

  Region *body = result.addRegion();
  if (parser.parseRegion(*body, /*arguments=*/{}, /*argTypes=*/{}))
    return failure();

  return success();
}

void ActionOp::print(OpAsmPrinter &printer) {
  if (getActionNameAttr()) {
    printer << " ";
    printer.printString(getActionNameAttr().getValue());

  }

  if (getPriorityAttr()) {
    printer << " priority=" << getPriorityAttr().getValue();
  }

  printer.printNewline();
  printer.printRegion(getBody(), /*printEntryBlockArgs=*/false,
                      /*printBlockTerminators=*/false);
  printer.printNewline();
}

/// Verifies that the operations inside a `cal.action` body follow the correct
/// ordering constraints.
///
/// The expected ordering is:
///   1. `cal.predicate` operations
///   2. `fifo.pop` operations
///   3. `cal.set` (state update) operations
///   4. `fifo.push` operations
///
/// The function walks through the body of the `cal.action` block and enforces
/// that:
/// - All `cal.predicate` ops appear before any `fifo.pop`, `cal.set`, or
///   `fifo.push` ops.
/// - All `fifo.pop` ops appear before any `cal.set` or `fifo.push` ops.
/// - All `cal.set` ops appear before any `fifo.push` ops.
/// - `fifo.push` ops can only appear after all others.
///
/// If any of these constraints are violated, an error is emitted for the
/// `cal.action` operation.

LogicalResult ActionOp::verify() {
  enum Phase { predicateOps = 0, popOps = 1, setStateOps = 2, pushOps = 3 };

  Phase currentPhase = predicateOps;

  if (!getBody().empty()) {
    for (Operation &op : getBody().front()) {
      if (mlir::isa<cal::Predicate>(op)) {
        if (currentPhase > predicateOps) {
          return emitOpError()
                 << "cal.predicate operations must be before fifo.pop, "
                    "cal.set, and fifo.push operations in the body of the "
                    "cal.action";
        }
        currentPhase = predicateOps;
      } else if (mlir::isa<fifo::Pop>(op)) {
        if (currentPhase > popOps) {
          return emitOpError()
                 << "fifo.pop operations must be before cal.set and "
                    "fifo.push operations and after cal.predicate operations "
                    "in the body of the cal.action";
        }
        currentPhase = popOps;
      } else if (mlir::isa<cal::StateSetOp>(op)) {
        if (currentPhase > setStateOps) {
          return emitOpError()
                 << "cal.set operations must be after fifo.pop and "
                    "cal.predicate operations and before fifo.push operations "
                    "in the body of the cal.action";
        }
        currentPhase = setStateOps;
      } else if (mlir::isa<fifo::Push>(op)) {
        if (currentPhase > pushOps) {
          return emitOpError()
                 << "fifo.push operations must be the last operations "
                    "in the the body of the cal.action";
        }
        currentPhase = pushOps;
      }
    }
  }

  return success();
}

llvm::MapVector<mlir::Value, int> ActionOp::getPortRates() {

  llvm::MapVector<mlir::Value, int> portRates;
  for (auto pushOp : getOps<fifo::Push>()) {
    portRates[pushOp.getInputPort()] += 1;
  }

  for (auto popOp : getOps<fifo::Pop>()) {
    portRates[popOp.getOutputPort()] -= 1;
  }
  return portRates;
}

int ActorOp::inDegree() {
  int portsIn = 0;
  for (Value arg : getBody().getArguments()) {
    if (mlir::isa<mlir::fifo::OutputPortType>(arg.getType())) {
      portsIn++;
    }
  }
  return portsIn;
}

int ActorOp::outDegree() {
  int portsOut = 0;
  for (Value arg : getBody().getArguments()) {
    if (mlir::isa<mlir::fifo::InputPortType>(arg.getType())) {
      portsOut++;
    }
  }
  return portsOut;
}

bool ActorOp::isSimpleActor() {
  if (inDegree() != 1) {
    return false; // Need to have 1 port in to be a simple actor
  }

  if (outDegree() != 1) {
    return false; // Need to have 1 port out to be a simple actor
  }

  int actionCount = 0;
  cal::ActionOp savedActionOp;
  for (Operation &op : getBody().getOps()) {
    if (auto actionOp = llvm::dyn_cast<ActionOp>(&op)) {
      actionCount++;
      savedActionOp = actionOp;
    }
  }

  if (actionCount != 1) {
    return false; // Need to have exactly one action in the actor to be a simple
                  // actor
  }

  // Check that all port rates are either +1 or -1
  llvm::MapVector<mlir::Value, int> portRates = savedActionOp.getPortRates();
  for (const auto &entry : portRates) {
    int rate = entry.second;
    if (rate != 1 && rate != -1) {
      return false; // Port rate must be exactly +1 or -1 for a simple actor
    }
  }

  // (no predicate count needed here)
  for (Operation &op : savedActionOp.getBody().getOps()) {
    if (llvm::isa<cal::Predicate>(op)) {
      return false; // If any predicate is present in the action body, it is not
                    // a simple actor
    }
  }

  return true;
}

cal::ActorOp CreateInstanceOp::getActor() {
  FlatSymbolRefAttr actorRef = getActorRefAttr();
  SymbolTableCollection symbolTable;
  ActorOp actor = symbolTable.lookupNearestSymbolFrom<ActorOp>(*this, actorRef);
  if (!actor) {
    emitOpError() << "'" << actorRef.getValue()
                  << "' does not reference a valid cal.actor";
    return nullptr;
  }
  return actor;
}

//===----------------------------------------------------------------------===//
// cal.instance.cast verifier and canonicalization
//===----------------------------------------------------------------------===//

LogicalResult InstanceCastOp::verify() {
  if (failed(requireNetworkAncestor(getOperation(), "cal.instance.cast")))
    return failure();
  Type inTy = getInput().getType();
  Type outTy = getOutput().getType();
  auto entTy = dyn_cast<InstanceType>(inTy);
  auto ifTy  = dyn_cast<InterfaceInstanceType>(outTy);
  if (!entTy || !ifTy)
    return emitOpError() << "expected cast from !cal.instance<@E> to !cal.instance.iface<@I>";

  // Verify that entity implements the interface in the nearest symbol table scope.
  SymbolTableCollection symbolTable;
  auto ifaceSym = ifTy.getIfaceRef();
  auto entSym = entTy.getActorRef();
  // Walk for a matching cal.implements @Iface for @Entity
  Operation *scope = SymbolTable::getNearestSymbolTable(getOperation());
  if (!scope)
    scope = getOperation()->getParentOfType<ModuleOp>();
  bool found = false;
  if (scope) {
    scope->walk([&](ImplementsOp impl) {
      if (impl.getIfaceRefAttr() == ifaceSym && impl.getEntityRefAttr() == entSym)
        found = true;
    });
  }
  if (!found)
    return emitOpError() << "entity '" << entSym.getValue() << "' does not implement interface '"
                         << ifaceSym.getValue() << "'";
  return success();
}

namespace {
struct FoldIdentityInstanceCast : OpRewritePattern<InstanceCastOp> {
  using OpRewritePattern::OpRewritePattern;
  LogicalResult matchAndRewrite(InstanceCastOp op, PatternRewriter &rewriter) const override {
    if (op.getInput().getType() == op.getOutput().getType()) {
      rewriter.replaceOp(op, op.getInput());
      return success();
    }
    return failure();
  }
};
} // namespace

void InstanceCastOp::getCanonicalizationPatterns(RewritePatternSet &patterns,
                                                 MLIRContext *ctx) {
  patterns.add<FoldIdentityInstanceCast>(ctx);
}

// Verify symbol uses for cal.implements. Ensures that the referenced
// interface exists and that the entity refers to either a cal.actor or
// cal.network symbol in the nearest symbol table.
LogicalResult ImplementsOp::verifySymbolUses(SymbolTableCollection &symbolTable) {
  FlatSymbolRefAttr ifaceRef = getIfaceRefAttr();
  FlatSymbolRefAttr entityRef = getEntityRefAttr();

  // Interface must resolve to a cal.interface symbol.
  if (!symbolTable.lookupNearestSymbolFrom<InterfaceOp>(*this, ifaceRef)) {
    return emitOpError() << "interface '" << ifaceRef.getValue()
                         << "' not found in nearest symbol table";
  }

  // Entity must resolve to either a cal.actor or cal.network.
  bool isActor = symbolTable.lookupNearestSymbolFrom<ActorOp>(*this, entityRef);
  bool isNetwork = symbolTable.lookupNearestSymbolFrom<NetworkOp>(*this, entityRef);
  if (!isActor && !isNetwork) {
    return emitOpError() << "entity '" << entityRef.getValue()
                         << "' does not reference a cal.actor or cal.network";
  }

  // Conformance check: if the interface declares port types, the entity must
  // match arity and port types (direction and element type) positionally.
  auto iface = symbolTable.lookupNearestSymbolFrom<InterfaceOp>(*this, ifaceRef);
  if (!iface)
    return emitOpError() << "internal error: interface symbol resolved earlier disappeared";

  auto inTypesAttr = iface.getInPortTypesAttr();
  auto outTypesAttr = iface.getOutPortTypesAttr();
  auto inNamesAttr = iface.getInPortNamesAttr();
  auto outNamesAttr = iface.getOutPortNamesAttr();
  unsigned ifaceInCount = inTypesAttr ? static_cast<unsigned>(inTypesAttr.size()) : 0u;
  unsigned ifaceOutCount = outTypesAttr ? static_cast<unsigned>(outTypesAttr.size()) : 0u;
  if (ifaceInCount == 0 && ifaceOutCount == 0)
    return success(); // Nothing declared to check.

  // Helper to extract port argument types from an entity (actor or network).
  auto extractEntityPortTypes = [](auto entityOp,
                                  SmallVectorImpl<Type> &inPortTypes,
                                  SmallVectorImpl<Type> &outPortTypes) {
    for (Value arg : entityOp.getBody().getArguments()) {
      Type t = arg.getType();
      if (auto outTy = dyn_cast<mlir::fifo::OutputPortType>(t))
        inPortTypes.push_back(outTy);
      else if (auto inTy = dyn_cast<mlir::fifo::InputPortType>(t))
        outPortTypes.push_back(inTy);
    }
  };

  SmallVector<Type> entIn, entOut;
  ArrayAttr entInNames, entOutNames;
  if (auto actor = symbolTable.lookupNearestSymbolFrom<ActorOp>(*this, entityRef)) {
    extractEntityPortTypes(actor, entIn, entOut);
    entInNames = actor->getAttrOfType<ArrayAttr>("inPortNames");
    entOutNames = actor->getAttrOfType<ArrayAttr>("outPortNames");
  } else if (auto net = symbolTable.lookupNearestSymbolFrom<NetworkOp>(*this, entityRef)) {
    extractEntityPortTypes(net, entIn, entOut);
    entInNames = net->getAttrOfType<ArrayAttr>("inPortNames");
    entOutNames = net->getAttrOfType<ArrayAttr>("outPortNames");
  }

  auto typeFromArray = [](ArrayAttr arr, unsigned idx) -> Type {
    if (!arr) return Type();
    if (idx >= arr.size()) return Type();
    if (auto ta = dyn_cast<TypeAttr>(arr[idx])) return ta.getValue();
    return Type();
  };

  bool ok = true;
  std::string msg;

  if (entIn.size() != ifaceInCount) {
    ok = false;
    msg += "input port count mismatch: expected ";
    msg += std::to_string(ifaceInCount);
    msg += ", got ";
    msg += std::to_string(entIn.size());
    msg += "; ";
  }
  if (entOut.size() != ifaceOutCount) {
    ok = false;
    msg += "output port count mismatch: expected ";
    msg += std::to_string(ifaceOutCount);
    msg += ", got ";
    msg += std::to_string(entOut.size());
    msg += "; ";
  }

  // Per-port type compatibility when counts are equal.
  if (ok) {
    for (unsigned i = 0; i < ifaceInCount; ++i) {
      Type ifaceTy = typeFromArray(inTypesAttr, i);
      if (!ifaceTy || entIn[i] != ifaceTy) {
        ok = false;
        msg += "input port["; msg += std::to_string(i); msg += "] type mismatch; ";
      }
    }
    for (unsigned i = 0; i < ifaceOutCount; ++i) {
      Type ifaceTy = typeFromArray(outTypesAttr, i);
      if (!ifaceTy || entOut[i] != ifaceTy) {
        ok = false;
        msg += "output port["; msg += std::to_string(i); msg += "] type mismatch; ";
      }
    }
  }

  if (!ok) {
    return emitOpError() << "entity '" << entityRef.getValue()
                         << "' does not conform to interface '" << ifaceRef.getValue()
                         << "': " << msg;
  }

  // Optional name conformance: if the interface specifies port names and the
  // entity also provides names (via in_names/out_names), require exact
  // positional match for clearer wiring and better diagnostics.
  auto checkNames = [&](ArrayAttr ifaceNames, ArrayAttr entNames, unsigned expect, StringRef which) -> LogicalResult {
    if (!ifaceNames)
      return success(); // nothing to check
    if (!entNames)
      return success(); // be permissive if entity didn't declare names
    if (entNames.size() != expect) {
      return emitOpError() << which << " port name count (" << entNames.size()
                           << ") does not match expected " << expect;
    }
    for (unsigned i = 0; i < expect; ++i) {
      auto ifaceNm = dyn_cast<StringAttr>(ifaceNames[i]);
      auto entNm = dyn_cast<StringAttr>(entNames[i]);
      if (!ifaceNm || !entNm || ifaceNm.getValue() != entNm.getValue()) {
        return emitOpError() << which << " port[" << i << "] name mismatch: expected '"
                             << (ifaceNm ? ifaceNm.getValue() : StringRef(""))
                             << "', got '"
                             << (entNm ? entNm.getValue() : StringRef("")) << "'";
      }
    }
    return success();
  };

  if (failed(checkNames(inNamesAttr, entInNames, ifaceInCount, "input")))
    return failure();
  if (failed(checkNames(outNamesAttr, entOutNames, ifaceOutCount, "output")))
    return failure();

  return success();
}

// NOTE: verification for future array/connect ops will be added once those
// ops are fully integrated via TableGen generation.

// Legacy cal.instance_if op was removed; custom parser/printer/verifier and
// canonicalization patterns have been deleted accordingly.

//===----------------------------------------------------------------------===//
// Algebraic Type Operations - Verifiers
//===----------------------------------------------------------------------===//

// Helper to find a variant descriptor by name in a VariantType
static std::optional<DictionaryAttr>
findVariantByName(VariantType variantType, StringRef variantName) {
  for (Attribute attr : variantType.getVariants()) {
    auto variantDict = mlir::dyn_cast<DictionaryAttr>(attr);
    if (!variantDict)
      continue;
    auto nameAttr = variantDict.getAs<StringAttr>("name");
    if (nameAttr && nameAttr.getValue() == variantName)
      return variantDict;
  }
  return std::nullopt;
}

// Helper to get the field types for a variant
static SmallVector<Type>
getVariantFieldTypes(DictionaryAttr variantDict) {
  SmallVector<Type> fieldTypes;
  auto fieldsAttr = variantDict.getAs<ArrayAttr>("fields");
  if (!fieldsAttr)
    return fieldTypes;
  for (Attribute fieldAttr : fieldsAttr) {
    if (auto typeAttr = mlir::dyn_cast<TypeAttr>(fieldAttr))
      fieldTypes.push_back(typeAttr.getValue());
  }
  return fieldTypes;
}

// Helper to find the index of a variant by name (for future use by lowering passes)
[[maybe_unused]] static std::optional<int64_t>
findVariantIndex(VariantType variantType, StringRef variantName) {
  int64_t index = 0;
  for (Attribute attr : variantType.getVariants()) {
    auto variantDict = mlir::dyn_cast<DictionaryAttr>(attr);
    if (!variantDict) {
      ++index;
      continue;
    }
    auto nameAttr = variantDict.getAs<StringAttr>("name");
    if (nameAttr && nameAttr.getValue() == variantName)
      return index;
    ++index;
  }
  return std::nullopt;
}

// Helper to find a field by name in a ProductType
static std::optional<std::pair<int64_t, Type>>
findProductFieldByName(ProductType productType, StringRef fieldName) {
  int64_t index = 0;
  for (Attribute attr : productType.getFields()) {
    auto fieldDict = mlir::dyn_cast<DictionaryAttr>(attr);
    if (!fieldDict) {
      ++index;
      continue;
    }
    auto nameAttr = fieldDict.getAs<StringAttr>("name");
    auto typeAttr = fieldDict.getAs<TypeAttr>("type");
    if (nameAttr && nameAttr.getValue() == fieldName && typeAttr)
      return std::make_pair(index, typeAttr.getValue());
    ++index;
  }
  return std::nullopt;
}

LogicalResult VariantCreateOp::verify() {
  auto variantType = mlir::cast<VariantType>(getResult().getType());
  StringRef variantName = getVariantName();

  // Find the variant descriptor
  auto variantDict = findVariantByName(variantType, variantName);
  if (!variantDict) {
    return emitOpError() << "variant '" << variantName << "' not found in type '"
                         << variantType.getName() << "'";
  }

  // Get expected field types
  auto expectedFieldTypes = getVariantFieldTypes(*variantDict);

  // Check arity
  if (getFields().size() != expectedFieldTypes.size()) {
    return emitOpError() << "variant '" << variantName << "' expects "
                         << expectedFieldTypes.size() << " field(s), but got "
                         << getFields().size();
  }

  // Check field types
  for (auto [idx, pair] : llvm::enumerate(llvm::zip(getFields(), expectedFieldTypes))) {
    auto [field, expectedType] = pair;
    if (field.getType() != expectedType) {
      return emitOpError() << "variant '" << variantName << "' field " << idx
                           << " expects type " << expectedType << ", but got "
                           << field.getType();
    }
  }

  return success();
}

LogicalResult VariantGetFieldOp::verify() {
  auto variantType = mlir::cast<VariantType>(getVariant().getType());
  StringRef variantName = getVariantName();
  int64_t fieldIndex = getFieldIndex();

  // Find the variant descriptor
  auto variantDict = findVariantByName(variantType, variantName);
  if (!variantDict) {
    return emitOpError() << "variant '" << variantName << "' not found in type '"
                         << variantType.getName() << "'";
  }

  // Get field types for this variant
  auto fieldTypes = getVariantFieldTypes(*variantDict);

  // Check field index bounds
  if (fieldIndex < 0 || static_cast<size_t>(fieldIndex) >= fieldTypes.size()) {
    return emitOpError() << "field index " << fieldIndex << " out of bounds for variant '"
                         << variantName << "' which has " << fieldTypes.size() << " field(s)";
  }

  // Check result type matches
  Type expectedType = fieldTypes[fieldIndex];
  if (getResult().getType() != expectedType) {
    return emitOpError() << "result type " << getResult().getType()
                         << " does not match field " << fieldIndex << " type "
                         << expectedType << " in variant '" << variantName << "'";
  }

  return success();
}

LogicalResult VariantMatchOp::verify() {
  auto variantType = mlir::cast<VariantType>(getVariant().getType());
  size_t numVariants = variantType.getVariants().size();

  // Check that we have exactly one region per variant
  if (getCases().size() != numVariants) {
    return emitOpError() << "expected " << numVariants << " case region(s) for variant type '"
                         << variantType.getName() << "', but got " << getCases().size();
  }

  // Verify each case region
  for (auto [idx, region] : llvm::enumerate(getCases())) {
    if (!region.hasOneBlock()) {
      return emitOpError() << "case region " << idx << " must have exactly one block";
    }

    // Get the expected variant for this case
    auto variantDict = mlir::cast<DictionaryAttr>(variantType.getVariants()[idx]);
    auto fieldTypes = getVariantFieldTypes(variantDict);

    // Check block argument count and types
    Block &caseBlock = region.front();
    if (caseBlock.getNumArguments() != fieldTypes.size()) {
      return emitOpError() << "case region " << idx << " expects "
                           << fieldTypes.size() << " block argument(s), but got "
                           << caseBlock.getNumArguments();
    }

    for (auto [argIdx, pair] : llvm::enumerate(
             llvm::zip(caseBlock.getArguments(), fieldTypes))) {
      auto [arg, expectedType] = pair;
      if (arg.getType() != expectedType) {
        return emitOpError() << "case region " << idx << " argument " << argIdx
                             << " expects type " << expectedType << ", but got "
                             << arg.getType();
      }
    }

    // Check that the region terminates with variant.yield
    if (caseBlock.empty()) {
      return emitOpError() << "case region " << idx << " is empty";
    }
    auto terminator = dyn_cast<VariantYieldOp>(caseBlock.getTerminator());
    if (!terminator) {
      return emitOpError() << "case region " << idx
                           << " must terminate with cal.variant.yield";
    }

    // Check yield type matches result type
    if (terminator.getResult().getType() != getResult().getType()) {
      return emitOpError() << "case region " << idx << " yields type "
                           << terminator.getResult().getType()
                           << " but expected " << getResult().getType();
    }
  }

  return success();
}

// Custom assembly format for VariantMatchOp
//
// Format:
//   cal.variant.match %variant : !cal.variant<...> -> result_type {
//     case "VariantName"(%arg0: type0, %arg1: type1):
//       ... ops ...
//       cal.variant.yield %result : type
//     case "OtherVariant":
//       ...
//   }

void VariantMatchOp::print(OpAsmPrinter &p) {
  auto variantType = mlir::cast<VariantType>(getVariant().getType());

  p << " " << getVariant() << " : " << variantType << " -> " << getResult().getType() << " {";
  p.increaseIndent();

  for (auto [idx, region] : llvm::enumerate(getCases())) {
    auto variantDict = mlir::cast<DictionaryAttr>(variantType.getVariants()[idx]);
    StringRef variantName = variantDict.getAs<StringAttr>("name").getValue();

    p.printNewline();
    p << "case \"" << variantName << "\"";

    Block &caseBlock = region.front();
    if (!caseBlock.getArguments().empty()) {
      p << "(";
      llvm::interleaveComma(caseBlock.getArguments(), p, [&](BlockArgument arg) {
        p << arg << ": " << arg.getType();
      });
      p << ")";
    }
    p << ":";
    p.increaseIndent();

    // Print the block contents (excluding the entry block arguments)
    for (Operation &op : caseBlock) {
      p.printNewline();
      p.printCustomOrGenericOp(&op);
    }

    p.decreaseIndent();
  }

  p.decreaseIndent();
  p.printNewline();
  p << "}";
}

ParseResult VariantMatchOp::parse(OpAsmParser &parser, OperationState &result) {
  OpAsmParser::UnresolvedOperand variantOperand;
  VariantType variantType;
  Type resultType;

  // Parse: %variant : !cal.variant<...> -> result_type
  if (parser.parseOperand(variantOperand) ||
      parser.parseColon() ||
      parser.parseType(variantType) ||
      parser.parseArrow() ||
      parser.parseType(resultType))
    return failure();

  if (parser.resolveOperand(variantOperand, variantType, result.operands))
    return failure();

  result.addTypes(resultType);

  // Parse the regions: { case "Name"(...): ... }
  if (parser.parseLBrace())
    return failure();

  // Parse case regions
  size_t numVariants = variantType.getVariants().size();
  for (size_t i = 0; i < numVariants; ++i) {
    // Get expected variant info
    auto variantDict = mlir::cast<DictionaryAttr>(variantType.getVariants()[i]);
    StringRef expectedVariantName = variantDict.getAs<StringAttr>("name").getValue();
    auto fieldTypes = getVariantFieldTypes(variantDict);

    // Parse: case "VariantName"
    if (parser.parseKeyword("case"))
      return failure();

    std::string variantName;
    if (parser.parseString(&variantName))
      return failure();

    if (variantName != expectedVariantName) {
      return parser.emitError(parser.getCurrentLocation())
             << "expected case for variant '" << expectedVariantName
             << "' but got '" << variantName << "'";
    }

    // Create a new region for this case
    Region *caseRegion = result.addRegion();

    // Parse optional block arguments: (%arg0: type0, ...)
    SmallVector<OpAsmParser::Argument> blockArgs;
    if (!fieldTypes.empty()) {
      if (parser.parseLParen())
        return failure();

      for (size_t j = 0; j < fieldTypes.size(); ++j) {
        if (j > 0 && parser.parseComma())
          return failure();

        OpAsmParser::Argument arg;
        if (parser.parseArgument(arg) ||
            parser.parseColon() ||
            parser.parseType(arg.type))
          return failure();

        if (arg.type != fieldTypes[j]) {
          return parser.emitError(parser.getCurrentLocation())
                 << "argument type " << arg.type << " does not match expected "
                 << fieldTypes[j];
        }
        blockArgs.push_back(arg);
      }

      if (parser.parseRParen())
        return failure();
    }

    // Parse colon
    if (parser.parseColon())
      return failure();

    // Parse the region body - use parseRegion with the block arguments
    if (parser.parseRegion(*caseRegion, blockArgs))
      return failure();

    // Ensure the region has exactly one block
    if (caseRegion->empty()) {
      return parser.emitError(parser.getCurrentLocation())
             << "case region for '" << variantName << "' cannot be empty";
    }
  }

  if (parser.parseRBrace())
    return failure();

  return success();
}

LogicalResult ProductCreateOp::verify() {
  auto productType = mlir::cast<ProductType>(getResult().getType());
  ArrayAttr fieldsAttr = productType.getFields();

  // Check arity
  if (getFields().size() != fieldsAttr.size()) {
    return emitOpError() << "product type '" << productType.getName()
                         << "' expects " << fieldsAttr.size()
                         << " field(s), but got " << getFields().size();
  }

  // Check field types
  for (auto [idx, pair] : llvm::enumerate(llvm::zip(getFields(), fieldsAttr))) {
    auto [field, fieldDictAttr] = pair;
    auto fieldDict = mlir::cast<DictionaryAttr>(fieldDictAttr);
    auto expectedTypeAttr = fieldDict.getAs<TypeAttr>("type");
    if (!expectedTypeAttr) {
      return emitOpError() << "field " << idx << " missing type in product type";
    }
    Type expectedType = expectedTypeAttr.getValue();
    if (field.getType() != expectedType) {
      auto fieldName = fieldDict.getAs<StringAttr>("name");
      return emitOpError() << "field '" << (fieldName ? fieldName.getValue() : "")
                           << "' (index " << idx << ") expects type " << expectedType
                           << ", but got " << field.getType();
    }
  }

  return success();
}

LogicalResult ProductGetFieldOp::verify() {
  auto productType = mlir::cast<ProductType>(getProduct().getType());
  StringRef fieldName = getFieldName();

  // Find the field
  auto fieldInfo = findProductFieldByName(productType, fieldName);
  if (!fieldInfo) {
    return emitOpError() << "field '" << fieldName << "' not found in product type '"
                         << productType.getName() << "'";
  }

  // Check result type matches
  Type expectedType = fieldInfo->second;
  if (getResult().getType() != expectedType) {
    return emitOpError() << "result type " << getResult().getType()
                         << " does not match field '" << fieldName << "' type "
                         << expectedType;
  }

  return success();
}

//===----------------------------------------------------------------------===//
// Memory Management Operations Verifiers
//===----------------------------------------------------------------------===//

LogicalResult RCAllocOp::verify() {
  // Check that result type is !cal.rc<T> where T matches input value type
  auto rcType = mlir::dyn_cast<RCType>(getResult().getType());
  if (!rcType) {
    return emitOpError() << "result type must be !cal.rc<T>";
  }

  Type valueType = getValue().getType();
  Type elementType = rcType.getElementType();
  if (valueType != elementType) {
    return emitOpError() << "value type " << valueType
                         << " does not match RC element type " << elementType;
  }

  return success();
}

LogicalResult RCRetainOp::verify() {
  // Check that input and output types match
  auto inputType = mlir::dyn_cast<RCType>(getValue().getType());
  auto outputType = mlir::dyn_cast<RCType>(getResult().getType());
  
  if (!inputType) {
    return emitOpError() << "input must be !cal.rc<T>";
  }
  if (!outputType) {
    return emitOpError() << "result must be !cal.rc<T>";
  }
  if (inputType != outputType) {
    return emitOpError() << "input and output types must match";
  }

  return success();
}

LogicalResult RCReleaseOp::verify() {
  auto rcType = mlir::dyn_cast<RCType>(getValue().getType());
  if (!rcType) {
    return emitOpError() << "operand must be !cal.rc<T>";
  }
  return success();
}

LogicalResult RCLoadOp::verify() {
  auto rcType = mlir::dyn_cast<RCType>(getRc().getType());
  if (!rcType) {
    return emitOpError() << "operand must be !cal.rc<T>";
  }

  Type elementType = rcType.getElementType();
  Type resultType = getValue().getType();
  if (elementType != resultType) {
    return emitOpError() << "result type " << resultType
                         << " does not match RC element type " << elementType;
  }

  return success();
}

LogicalResult RCStoreOp::verify() {
  auto rcType = mlir::dyn_cast<RCType>(getRc().getType());
  if (!rcType) {
    return emitOpError() << "target must be !cal.rc<T>";
  }

  Type valueType = getValue().getType();
  Type elementType = rcType.getElementType();
  if (valueType != elementType) {
    return emitOpError() << "value type " << valueType
                         << " does not match RC element type " << elementType;
  }

  return success();
}

LogicalResult TokenWrapOp::verify() {
  auto tokenType = mlir::dyn_cast<TokenType>(getToken().getType());
  if (!tokenType) {
    return emitOpError() << "result must be !cal.token<T>";
  }

  Type valueType = getValue().getType();
  Type elementType = tokenType.getElementType();
  if (valueType != elementType) {
    return emitOpError() << "value type " << valueType
                         << " does not match token element type " << elementType;
  }

  return success();
}

LogicalResult TokenUnwrapOp::verify() {
  auto tokenType = mlir::dyn_cast<TokenType>(getToken().getType());
  if (!tokenType) {
    return emitOpError() << "operand must be !cal.token<T>";
  }

  Type elementType = tokenType.getElementType();
  Type resultType = getValue().getType();
  if (elementType != resultType) {
    return emitOpError() << "result type " << resultType
                         << " does not match token element type " << elementType;
  }

  return success();
}

