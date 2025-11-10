#include "mlir/Pass/Pass.h"
// Dependent dialects referenced in the generated registration for this pass.
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "Dialect/Cal/CalOps.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PatternMatch.h"
#include "Transforms/Passes.h"

//===- ElaborateScfStructures.cpp - Elaborate scf.if/for for CAL -------===//
// Elaborate structural scf.if/scf.for when predicates and trip counts are
// (trivially) constant, cloning CAL structural ops into the parent network.
// This strengthens constant detection beyond bare arith.constant by evaluating
// small integer/boolean expression trees (cmp/select/add/sub/mul/index_cast).
//===----------------------------------------------------------------------===//

using namespace mlir;

namespace mlir {
#define GEN_PASS_DEF_ELABORATESCFSTRUCTURESPASS
#include "Transforms/Passes.h.inc"

namespace {
struct ElaborateScfStructuresPass : public impl::ElaborateScfStructuresPassBase<ElaborateScfStructuresPass> {
  void runOnOperation() override {
    ModuleOp module = getOperation();

    auto hasNetworkAncestor = [](Operation *op) {
      Operation *cur = op->getParentOp();
      while (cur) {
        if (isa<cal::NetworkOp>(cur)) return true;
        cur = cur->getParentOp();
      }
      return false;
    };

    // Tiny local evaluators to fold trivially constant exprs.
    auto evalInt = [&](Value v, std::function<std::optional<int64_t>(Value)> &self) -> std::optional<int64_t> {
      if (!v)
        return std::nullopt;
      if (auto c = v.getDefiningOp<arith::ConstantOp>()) {
        if (auto ia = dyn_cast<IntegerAttr>(c.getValue()))
          return ia.getInt();
      }
      if (auto cast = v.getDefiningOp<arith::IndexCastOp>()) {
        return self(cast.getIn());
      }
      if (auto subi = v.getDefiningOp<arith::SubIOp>()) {
        auto a = self(subi.getLhs());
        auto b = self(subi.getRhs());
        if (a && b) return *a - *b;
      }
      if (auto addi = v.getDefiningOp<arith::AddIOp>()) {
        auto a = self(addi.getLhs());
        auto b = self(addi.getRhs());
        if (a && b) return *a + *b;
      }
      if (auto muli = v.getDefiningOp<arith::MulIOp>()) {
        auto a = self(muli.getLhs());
        auto b = self(muli.getRhs());
        if (a && b) return (*a) * (*b);
      }
      if (auto sel = v.getDefiningOp<arith::SelectOp>()) {
        // Only handle i1 condition.
        auto evalBool = [&](Value bv, auto &selfB) -> std::optional<bool> {
          if (auto c = bv.getDefiningOp<arith::ConstantOp>()) {
            if (auto ba = dyn_cast<BoolAttr>(c.getValue()))
              return ba.getValue();
          }
          if (auto cmp = bv.getDefiningOp<arith::CmpIOp>()) {
            auto lhs = self(cmp.getLhs());
            auto rhs = self(cmp.getRhs());
            if (!lhs || !rhs)
              return std::nullopt;
            switch (cmp.getPredicate()) {
            case arith::CmpIPredicate::eq: return *lhs == *rhs; 
            case arith::CmpIPredicate::ne: return *lhs != *rhs; 
            case arith::CmpIPredicate::slt: return *lhs < *rhs; 
            case arith::CmpIPredicate::sle: return *lhs <= *rhs; 
            case arith::CmpIPredicate::sgt: return *lhs > *rhs; 
            case arith::CmpIPredicate::sge: return *lhs >= *rhs; 
            case arith::CmpIPredicate::ult: return (uint64_t)*lhs < (uint64_t)*rhs; 
            case arith::CmpIPredicate::ule: return (uint64_t)*lhs <= (uint64_t)*rhs; 
            case arith::CmpIPredicate::ugt: return (uint64_t)*lhs > (uint64_t)*rhs; 
            case arith::CmpIPredicate::uge: return (uint64_t)*lhs >= (uint64_t)*rhs; 
            }
          }
          return std::nullopt;
        };
        std::function<std::optional<bool>(Value)> selfB = [&](Value bv){ return evalBool(bv, selfB); };
        auto cond = selfB(sel.getCondition());
        if (!cond)
          return std::nullopt;
        return *cond ? self(sel.getTrueValue()) : self(sel.getFalseValue());
      }
      return std::nullopt;
    };
    std::function<std::optional<int64_t>(Value)> evalIntSelf = [&](Value v){ return evalInt(v, evalIntSelf); };

    auto evalBool = [&](Value v, std::function<std::optional<bool>(Value)> &selfB) -> std::optional<bool> {
      if (!v)
        return std::nullopt;
      if (auto c = v.getDefiningOp<arith::ConstantOp>()) {
        if (auto ba = dyn_cast<BoolAttr>(c.getValue()))
          return ba.getValue();
      }
      if (auto cmp = v.getDefiningOp<arith::CmpIOp>()) {
        auto lhs = evalIntSelf(cmp.getLhs());
        auto rhs = evalIntSelf(cmp.getRhs());
        if (!lhs || !rhs)
          return std::nullopt;
        switch (cmp.getPredicate()) {
        case arith::CmpIPredicate::eq: return *lhs == *rhs; 
        case arith::CmpIPredicate::ne: return *lhs != *rhs; 
        case arith::CmpIPredicate::slt: return *lhs < *rhs; 
        case arith::CmpIPredicate::sle: return *lhs <= *rhs; 
        case arith::CmpIPredicate::sgt: return *lhs > *rhs; 
        case arith::CmpIPredicate::sge: return *lhs >= *rhs; 
        case arith::CmpIPredicate::ult: return (uint64_t)*lhs < (uint64_t)*rhs; 
        case arith::CmpIPredicate::ule: return (uint64_t)*lhs <= (uint64_t)*rhs; 
        case arith::CmpIPredicate::ugt: return (uint64_t)*lhs > (uint64_t)*rhs; 
        case arith::CmpIPredicate::uge: return (uint64_t)*lhs >= (uint64_t)*rhs; 
        }
      }
      if (auto sel = v.getDefiningOp<arith::SelectOp>()) {
        auto c = selfB(sel.getCondition());
        if (!c) return std::nullopt;
        auto t = evalIntSelf(sel.getTrueValue());
        auto f = evalIntSelf(sel.getFalseValue());
        if (t && f)
          return *c ? (*t != 0) : (*f != 0);
      }
      return std::nullopt;
    };
    std::function<std::optional<bool>(Value)> evalBoolSelf = [&](Value v){ return evalBool(v, evalBoolSelf); };

    // 1) Fold constant scf.if (no-result only) by inlining the taken branch.
    SmallVector<scf::IfOp, 16> ifsToProcess;
    module.walk([&](scf::IfOp ifOp){ ifsToProcess.push_back(ifOp); });
    for (scf::IfOp ifOp : ifsToProcess) {
      if (ifOp.getNumResults() != 0)
        continue; // Only handle structural, no-result conditionals.
      if (!hasNetworkAncestor(ifOp))
        continue;
      auto cEval = evalBoolSelf(ifOp.getCondition());
      if (!cEval.has_value())
        continue;

      IRRewriter rewriter(&getContext());
      rewriter.setInsertionPoint(ifOp);
      Region &chosen = (*cEval) ? ifOp.getThenRegion() : ifOp.getElseRegion();
      // Inline all ops from the chosen region's single block (if present).
      if (!chosen.empty()) {
        Block &blk = chosen.front();
        for (Operation &inner : llvm::make_early_inc_range(blk)) {
          if (isa<scf::YieldOp>(&inner))
            continue;
          rewriter.clone(inner);
        }
      }
      rewriter.eraseOp(ifOp);
    }

    // 2) Fully unroll small static scf.for (no-iter-args, no-results) by cloning body.
    SmallVector<scf::ForOp, 16> forsToProcess;
    module.walk([&](scf::ForOp forOp){ forsToProcess.push_back(forOp); });
    for (scf::ForOp forOp : forsToProcess) {
      if (forOp.getNumResults() != 0 || forOp.getInitArgs().size() != 0)
        continue; // Only structural loops without carried args/results.
      if (!hasNetworkAncestor(forOp))
        continue;

      auto lbOpt = evalIntSelf(forOp.getLowerBound());
      auto ubOpt = evalIntSelf(forOp.getUpperBound());
      auto stOpt = evalIntSelf(forOp.getStep());
      if (!lbOpt || !ubOpt || !stOpt)
        continue;
      int64_t lb = *lbOpt;
      int64_t ub = *ubOpt;
      int64_t st = *stOpt;
      if (st <= 0)
        continue;
      int64_t tripCount = (ub <= lb) ? 0 : ((ub - lb + st - 1) / st);
      if (tripCount < 0 || tripCount > 8)
        continue; // Be conservative for now.

      IRRewriter rewriter(&getContext());
      rewriter.setInsertionPoint(forOp);
      // Clone body tripCount times. Maintain intra-body SSA mapping per iteration
      // so that operands refer to the cloned defs, avoiding dangling uses of the
      // original ops when the loop is erased.
      if (!forOp.getBody()->empty()) {
        Block &body = *forOp.getBody();
        SmallVector<Operation *, 16> originalOps;
        for (Operation &inner : body) {
          if (isa<scf::YieldOp>(inner))
            continue;
          originalOps.push_back(&inner);
        }
        for (int64_t i = 0; i < tripCount; ++i) {
          IRMapping map; // fresh per iteration; structural loop has no carried args
          // Map the loop IV to a constant value for this iteration.
          Value ivConst = rewriter.create<arith::ConstantIndexOp>(forOp.getLoc(), lb + i * st);
          map.map(body.getArgument(0), ivConst);
          for (Operation *orig : originalOps) {
            Operation *cloned = rewriter.clone(*orig, map);
            // Record result mapping so later ops in the same iteration use cloned defs.
            for (auto [oRes, cRes] : llvm::zip(orig->getResults(), cloned->getResults()))
              map.map(oRes, cRes);
          }
        }
      }
      rewriter.eraseOp(forOp);
    }

    // 3) Special-case unroll array-builder scf.for with single iter_arg when trip count is a small constant.
    SmallVector<scf::ForOp, 16> arrayBuilderFors;
    module.walk([&](scf::ForOp forOp){ arrayBuilderFors.push_back(forOp); });
    for (scf::ForOp forOp : arrayBuilderFors) {
      if (!hasNetworkAncestor(forOp))
        continue;
      // Must have exactly one iter_arg and one result of instance.array type.
      if (forOp.getInitArgs().size() != 1 || forOp.getNumResults() != 1)
        continue;
      auto arrTy = forOp.getResult(0).getType().dyn_cast<cal::InstanceArrayType>();
      if (!arrTy)
        continue;
      // Require 0 lower bound and step 1 and constant upper bound.
      auto lbOpt2 = evalIntSelf(forOp.getLowerBound());
      auto ubOpt2 = evalIntSelf(forOp.getUpperBound());
      auto stOpt2 = evalIntSelf(forOp.getStep());
      if (!lbOpt2 || !ubOpt2 || !stOpt2)
        continue;
      int64_t lb = *lbOpt2;
      int64_t ub = *ubOpt2;
      int64_t st = *stOpt2;
      if (lb != 0 || st != 1)
        continue;
      int64_t tripCount = std::max<int64_t>(0, ub);
      if (tripCount < 0 || tripCount > 16)
        continue; // Be conservative.

      // Heuristically check body has exactly one instantiate and one array.set and yields the array.
      if (forOp.getBody()->empty())
        continue;
      Operation *instantiateOp = nullptr;
      Operation *arraySetOp = nullptr;
      for (Operation &inner : *forOp.getBody()) {
        if (isa<scf::YieldOp>(inner))
          continue;
        if (isa<cal::InstantiateOp>(inner)) {
          if (instantiateOp) { instantiateOp = nullptr; break; }
          instantiateOp = &inner;
          continue;
        }
        if (isa<cal::InstanceArraySetOp>(inner)) {
          if (arraySetOp) { arraySetOp = nullptr; break; }
          arraySetOp = &inner;
          continue;
        }
        // Unknown op in body, skip pattern.
        instantiateOp = nullptr;
        arraySetOp = nullptr;
        break;
      }
      if (!instantiateOp || !arraySetOp)
        continue;

      // Create a new statically-sized init and unroll.
      IRRewriter rewriter(&getContext());
      rewriter.setInsertionPoint(forOp);

  auto cTrip = rewriter.create<arith::ConstantIndexOp>(forOp.getLoc(), tripCount);

  // Build a new array type with static extent using the same actorRef.
  auto ctx = &getContext();
  SmallVector<Attribute, 1> dimsAttrs;
  dimsAttrs.push_back(IntegerAttr::get(IntegerType::get(ctx, 64), tripCount));
  auto newShape = ArrayAttr::get(ctx, dimsAttrs);
  auto newArrTy = cal::InstanceArrayType::get(ctx, arrTy.getActorRef(), newShape);

  Value cur = rewriter.create<cal::InstanceArrayInitOp>(forOp.getLoc(), newArrTy, ValueRange{cTrip});

      // We'll clone the instantiate op N times and set into array at constant index.
      for (int64_t i = 0; i < tripCount; ++i) {
        auto cIdx = rewriter.create<arith::ConstantIndexOp>(forOp.getLoc(), i);
        // Clone instantiate op.
        IRMapping mapping;
        // Map the loop IV to the constant index for any potential use.
        mapping.map(forOp.getInductionVar(), cIdx);
        // Map the carried array arg to current accumulator.
        mapping.map(forOp.getRegionIterArg(0), cur);
        Operation *newInst = rewriter.clone(*instantiateOp, mapping);
        // newInst should produce a single !cal.instance result.
        Value instVal = newInst->getResult(0);
  cur = rewriter.create<cal::InstanceArraySetOp>(forOp.getLoc(), newArrTy, cur, ValueRange{cIdx}, instVal);
      }

      // Replace uses of the loop result with the built array and erase the loop.
      rewriter.replaceAllUsesWith(forOp.getResult(0), cur);
      rewriter.eraseOp(forOp);
    }
  }
};
} // namespace

} // namespace mlir

std::unique_ptr<mlir::Pass> mlir::createElaborateScfStructuresPass() {
  return std::make_unique<mlir::ElaborateScfStructuresPass>();
}
