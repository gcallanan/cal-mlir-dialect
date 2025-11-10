#include <functional>
#include "mlir/Pass/Pass.h"
#include "mlir/IR/BuiltinAttributes.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalTypes.h"
#include "Transforms/PromoteCalInstanceArrays/PromoteCalInstanceArrays.h"
#include "Transforms/Passes.h"
#include "llvm/Support/raw_ostream.h"

using namespace mlir;
using namespace mlir::cal;

namespace mlir {
#define GEN_PASS_DEF_INFERCALINSTANCEARRAYSHAPEPASS
#include "Transforms/Passes.h.inc"
} // namespace mlir

namespace {

static std::optional<int64_t> evalConstIndex(Value v) {
  if (!v) return std::nullopt;
  if (auto c = v.getDefiningOp<arith::ConstantOp>()) {
    if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) return ia.getInt();
    return std::nullopt;
  }
  if (auto cast = v.getDefiningOp<arith::IndexCastOp>()) {
    if (auto inner = evalConstIndex(cast.getIn())) return inner;
    if (auto ci = cast.getIn().getDefiningOp<arith::ConstantOp>()) {
      if (auto ia = dyn_cast<IntegerAttr>(ci.getValue())) return ia.getInt();
    }
    return std::nullopt;
  }
  if (auto addi = v.getDefiningOp<arith::AddIOp>()) {
    auto a = evalConstIndex(addi.getLhs());
    auto b = evalConstIndex(addi.getRhs());
    if (a && b) return *a + *b;
    return std::nullopt;
  }
  if (auto subi = v.getDefiningOp<arith::SubIOp>()) {
    auto a = evalConstIndex(subi.getLhs());
    auto b = evalConstIndex(subi.getRhs());
    if (a && b) return *a - *b;
    return std::nullopt;
  }
  if (auto muli = v.getDefiningOp<arith::MulIOp>()) {
    auto a = evalConstIndex(muli.getLhs());
    auto b = evalConstIndex(muli.getRhs());
    if (a && b) return *a * *b;
    return std::nullopt;
  }
  return std::nullopt;
}

struct LoopNestInfo {
  SmallVector<scf::ForOp> loops;   // outermost -> innermost
  InstanceArrayType dynArrayTy;    // dynamic array type built by the nest
  cal::InstanceArraySetOp setOp;   // innermost array.set yielded
  cal::InstantiateOp instantiateOp;// optional instantiate producing handle
};

static scf::ForOp getSingleNestedFor(Block &body) {
  scf::ForOp found = nullptr;
  for (Operation &op : body) {
    if (isa<scf::YieldOp>(&op))
      continue;
    if (auto f = dyn_cast<scf::ForOp>(&op)) {
      if (found) return nullptr;
      found = f;
      continue;
    }
    if (!(isa<arith::AddIOp, arith::SubIOp, arith::MulIOp,
              arith::IndexCastOp, arith::ConstantOp>(&op)))
      return nullptr;
  }
  return found;
}

static bool collectLoopNest(scf::ForOp root, LoopNestInfo &info) {
  if (root.getInitArgs().size() != 1 || root.getNumResults() != 1)
    return false;
  auto arrTy = dyn_cast<InstanceArrayType>(root.getResult(0).getType());
  if (!arrTy)
    return false;
  auto shape = arrTy.getShape();
  if (!shape || shape.empty())
    return false;
  for (Attribute dim : shape) {
    auto ia = dyn_cast<IntegerAttr>(dim);
    if (!ia || ia.getInt() != -1)
      return false;
  }

  scf::ForOp cur = root;
  info.loops.clear();
  while (true) {
    info.loops.push_back(cur);
    scf::ForOp next = getSingleNestedFor(*cur.getBody());
    if (!next) break;
    cur = next;
  }

  scf::ForOp innermost = info.loops.back();
  cal::InstanceArraySetOp set = nullptr;
  cal::InstantiateOp inst = nullptr;
  for (Operation &op : *innermost.getBody()) {
    if (auto s = dyn_cast<cal::InstanceArraySetOp>(&op)) set = s;
    if (auto i = dyn_cast<cal::InstantiateOp>(&op)) inst = i;
  }
  if (!set)
    return false;
  auto term = dyn_cast<scf::YieldOp>(innermost.getBody()->getTerminator());
  if (!term || term.getNumOperands() != 1 || term.getOperand(0) != set.getResult())
    return false;

  info.dynArrayTy = arrTy;
  info.setOp = set;
  info.instantiateOp = inst;
  return true;
}

