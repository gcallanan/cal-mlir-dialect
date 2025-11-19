//===- NormalizeConnects.cpp - Lower array-indexed connects to scalars -*- C++ -*-===//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//===----------------------------------------------------------------------===//

#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

#include "Transforms/Passes.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalTypes.h"

using namespace mlir;
using namespace mlir::cal;

namespace {
struct NormalizeCalConnectsPass : PassWrapper<NormalizeCalConnectsPass, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(NormalizeCalConnectsPass)
  StringRef getArgument() const final { return "normalize-cal-connects"; }
  StringRef getDescription() const final { return "Lower array-indexed cal.connect endpoints to scalar instance handles via cal.instance_at"; }

  void runOnOperation() override {
    ModuleOp module = getOperation();
    IRRewriter rewriter(&getContext());

    SmallVector<ConnectOp, 32> connects;
    module.walk([&](ConnectOp op) { connects.push_back(op); });

    for (ConnectOp op : connects) {
      if (!op || op->getParentOp() == nullptr)
        continue;
      Location loc = op.getLoc();

      Value src = op.getSrc();
      SmallVector<Value, 4> srcIdx(op.getSrcIndices().begin(), op.getSrcIndices().end());
      Value dst = op.getDst();
      SmallVector<Value, 4> dstIdx(op.getDstIndices().begin(), op.getDstIndices().end());

      bool changed = false;
      rewriter.setInsertionPoint(op);

      // If source is array-indexed, extract a scalar handle.
      if (!srcIdx.empty()) {
        Type srcTy = src.getType();
        Type handleTy;
        if (auto arrTy = dyn_cast<InstanceArrayType>(srcTy)) {
          handleTy = InstanceType::get(&getContext(), arrTy.getActorRef());
        } else if (auto arrIfaceTy = dyn_cast<InterfaceInstanceArrayType>(srcTy)) {
          handleTy = InterfaceInstanceType::get(&getContext(), arrIfaceTy.getIfaceRef());
        }
        if (handleTy) {
          auto at = rewriter.create<InstanceAtOp>(loc, handleTy, src, ValueRange(srcIdx));
          src = at.getResult();
          srcIdx.clear();
          changed = true;
        }
      }

      // If destination is array-indexed, extract a scalar handle.
      if (!dstIdx.empty()) {
        Type dstTy = dst.getType();
        Type handleTy;
        if (auto arrTy = dyn_cast<InstanceArrayType>(dstTy)) {
          handleTy = InstanceType::get(&getContext(), arrTy.getActorRef());
        } else if (auto arrIfaceTy = dyn_cast<InterfaceInstanceArrayType>(dstTy)) {
          handleTy = InterfaceInstanceType::get(&getContext(), arrIfaceTy.getIfaceRef());
        }
        if (handleTy) {
          auto at = rewriter.create<InstanceAtOp>(loc, handleTy, dst, ValueRange(dstIdx));
          dst = at.getResult();
          dstIdx.clear();
          changed = true;
        }
      }

      if (!changed)
        continue;

      // Recreate a normalized connect with scalar endpoints (no indices).
      OperationState st(loc, ConnectOp::getOperationName());
      // Operands in order: src, srcIndices..., dst, dstIndices...
      st.addOperands(src);
      st.addOperands(ValueRange{}); // no src indices after scalarization
      st.addOperands(dst);
      st.addOperands(ValueRange{}); // no dst indices after scalarization
      // No results.
      // Attributes: srcPort, dstPort, optional capacity, and required segment sizes
      if (auto a = op.getSrcPortAttr()) st.addAttribute("srcPort", a);
      if (auto a = op.getDstPortAttr()) st.addAttribute("dstPort", a);
      if (auto a = op.getCapacityAttr()) st.addAttribute("capacity", a);
      // operandSegmentSizes: [src(1), srcIndices(0), dst(1), dstIndices(0)]
      auto seg = rewriter.getI32VectorAttr({1, 0, 1, 0});
      st.addAttribute("operand_segment_sizes", seg);
      (void)rewriter.create(st);
      
      rewriter.eraseOp(op);
    }
  }
};
} // namespace

namespace mlir {
std::unique_ptr<Pass> createNormalizeCalConnectsPass() {
  return std::make_unique<NormalizeCalConnectsPass>();
}
} // namespace mlir
