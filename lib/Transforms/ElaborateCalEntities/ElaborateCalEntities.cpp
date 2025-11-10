#include "Transforms/Passes.h"
#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/Pass/Pass.h"

namespace mlir {
#define GEN_PASS_DEF_ELABORATECALENTITIESPASS
#include "Transforms/Passes.h.inc"
} // namespace mlir

using namespace mlir;
using namespace mlir::cal;

namespace {

// Simple utilities to check constant loop bounds (evaluate small arith trees).
static std::optional<int64_t> evalConstIndex(Value v) {
  if (auto cIdx = v.getDefiningOp<arith::ConstantIndexOp>())
    return cIdx.value();
  if (auto c = v.getDefiningOp<arith::ConstantOp>()) {
    if (auto intAttr = dyn_cast<IntegerAttr>(c.getValue()))
      return intAttr.getInt();
  }
  if (auto cast = v.getDefiningOp<arith::IndexCastOp>())
    return evalConstIndex(cast.getIn());
  if (auto addi = v.getDefiningOp<arith::AddIOp>()) {
    auto a = evalConstIndex(addi.getLhs());
    auto b = evalConstIndex(addi.getRhs());
    if (a && b) return *a + *b;
  }
  if (auto subi = v.getDefiningOp<arith::SubIOp>()) {
    auto a = evalConstIndex(subi.getLhs());
    auto b = evalConstIndex(subi.getRhs());
    if (a && b) return *a - *b;
  }
  if (auto muli = v.getDefiningOp<arith::MulIOp>()) {
    auto a = evalConstIndex(muli.getLhs());
    auto b = evalConstIndex(muli.getRhs());
    if (a && b) return *a * *b;
  }
  return std::nullopt;
}

struct ElaborateCalEntitiesPass : public impl::ElaborateCalEntitiesPassBase<ElaborateCalEntitiesPass> {
  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<mlir::scf::SCFDialect, mlir::cal::CalDialect, mlir::arith::ArithDialect>();
  }

  void runOnOperation() override {
    ModuleOp mod = getOperation();

    // Collect candidate loops first (avoid iterator invalidation).
    SmallVector<scf::ForOp> candidates;
    mod.walk([&](scf::ForOp forOp) {
      // Require exactly one iter_arg that is an instance array.
      if (!forOp.getInitArgs().size()) return; // must carry array
      if (forOp.getInitArgs().size() != 1) return; // v1 constraint
      Value initVal = forOp.getInitArgs().front();
      auto arrInit = initVal.getDefiningOp<cal::InstanceArrayInitOp>();
      if (!arrInit) return; // pattern: iter arg originates from array.init
      Type arrTy = arrInit.getResult().getType();
      if (!isa<cal::InstanceArrayType>(arrTy)) return; // concrete arrays only v1
      // Constant bounds only.
  auto lb = evalConstIndex(forOp.getLowerBound());
  auto ub = evalConstIndex(forOp.getUpperBound());
  auto step = evalConstIndex(forOp.getStep());
      if (!(lb && ub && step) || *step <= 0) return;
      candidates.push_back(forOp);
    });

    if (candidates.empty()) return; // Nothing to do.

    // Process each loop: inline body iterations sequentially and rebuild array sets.
    for (scf::ForOp forOp : candidates) {
  auto lb = *evalConstIndex(forOp.getLowerBound());
  auto ub = *evalConstIndex(forOp.getUpperBound());
  auto step = *evalConstIndex(forOp.getStep());
      int64_t tripCount = (ub - lb + step - 1) / step; // ceil_div
      if (tripCount <= 0) continue;

      OpBuilder builder(forOp);
      Location loc = forOp.getLoc();

      // Start with the original init array value.
      Value curArray = forOp.getInitArgs().front();

      // Inline body per iteration with constant iv substitution.
      IRMapping mapper;
      // Map block arguments (iv, iter_arg) each iteration separately.
      Block &body = *forOp.getBody();
      Value iterArg = body.getArgument(1);

      for (int64_t i = 0; i < tripCount; ++i) {
        // Create constant iv for this iteration.
        Value ivConst = builder.create<arith::ConstantIndexOp>(loc, lb + i * step);
        mapper.map(body.getArgument(0), ivConst); // map induction variable
        mapper.map(iterArg, curArray);            // current array state

        // Clone all operations except yield.
        for (Operation &inner : body.getOperations()) {
          if (isa<scf::YieldOp>(inner)) continue;
          Operation *cloned = builder.clone(inner, mapper);
          // Update mapping for results (e.g., array.set result becomes new array state).
          for (auto [orig, neu] : llvm::zip(inner.getResults(), cloned->getResults()))
            mapper.map(orig, neu);
        }
        // Retrieve the yielded array value for next iteration.
        auto yieldOp = cast<scf::YieldOp>(body.getTerminator());
        Value yielded = mapper.lookupOrDefault(yieldOp.getResults().front());
        curArray = yielded;
        mapper.clear(); // fresh mapping next iteration
      }

      // Replace the loop with final array value.
      forOp.getResult(0).replaceAllUsesWith(curArray);
      forOp.erase();
    }
  }
};

} // namespace

std::unique_ptr<mlir::Pass> mlir::createElaborateCalEntitiesPass() {
  return std::make_unique<ElaborateCalEntitiesPass>();
}