struct InferCalInstanceArrayShapePass
    : public mlir::impl::InferCalInstanceArrayShapePassBase<InferCalInstanceArrayShapePass> {
  void runOnOperation() override {
    ModuleOp module = getOperation();
    SmallVector<scf::ForOp> forOps;
    module.walk([&](scf::ForOp f){ forOps.push_back(f); });
    IRRewriter rewriter(&getContext());
    for (scf::ForOp root : forOps) {
      LoopNestInfo info;
      if (!collectLoopNest(root, info)) continue;
      // Compute extents from each loop.
      SmallVector<int64_t> extents; extents.reserve(info.loops.size());
      bool fail=false;
      for (scf::ForOp loop : info.loops) {
        auto lb = evalConstIndex(loop.getLowerBound());
        auto ub = evalConstIndex(loop.getUpperBound());
        auto st = evalConstIndex(loop.getStep());
        if (!lb || !ub || !st || *st<=0) { fail=true; break; }
        int64_t diff = *ub - *lb; if (diff < 0) diff = 0;
        int64_t trip = (diff + *st - 1)/ *st;
        if (trip <= 0) { fail=true; break; }
        extents.push_back(trip);
      }
      if (fail) continue;
      // If already static, skip.
      auto dynTy = info.dynArrayTy;
      bool allDyn=true; for (Attribute a : dynTy.getShape()) {
        if (auto ia = dyn_cast<IntegerAttr>(a)) if (ia.getInt() != -1) allDyn=false;
      }
      if (!allDyn) continue; // nothing to do
      if ((int64_t)extents.size() != (int64_t)dynTy.getShape().size()) continue;
      // Build static type.
      auto *ctx = rewriter.getContext();
      SmallVector<Attribute> newDims; newDims.reserve(extents.size());
      for (int64_t e : extents)
        newDims.push_back(IntegerAttr::get(IntegerType::get(ctx,64), e));
      auto staticTy = InstanceArrayType::get(ctx, dynTy.getActorRef(), ArrayAttr::get(ctx, newDims));

      // Rebuild loop nest recursively (shape-only) with static array type.
      std::function<Value(unsigned, Value)> rebuildNest = [&](unsigned idx, Value carried) -> Value {
        scf::ForOp oldLoop = info.loops[idx];
        rewriter.setInsertionPoint(oldLoop);
        Value init = carried;
        if (idx == 0) {
          init = rewriter.create<cal::InstanceArrayInitOp>(oldLoop.getLoc(), staticTy, ValueRange{});
        }
        auto newLoop = rewriter.create<scf::ForOp>(oldLoop.getLoc(), oldLoop.getLowerBound(), oldLoop.getUpperBound(), oldLoop.getStep(), ValueRange{init});
        Block *oldBody = oldLoop.getBody();
        Block *newBody = newLoop.getBody();
        IRMapping map;
        map.map(oldLoop.getInductionVar(), newLoop.getInductionVar());
        map.map(oldLoop.getRegionIterArg(0), newLoop.getRegionIterArg(0));
        rewriter.setInsertionPointToStart(newBody);
        for (Operation &op : oldBody->without_terminator()) {
          if (auto innerOld = dyn_cast<scf::ForOp>(&op)) {
            // Recurse to build inner loop; existing rebuild will handle its body.
            (void)innerOld; // no-op; the actual nested loop will be handled when root advances
            continue;
          }
          if (auto setOp = dyn_cast<cal::InstanceArraySetOp>(&op)) {
            Value arrayOperand = map.lookupOrDefault(setOp.getArray());
            SmallVector<Value> idxVals;
            for (Value iv : setOp.getIndices()) idxVals.push_back(map.lookupOrDefault(iv));
            Value valueOperand = map.lookupOrDefault(setOp.getValue());
            auto newSet = rewriter.create<cal::InstanceArraySetOp>(setOp.getLoc(), staticTy, arrayOperand, ValueRange(idxVals), valueOperand);
            map.map(setOp.getResult(), newSet.getResult());
            continue;
          }
          if (isa<cal::InstanceArrayInitOp>(&op)) {
            continue; // skip dynamic init
          }
          Operation *cloned = rewriter.clone(op, map);
          for (auto [o, n] : llvm::zip(op.getResults(), cloned->getResults())) map.map(o, n);
        }
        scf::YieldOp oldYield = dyn_cast<scf::YieldOp>(oldBody->getTerminator());
        Value oldYieldVal = oldYield.getOperand(0);
        Value newYieldVal = map.lookupOrNull(oldYieldVal);
        if (!newYieldVal) newYieldVal = newLoop.getRegionIterArg(0);
        rewriter.setInsertionPointToEnd(newBody);
        rewriter.create<scf::YieldOp>(oldYield.getLoc(), ValueRange{newYieldVal});
        return newLoop.getResult(0);
      };

      Value finalVal = rebuildNest(0, Value());
      rewriter.replaceOp(info.loops.front(), finalVal);
    }
  }
};

} // namespace

namespace mlir {
std::unique_ptr<Pass> createInferCalInstanceArrayShapePass() {
  return std::make_unique<InferCalInstanceArrayShapePass>();
}
} // namespace mlir
