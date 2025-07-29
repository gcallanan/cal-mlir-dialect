#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Rewrite/FrozenRewritePatternSet.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

#include "Transforms/Passes.h"
#include "Transforms/CalPrepareGpuAsyncRegions/CalPrepareGpuAsyncRegions.h"

namespace mlir {

#define GEN_PASS_DEF_CALPREPAREGPUASYNCREGIONSPASS
#include "Transforms/Passes.h.inc"

class CalPrepareGpuAsyncRegionsPass : public impl::CalPrepareGpuAsyncRegionsPassBase<CalPrepareGpuAsyncRegionsPass> {
public:
  void runOnOperation() override {
    // Find the @main function
    mlir::func::FuncOp mainFunc = nullptr;
    getOperation()->walk([&](mlir::func::FuncOp funcOp) {
      if (funcOp.getName() == "main") {
        mainFunc = funcOp;
        return WalkResult::interrupt();
      }
      return WalkResult::advance();
    });

    if (!mainFunc) {
      // We skip the pass if no main function is found
      return;
    }

    // // Find the last occurring scf::WhileOp directly under the main function
    // scf::WhileOp lastWhileOp = nullptr;
    // for (auto whileOp : mainFunc.getBody().front().getOps<scf::WhileOp>()) {
    //   lastWhileOp = whileOp;
    // }
    // if (!lastWhileOp) {
    //   // We skip the pass if no scf::WhileOp is found
    //   return;
    // }

    // // Collect all callee functions from the last while loop
    // auto module = mainFunc->getParentOfType<ModuleOp>();
    // SmallVector<func::FuncOp, 8> callees;
    // for (auto funcCall : lastWhileOp.getAfterBody()->getOps<func::CallOp>()) {
    //   auto callee = module.lookupSymbol<func::FuncOp>(funcCall.getCallee());
    //   if (!callee) {
    //     mlir::emitError(funcCall.getLoc(), "Callee function not found: ")
    //         << funcCall.getCallee();
    //     signalPassFailure();
    //   }
    //   callees.push_back(callee);
    // }

    // auto *ctx = &getContext();

    // // First pass: Update call operations to include cloned allocations
    // RewritePatternSet patterns1(ctx);
    // patterns1.add<UpdateCallOpPattern>(ctx, callees, mainFunc);

    // if (failed(applyPatternsGreedily(getOperation(), std::move(patterns1)))) {
    //   signalPassFailure();
    // }

    // // Second pass: Hoist allocations from function bodies to parameters
    // RewritePatternSet patterns2(ctx);
    // patterns2.add<HoistAllocsFromFuncPattern>(ctx, callees);

    // if (failed(applyPatternsGreedily(getOperation(), std::move(patterns2)))) {
    //   signalPassFailure();
    // }
  }
};
} // namespace mlir
