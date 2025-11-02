#include "mlir/Pass/Pass.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/Diagnostics.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include <optional>
#include <set>
#include "llvm/ADT/ArrayRef.h"

#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalTypes.h"

#include "Transforms/Passes.h"
#include "Transforms/VerifyInstanceArrayFills/VerifyInstanceArrayFills.h"

// Generate the base class for this pass (provides getArgument, getName, etc.).
namespace mlir {
#define GEN_PASS_DEF_VERIFYINSTANCEARRAYFILLSPASS
#include "Transforms/Passes.h.inc"
} // namespace mlir

using namespace mlir;
using namespace mlir::cal;

namespace {

static int64_t getTotalElements(mlir::Type arrTy) {
  auto computeFromShape = [](mlir::ArrayAttr shape) -> int64_t {
    if (!shape) return -1;
    int64_t total = 1;
    for (mlir::Attribute a : shape) {
      if (auto ia = mlir::dyn_cast<mlir::IntegerAttr>(a)) {
        int64_t extent = ia.getInt();
        if (extent <= 0) return -1;
        total *= extent;
      } else {
        // Dynamic/unknown dimension
        return -1;
      }
    }
    return total;
  };
  if (auto t = mlir::dyn_cast<cal::InstanceArrayType>(arrTy))
    return computeFromShape(t.getShape());
  if (auto t = mlir::dyn_cast<cal::InterfaceInstanceArrayType>(arrTy))
    return computeFromShape(t.getShape());
  return -1;
}

static mlir::LogicalResult checkOOB(mlir::Location loc, mlir::Type arrTy, llvm::ArrayRef<mlir::Value> indices) {
  auto check = [&](mlir::ArrayAttr shape) -> mlir::LogicalResult {
    if (!shape) return success();
    if (indices.size() != shape.size())
      return emitError(loc) << "rank mismatch: provided " << indices.size() << " indices for array of rank " << shape.size();
    for (size_t d = 0; d < shape.size(); ++d) {
      auto dimAttr = mlir::dyn_cast<mlir::IntegerAttr>(shape[d]);
      if (!dimAttr) continue; // dynamic dim, skip bound check
      if (auto c = indices[d].getDefiningOp<mlir::arith::ConstantOp>()) {
        if (auto idxAttr = mlir::dyn_cast_or_null<mlir::IntegerAttr>(c.getValue())) {
          int64_t idx = idxAttr.getInt();
          int64_t extent = dimAttr.getInt();
          if (idx < 0 || idx >= extent)
            return emitError(loc) << "index " << idx << " out of bounds for dimension " << d << " of extent " << extent;
        }
      }
    }
    return success();
  };
  if (auto t = mlir::dyn_cast<cal::InstanceArrayType>(arrTy))
    return check(t.getShape());
  if (auto t = mlir::dyn_cast<cal::InterfaceInstanceArrayType>(arrTy))
    return check(t.getShape());
  // Non-array type; nothing to check.
  return success();
}

struct VerifyInstanceArrayFillsPass : public mlir::impl::VerifyInstanceArrayFillsPassBase<VerifyInstanceArrayFillsPass> {
  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<mlir::cal::CalDialect, mlir::arith::ArithDialect>();
  }
  void runOnOperation() override {
  mlir::ModuleOp mod = getOperation();

    // 1) Bounds check on cal.instance.array.set
    mlir::WalkResult wr = mod.walk([&](mlir::cal::InstanceArraySetOp setOp) {
      mlir::Type arrTy = setOp.getArray().getType();
      llvm::SmallVector<mlir::Value> indices(setOp.getIndices().begin(), setOp.getIndices().end());
      if (failed(checkOOB(setOp.getLoc(), arrTy, indices))) {
        signalPassFailure();
        return WalkResult::interrupt();
      }
      return WalkResult::advance();
    });
    if (wr.wasInterrupted()) return;

    // 2) Basic completeness check on linear chains of sets
    //    We only handle the simple pattern: init -> set -> set -> ... -> used
    mod.walk([&](mlir::cal::InstanceArrayInitOp init) {
      mlir::Type arrTy = init.getArray().getType();
      int64_t total = getTotalElements(arrTy);
      if (total <= 0) return;

      // Trace a linear chain from init's single result through users if they are set ops.
  mlir::Value cur = init.getResult();
      std::set<std::string> seen;
  bool advanced = false;
      auto extractConstIdx = [](mlir::Value v) -> std::optional<int64_t> {
        if (auto c = v.getDefiningOp<mlir::arith::ConstantOp>()) {
          if (auto idxAttr = mlir::dyn_cast_or_null<mlir::IntegerAttr>(c.getValue()))
            return idxAttr.getInt();
        }
        return std::nullopt;
      };

      while (cur.hasOneUse()) {
        Operation *user = *cur.user_begin();
  auto setOp = mlir::dyn_cast<mlir::cal::InstanceArraySetOp>(user);
        if (!setOp) break;
        SmallVector<int64_t> idxTuple;
        bool allConst = true;
        for (Value iv : setOp.getIndices()) {
          auto oi = extractConstIdx(iv);
          if (!oi) { allConst = false; break; }
          idxTuple.push_back(*oi);
        }
        if (allConst) {
          std::string key;
          for (size_t i = 0; i < idxTuple.size(); ++i) {
            if (i) key.push_back(',');
            key += std::to_string(idxTuple[i]);
          }
          seen.insert(key);
        }
        advanced = true;
        cur = setOp.getResult();
      }

      // Only remark for linear chains we actually traversed (ignore non-linear patterns).
      if (advanced && (int64_t)seen.size() < total) {
        init.emitRemark() << "instance array appears only partially filled in linear chain: assigned "
                          << seen.size() << "/" << total << " constant index positions";
      }
    });
  }
};

} // namespace

std::unique_ptr<Pass> mlir::createVerifyInstanceArrayFillsPass() {
  return std::make_unique<VerifyInstanceArrayFillsPass>();
}
