#include <functional>
#include "mlir/Pass/Pass.h"
#include "mlir/IR/BuiltinAttributes.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
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

      // Rebuild entire loop nest recursively (shape-only) with static array type.
      DenseSet<Operation*> rebuilt;
      std::function<Value(unsigned, Value)> rebuildNest = [&](unsigned idx, Value carried) -> Value {
        scf::ForOp oldLoop = info.loops[idx];
        if (rebuilt.contains(oldLoop.getOperation()))
          return info.loops[idx]->getResult(0); // already rebuilt
        rewriter.setInsertionPoint(oldLoop);
        Value init = carried;
        if (idx == 0) {
          // Fresh static init replaces dynamic iter arg seed.
          init = rewriter.create<cal::InstanceArrayInitOp>(oldLoop.getLoc(), staticTy, ValueRange{});
        }
        auto newLoop = rewriter.create<scf::ForOp>(oldLoop.getLoc(), oldLoop.getLowerBound(), oldLoop.getUpperBound(), oldLoop.getStep(), ValueRange{init});
        rebuilt.insert(oldLoop.getOperation());
        Block *oldBody = oldLoop.getBody();
        Block *newBody = newLoop.getBody();
        IRMapping map;
        map.map(oldLoop.getInductionVar(), newLoop.getInductionVar());
        map.map(oldLoop.getRegionIterArg(0), newLoop.getRegionIterArg(0));
        rewriter.setInsertionPointToStart(newBody);
        for (Operation &op : oldBody->without_terminator()) {
          // Nested loop: rebuild recursively and map its result.
          if (auto innerOld = dyn_cast<scf::ForOp>(&op)) {
            // Identify index of this inner loop in collected nest.
            unsigned nextIdx = 0;
            bool found=false;
            for (unsigned k=0;k<info.loops.size();++k) {
              if (info.loops[k] == innerOld) { nextIdx = k; found=true; break; }
            }
            if (found) {
              Value carriedInner = map.lookupOrDefault(oldLoop.getRegionIterArg(0));
              Value innerRes = rebuildNest(nextIdx, carriedInner);
              map.map(innerOld.getResult(0), innerRes);
            }
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
            // Drop dynamic init; replaced by static init above.
            continue;
          }
          Operation *cloned = rewriter.clone(op, map);
          for (auto [o, n] : llvm::zip(op.getResults(), cloned->getResults())) map.map(o, n);
        }
        // Yield last mapped set or the carried array if none.
        scf::YieldOp oldYield = dyn_cast<scf::YieldOp>(oldBody->getTerminator());
        Value oldYieldVal = oldYield.getOperand(0);
        Value newYieldVal = map.lookupOrNull(oldYieldVal);
        if (!newYieldVal) newYieldVal = newLoop.getRegionIterArg(0);
        rewriter.setInsertionPointToEnd(newBody);
        rewriter.create<scf::YieldOp>(oldYield.getLoc(), ValueRange{newYieldVal});
        return newLoop.getResult(0);
      };

      Value finalVal = rebuildNest(0, Value());
      // Adjust enclosing function signature BEFORE replacing loop so verification sees consistent types.
      if (auto fn = info.loops.front()->getParentOfType<func::FuncOp>()) {
        auto oldFnType = fn.getFunctionType();
        SmallVector<Type> resultTypes(oldFnType.getResults().begin(), oldFnType.getResults().end());
        // Scan returns for staticized arrays.
        bool needsUpdate=false;
        fn.walk([&](func::ReturnOp ret){
          for (auto it : llvm::enumerate(ret.getOperands())) {
            if (it.index() >= resultTypes.size()) continue;
            auto oldArr = dyn_cast<cal::InstanceArrayType>(resultTypes[it.index()]);
            auto newArr = dyn_cast<cal::InstanceArrayType>(finalVal.getType());
            if (!oldArr || !newArr) continue;
            bool oldDynamic=false; for (Attribute a : oldArr.getShape()) if (auto ia=dyn_cast<IntegerAttr>(a)) if (ia.getInt()==-1) { oldDynamic=true; break; }
            bool newFullyStatic=true; for (Attribute a : newArr.getShape()) if (auto ia=dyn_cast<IntegerAttr>(a)) if (ia.getInt()==-1) { newFullyStatic=false; break; }
            if (oldDynamic && newFullyStatic) { resultTypes[it.index()] = newArr; needsUpdate=true; }
          }
        });
        if (needsUpdate) {
          auto newFnType = FunctionType::get(fn.getContext(), oldFnType.getInputs(), resultTypes);
          fn.setType(newFnType);
        }
      }
      rewriter.replaceOp(info.loops.front(), finalVal);
    }

    // Pass 2: Upgrade dynamic instance.array.init with constant dim operands to static type.
    SmallVector<cal::InstanceArrayInitOp> initOps;
    module.walk([&](cal::InstanceArrayInitOp op){ initOps.push_back(op); });
    for (auto init : initOps) {
      auto arrTy = dyn_cast<InstanceArrayType>(init.getResult().getType());
      if (!arrTy) continue;
      auto shape = arrTy.getShape();
      if (!shape) continue;
      bool anyStatic=false; for (Attribute a : shape) if (auto ia=dyn_cast<IntegerAttr>(a)) if (ia.getInt()!=-1) anyStatic=true;
      if (anyStatic) continue; // already partially or fully static -> skip (handled elsewhere)
      // If there are no dims operands, cannot infer (already dynamic without explicit extents)
      if (init.getDims().empty()) continue;
      SmallVector<int64_t> extents; bool allConst=true;
      for (Value d : init.getDims()) {
        auto c = evalConstIndex(d);
        if (!c || *c <= 0) { allConst=false; break; }
        extents.push_back(*c);
      }
      if (!allConst) continue;
      // Build static type
      auto *ctx = rewriter.getContext();
      SmallVector<Attribute> dimAttrs; dimAttrs.reserve(extents.size());
      for (int64_t e : extents)
        dimAttrs.push_back(IntegerAttr::get(IntegerType::get(ctx,64), e));
      auto staticTy = InstanceArrayType::get(ctx, arrTy.getActorRef(), ArrayAttr::get(ctx, dimAttrs));
      rewriter.setInsertionPoint(init);
      auto newInit = rewriter.create<cal::InstanceArrayInitOp>(init.getLoc(), staticTy, ValueRange{});
      // Mark for debugging
      newInit->setAttr("cal.shape_inferred", rewriter.getUnitAttr());
      rewriter.replaceOp(init, newInit.getResult());
    }

    // Pass 3: Upgrade dynamic instance_array.literal based on operand count (1-D only).
    SmallVector<cal::InstanceArrayLiteralOp> literalOps;
    module.walk([&](cal::InstanceArrayLiteralOp op){ literalOps.push_back(op); });
    for (auto lit : literalOps) {
      auto arrTy = dyn_cast<InstanceArrayType>(lit.getResult().getType());
      if (!arrTy) continue;
      auto shape = arrTy.getShape();
      if (!shape || shape.size() != 1) continue; // only 1-D for now
      auto ia = dyn_cast<IntegerAttr>(shape[0]);
      if (!ia || ia.getInt() != -1) continue; // already static
      int64_t n = (int64_t)lit.getInputs().size();
      if (n <= 0) continue;
      auto *ctx = rewriter.getContext();
      auto newShape = ArrayAttr::get(ctx, IntegerAttr::get(IntegerType::get(ctx,64), n));
      auto staticTy = InstanceArrayType::get(ctx, arrTy.getActorRef(), newShape);
      rewriter.setInsertionPoint(lit);
      auto newLit = rewriter.create<cal::InstanceArrayLiteralOp>(lit.getLoc(), staticTy, lit.getInputs());
      newLit->setAttr("cal.shape_inferred", rewriter.getUnitAttr());
      rewriter.replaceOp(lit, newLit.getResult());
    }

    // Pass 4: Upgrade dynamic instance_array.concat where both operands are static 1-D arrays.
    SmallVector<cal::InstanceArrayConcatOp> concatOps;
    module.walk([&](cal::InstanceArrayConcatOp op){ concatOps.push_back(op); });
    for (auto concat : concatOps) {
      auto resTy = dyn_cast<InstanceArrayType>(concat.getResult().getType());
      if (!resTy) continue;
      auto resShape = resTy.getShape();
      if (!resShape || resShape.size()!=1) continue; // Only 1-D for now
      auto resDimAttr = dyn_cast<IntegerAttr>(resShape[0]);
      if (!resDimAttr || resDimAttr.getInt() != -1) continue; // already static result
      auto lhsTy = dyn_cast<InstanceArrayType>(concat.getLhs().getType());
      auto rhsTy = dyn_cast<InstanceArrayType>(concat.getRhs().getType());
      if (!lhsTy || !rhsTy) continue;
      auto lhsShape = lhsTy.getShape();
      auto rhsShape = rhsTy.getShape();
      if (!lhsShape || lhsShape.size()!=1 || !rhsShape || rhsShape.size()!=1) continue;
      auto lhsDim = dyn_cast<IntegerAttr>(lhsShape[0]);
      auto rhsDim = dyn_cast<IntegerAttr>(rhsShape[0]);
      if (!lhsDim || !rhsDim) continue;
      int64_t l = lhsDim.getInt();
      int64_t r = rhsDim.getInt();
      if (l < 0 || r < 0) continue; // both must be static
      int64_t total = l + r;
      auto *ctx = rewriter.getContext();
      auto newShape = ArrayAttr::get(ctx, IntegerAttr::get(IntegerType::get(ctx,64), total));
      auto staticTy = InstanceArrayType::get(ctx, resTy.getActorRef(), newShape);
      rewriter.setInsertionPoint(concat);
      auto newConcat = rewriter.create<cal::InstanceArrayConcatOp>(concat.getLoc(), staticTy, concat.getLhs(), concat.getRhs());
      newConcat->setAttr("cal.shape_inferred", rewriter.getUnitAttr());
      rewriter.replaceOp(concat, newConcat.getResult());
    }

    // Final adjustment: update function result types if returns were staticized.
    module.walk([&](func::FuncOp fn){
      // Collect return ops and see if any operand type differs only by dynamic -> static array change.
      bool needsUpdate=false;
      SmallVector<Type> newResults(fn.getFunctionType().getResults().begin(), fn.getFunctionType().getResults().end());
      fn.walk([&](func::ReturnOp ret){
        for (auto it : llvm::enumerate(ret.getOperands())) {
          Type retTy = it.value().getType();
          if (it.index() >= newResults.size()) continue;
          auto oldTy = dyn_cast<cal::InstanceArrayType>(newResults[it.index()]);
          auto newTy = dyn_cast<cal::InstanceArrayType>(retTy);
          if (!oldTy || !newTy) continue;
          // If old was dynamic in any dim and new is fully static, update.
          bool oldDynamic=false; bool newStatic=true;
          for (Attribute a : oldTy.getShape()) if (auto ia=dyn_cast<IntegerAttr>(a)) if (ia.getInt()==-1) { oldDynamic=true; break; }
          for (Attribute a : newTy.getShape()) if (auto ia=dyn_cast<IntegerAttr>(a)) if (ia.getInt()==-1) { newStatic=false; break; }
          if (oldDynamic && newStatic) {
            newResults[it.index()] = retTy;
            needsUpdate=true;
          }
        }
      });
      if (needsUpdate) {
        auto newFnType = FunctionType::get(fn.getContext(), fn.getFunctionType().getInputs(), newResults);
        fn.setType(newFnType);
      }
    });
  }
};

} // namespace

namespace mlir {
std::unique_ptr<Pass> createInferCalInstanceArrayShapePass() {
  return std::make_unique<InferCalInstanceArrayShapePass>();
}
} // namespace mlir
