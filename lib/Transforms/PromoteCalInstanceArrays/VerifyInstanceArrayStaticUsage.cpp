#include "mlir/Pass/Pass.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalTypes.h"
#include "Transforms/Passes.h"

using namespace mlir;
using namespace mlir::cal;

namespace {

class VerifyInstanceArrayStaticUsagePass : public PassWrapper<VerifyInstanceArrayStaticUsagePass, OperationPass<ModuleOp>> {
public:
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(VerifyInstanceArrayStaticUsagePass)
  StringRef getArgument() const final { return "verify-instance-array-static-usage"; }
  StringRef getDescription() const final { return "Verify that constant indices used with static instance arrays are in-bounds"; }

  void runOnOperation() override {
    ModuleOp module = getOperation();
    bool hadError = false;

    auto checkIndices = [&](Operation *useOp, InstanceArrayType arrTy, ArrayRef<Value> indices) {
      auto shapeAttr = arrTy.getShape();
      if (!shapeAttr) return; // nothing to check
      if (shapeAttr.size() != indices.size()) return; // mismatch; let other verifiers complain
      unsigned dimIdx = 0;
      for (auto dimAttr : shapeAttr) {
        auto intAttr = dyn_cast<IntegerAttr>(dimAttr);
        if (!intAttr || intAttr.getInt() < 0) { ++dimIdx; continue; } // dynamic or sentinel -> skip
        Value idxVal = indices[dimIdx];
        auto cIdx = idxVal.getDefiningOp<arith::ConstantOp>();
        if (!cIdx) { ++dimIdx; continue; } // not constant, skip (runtime check elsewhere)
        auto cInt = dyn_cast<IntegerAttr>(cIdx.getValue());
        if (!cInt) { ++dimIdx; continue; }
        int64_t iv = cInt.getInt();
        int64_t bound = intAttr.getInt();
        if (iv < 0 || iv >= bound) {
          useOp->emitError() << "index " << iv << " out of bounds for static instance array dimension " << dimIdx << " (size=" << bound << ")";
          hadError = true;
        }
        ++dimIdx;
      }
    };

    module.walk([&](cal::InstanceArraySetOp setOp) {
      auto arrTy = dyn_cast<InstanceArrayType>(setOp.getArray().getType());
      if (!arrTy) return;
      SmallVector<Value, 4> idxVals(setOp.getIndices().begin(), setOp.getIndices().end());
      checkIndices(setOp, arrTy, idxVals);
    });

    module.walk([&](cal::InstanceAtOp atOp) {
      auto arrTy = dyn_cast<InstanceArrayType>(atOp.getArray().getType());
      if (!arrTy) return;
      SmallVector<Value, 4> idxVals(atOp.getIndices().begin(), atOp.getIndices().end());
      checkIndices(atOp, arrTy, idxVals);
    });

    if (hadError) signalPassFailure();
  }
};

} // namespace

namespace mlir {
std::unique_ptr<Pass> createVerifyInstanceArrayStaticUsagePass() {
  return std::make_unique<VerifyInstanceArrayStaticUsagePass>();
}
} // namespace mlir
