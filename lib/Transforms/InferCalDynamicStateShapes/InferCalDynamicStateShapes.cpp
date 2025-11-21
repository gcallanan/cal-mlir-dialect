#include "mlir/Pass/Pass.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/Matchers.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalTypes.h"
#include "Transforms/Passes.h"

using namespace mlir;
using namespace mlir::cal;

namespace mlir {
#define GEN_PASS_DEF_INFERCALDYNAMICSTATESHAPESPASS
#include "Transforms/Passes.h.inc"
} // namespace mlir

namespace {

struct InferCalDynamicStateShapesPass : public mlir::impl::InferCalDynamicStateShapesPassBase<InferCalDynamicStateShapesPass> {
  void runOnOperation() override {
    ModuleOp module = getOperation();
    SmallVector<cal::CreateStateVarOp, 16> worklist;
    module.walk([&](cal::CreateStateVarOp op) { worklist.push_back(op); });

    auto evalConst = [&](Value v) -> std::optional<int64_t> {
      APInt ap;
      // Generic integer (covers index constants via matchPattern) first.
      if (matchPattern(v, m_ConstantInt(&ap)))
        return ap.getSExtValue();
      if (matchPattern(v, m_ConstantIndex(&ap)))
        return ap.getSExtValue();
      if (auto cOp = v.getDefiningOp<arith::ConstantOp>()) {
        if (auto intAttr = dyn_cast<IntegerAttr>(cOp.getValue()))
          return intAttr.getValue().getSExtValue();
      }
      if (auto castOp = v.getDefiningOp<arith::IndexCastOp>()) {
        if (auto inner = evalConst(castOp.getIn()))
          return inner;
      }
      // Simple folds: addi, subi, muli (both constant operands).
      if (auto addOp = v.getDefiningOp<arith::AddIOp>()) {
        if (auto lhs = evalConst(addOp.getLhs()); lhs && evalConst(addOp.getRhs()))
          return *lhs + *evalConst(addOp.getRhs());
      }
      if (auto subOp = v.getDefiningOp<arith::SubIOp>()) {
        if (auto lhs = evalConst(subOp.getLhs()); lhs && evalConst(subOp.getRhs()))
          return *lhs - *evalConst(subOp.getRhs());
      }
      if (auto mulOp = v.getDefiningOp<arith::MulIOp>()) {
        if (auto lhs = evalConst(mulOp.getLhs()); lhs && evalConst(mulOp.getRhs()))
          return *lhs * *evalConst(mulOp.getRhs());
      }
      return std::nullopt;
    };

    for (cal::CreateStateVarOp createOp : worklist) {
      Type stateElemTy = createOp.getStateType();
      ShapedType shapedTy = nullptr;
      if (auto mem = dyn_cast<MemRefType>(stateElemTy)) shapedTy = mem;
      else if (auto ten = dyn_cast<RankedTensorType>(stateElemTy)) shapedTy = ten;
      else continue; // Not a shaped type we handle.
      if (!shapedTy || shapedTy.getNumDynamicDims() == 0) continue; // Already static.

      ValueRange sizeOperands = createOp.getSizes();
      if (sizeOperands.empty()) continue; // Need explicit operands for dynamic dims.

      SmallVector<int64_t> newShape(shapedTy.getShape().begin(), shapedTy.getShape().end());
      int dynOperandIdx = 0;
      bool allResolved = true;
      for (int64_t dim = 0, e = shapedTy.getRank(); dim < e; ++dim) {
        if (!ShapedType::isDynamic(newShape[dim])) continue;
        if (dynOperandIdx >= (int)sizeOperands.size()) { allResolved = false; break; }
        Value sz = sizeOperands[dynOperandIdx++];
        auto maybeConst = evalConst(sz);
        if (!maybeConst || *maybeConst < 0) { allResolved = false; break; }
        newShape[dim] = *maybeConst;
      }
      if (!allResolved) continue;
      ShapedType newTy;
      if (auto mem = dyn_cast<MemRefType>(shapedTy))
        newTy = MemRefType::get(newShape, mem.getElementType(), mem.getLayout(), mem.getMemorySpace());
      else if (auto ten = dyn_cast<RankedTensorType>(shapedTy))
        newTy = RankedTensorType::get(newShape, ten.getElementType());
      else
        continue;
      if (!newTy.hasStaticShape()) continue; // Must be fully static.

      // Replace op with a new create_state_var without size operands (static now).
      OpBuilder b(createOp);
      auto stateRefTy = cal::StateVarRefType::get(module.getContext(), newTy);
      auto newOp = b.create<cal::CreateStateVarOp>(createOp.getLoc(), stateRefTy, ValueRange{}, TypeAttr::get(newTy));
      createOp.getResult().replaceAllUsesWith(newOp.getResult());
      createOp.erase();
    }
  }
};

} // end anonymous namespace

std::unique_ptr<mlir::Pass> mlir::createInferCalDynamicStateShapesPass() {
  return std::make_unique<InferCalDynamicStateShapesPass>();
}
