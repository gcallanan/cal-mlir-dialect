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
#include "Transforms/HoistAllocs/HoistAllocs.h"

namespace mlir {

#define GEN_PASS_DEF_HOISTALLOCSPASS
#include "Transforms/Passes.h.inc"

/// Collect all allocation-related operations within a function that should be
/// hoisted.
///
/// This function walks through the entire body of the given function and
/// identifies operations that represent memory allocations or expensive
/// constant materializations that would benefit from being hoisted out of
/// frequently-called functions.
///
/// The function collects three types of operations:
/// 1. memref::AllocOp - Standard memref allocations that may be expensive to
/// repeat
/// 2. gpu::AllocOp - GPU memory allocations which are particularly costly
/// 3. arith::ConstantOp with dense tensor attributes - Large constant tensors
/// that would otherwise be materialized repeatedly during each function call
///
/// @param funcOp The function to analyze for allocation-related operations
/// @return A vector of pointers to operations that should be hoisted to reduce
///         allocation overhead in repeated function calls
static SmallVector<Operation *, 8> getAllocRelatedOps(func::FuncOp funcOp) {
  SmallVector<Operation *, 8> allocRelatedOps;
  funcOp.walk([&](Operation *op) {
    if (isa<memref::AllocOp>(op) || isa<gpu::AllocOp>(op)) {
      allocRelatedOps.push_back(op);
    } else if (auto constOp = dyn_cast<arith::ConstantOp>(op)) {
      auto tensorType =
          mlir::dyn_cast<RankedTensorType>(constOp.getResult().getType());
      auto attr = mlir::dyn_cast<DenseElementsAttr>(constOp.getValue());
      if (tensorType && attr) {
        allocRelatedOps.push_back(op);
      }
    }
  });
  return allocRelatedOps;
}

/// Pattern to hoist allocation-related operations from function bodies to
/// function parameters.
///
/// This pattern implements the second phase of the allocation hoisting
/// optimization by transforming target functions to accept their allocation
/// operations as parameters instead of creating them internally. This
/// eliminates repeated allocations when functions are called multiple times in
/// loops.
///
/// The transformation process:
/// 1. Identifies all allocation-related operations within the target function
/// 2. Converts each allocation result into a new function parameter by adding
///    block arguments to the function's entry block
/// 3. Replaces all uses of the original allocation operations with the new
/// parameters
/// 4. Removes the original allocation operations from the function body
/// 5. Updates the function signature to include the new parameter types
///
/// This pattern only operates on functions that are in the target functions
/// list, which typically consists of functions called within the main
/// function's execution loop.
///
/// Example transformation:
/// Input:
///   func.func @worker(%arg0: memref<2xi32>) -> i1 {
///     %alloc = gpu.alloc() : memref<4xi32>
///     // ... use %alloc ...
///   }
///
/// Output:
///   func.func @worker(%arg0: memref<2xi32>, %arg1: memref<4xi32>) -> i1 {
///     // ... use %arg1 instead of %alloc ...
///   }
///
/// This pattern must be applied after UpdateCallOpPattern has already updated
/// the call sites to provide the hoisted allocations as arguments.
struct HoistAllocsFromFuncPattern : public OpRewritePattern<func::FuncOp> {
  SmallVector<func::FuncOp, 8> &targetFunctions;

public:
  HoistAllocsFromFuncPattern(MLIRContext *ctx,
                             SmallVector<func::FuncOp, 8> &callees)
      : OpRewritePattern(ctx), targetFunctions(callees) {}

  LogicalResult matchAndRewrite(func::FuncOp op,
                                PatternRewriter &rewriter) const override {
    // Check if this function is one of the target functions
    for (const auto &callee : targetFunctions) {
      if (op == callee) {
        return hoistAllocsFromFunction(rewriter, op);
      }
    }
    return failure();
  }

private:
  LogicalResult hoistAllocsFromFunction(PatternRewriter &rewriter,
                                        func::FuncOp funcOp) const {
    // Get the entry block of the function
    Block &entryBlock = funcOp.getBody().front();
    auto currentFuncType = funcOp.getFunctionType();
    SmallVector<Type, 8> newInputTypes(currentFuncType.getInputs().begin(),
                                       currentFuncType.getInputs().end());

    // Get all allocation-related operations in the function body
    SmallVector<Operation *, 8> allocRelatedOps = getAllocRelatedOps(funcOp);

    if (allocRelatedOps.empty()) {
      return failure();
    }

    // Hoist each allocation-related operation to the entry block
    // and replace uses in the function body
    for (Operation *op : allocRelatedOps) {
      SmallVector<BlockArgument, 4> newArgs;
      for (Value result : op->getResults()) {
        Type resultType = result.getType();
        BlockArgument newArg =
            entryBlock.addArgument(resultType, funcOp.getLoc());
        newArgs.push_back(newArg);
        newInputTypes.push_back(resultType);
      }
      op->replaceAllUsesWith(newArgs);
    }

    // Erase the original operations after hoisting
    for (Operation *op : allocRelatedOps) {
      rewriter.eraseOp(op);
    }

    // Update the function type to include new input types
    auto newFuncType =
        rewriter.getFunctionType(newInputTypes, currentFuncType.getResults());
    funcOp.setType(newFuncType);

    return success();
  }
};

/// Pattern to update function call operations to include hoisted allocations as
/// additional operands.
///
/// This pattern implements the first phase of the allocation hoisting
/// optimization by modifying call sites in the main function to pass
/// pre-allocated memory as arguments to the called functions. This prevents
/// repeated allocations during function execution loops, particularly for CAL
/// actors that have been lowered to functions.
///
/// The transformation process:
/// 1. Identifies call operations within the main function that call target
/// functions
/// 2. Analyzes the called function to find allocation-related operations that
/// need hoisting
/// 3. Clones these allocation operations at the top of the main function's
/// entry block
/// 4. Creates a new call operation with the cloned allocations as additional
/// operands
/// 5. Replaces the original call with the updated call operation
///
/// This pattern only operates on function calls within the main function that
/// target functions in the callees list (typically CAL actors converted to
/// functions). The cloned allocations are placed once in the main function and
/// reused across all iterations of the execution loop.
///
/// Example transformation:
/// Input:
///   func.func @main() {
///     scf.while() {
///       %result = func.call @worker(%data) : (memref<2xi32>) -> i1
///     }
///   }
///   func.func @worker(%arg0: memref<2xi32>) -> i1 {
///     %alloc = gpu.alloc() : memref<4xi32>
///     // ... use %alloc ...
///   }
///
/// Output:
///   func.func @main() {
///     %hoisted_alloc = gpu.alloc() : memref<4xi32>
///     scf.while() {
///       %result = func.call @worker(%data, %hoisted_alloc)
///         : (memref<2xi32>, memref<4xi32>) -> i1
///     }
///   }
///
/// This pattern must be applied before HoistAllocsFromFuncPattern, which will
/// update the called function signatures to accept the hoisted allocations as
/// parameters.
struct UpdateCallOpPattern : public OpRewritePattern<func::CallOp> {
  SmallVector<func::FuncOp, 8> &callees;
  func::FuncOp mainFunction;

  UpdateCallOpPattern(MLIRContext *ctx,
                      SmallVector<func::FuncOp, 8> &calleesList,
                      func::FuncOp main)
      : OpRewritePattern(ctx), callees(calleesList), mainFunction(main) {}

  LogicalResult matchAndRewrite(func::CallOp callOp,
                                PatternRewriter &rewriter) const override {
    // Check if callOp is inside the main function
    auto parentFunc = callOp->getParentOfType<func::FuncOp>();
    if (!parentFunc || parentFunc != mainFunction) {
      return failure();
    }

    // Check if the called function is in the callees list
    auto calleeName = callOp.getCallee();
    func::FuncOp matchedCallee = nullptr;
    for (auto &callee : callees) {
      if (callee.getName() == calleeName) {
        matchedCallee = callee;
        break;
      }
    }
    if (!matchedCallee) {
      return failure();
    }

    auto numCallOperands = callOp.getNumOperands();
    auto numFuncInputs = matchedCallee.getFunctionType().getNumInputs();
    if (numCallOperands != numFuncInputs) {
      return failure();
    }

    auto allocRelatedOps = getAllocRelatedOps(matchedCallee);
    if (allocRelatedOps.empty()) {
      return failure();
    }

    OpBuilder::InsertionGuard guard(rewriter);

    // Clone each alloc-related op at the top of the parent function's entry
    // block
    Block &entryBlock = parentFunc.getBody().front();
    rewriter.setInsertionPointToStart(&entryBlock);

    SmallVector<Value, 8> newAllocValues;

    // Helper to decide if an op is a pure, cheap arithmetic op that we
    // can safely clone at main entry to rebuild size expressions.
    auto isCloneableSizeOp = [](Operation *op) -> bool {
      return isa<arith::ConstantOp, arith::IndexCastOp, arith::AddIOp,
                 arith::SubIOp, arith::MulIOp, arith::DivSIOp, arith::DivUIOp>(op);
    };

    // Recursively ensure a value is available in the parent function by either
    // mapping a callee block argument to the corresponding call operand or by
    // cloning a small, pure arithmetic producer chain.
    std::function<Value(Value, IRMapping &)> materializeInParent =
        [&](Value v, IRMapping &map) -> Value {
          if (Value mapped = map.lookupOrNull(v))
            return mapped;
          if (auto barg = dyn_cast<BlockArgument>(v)) {
            // Map callee arg -> corresponding call operand.
            auto callee = matchedCallee;
            Block &entry = callee.getBody().front();
            unsigned idx = barg.getArgNumber();
            // Defensive checks.
            if (&entry != barg.getOwner() || idx >= callOp.getNumOperands())
              return nullptr;
            Value callerOperand = callOp.getOperand(idx);
            map.map(v, callerOperand);
            return callerOperand;
          }
          Operation *def = v.getDefiningOp();
          if (!def || !isCloneableSizeOp(def))
            return nullptr;
          // Materialize all operands first.
          SmallVector<Value, 4> clonedOperands;
          clonedOperands.reserve(def->getNumOperands());
          for (Value opnd : def->getOperands()) {
            Value m = materializeInParent(opnd, map);
            if (!m)
              return nullptr;
            clonedOperands.push_back(m);
          }
          Operation *cloned = rewriter.clone(*def, map);
          // For ops like IndexCast/AddI the IRMapping used above already
          // remaps operands; ensure result is mapped for downstream uses.
          map.map(v, cloned->getResult(0));
          return cloned->getResult(0);
        };

    for (Operation *allocOp : allocRelatedOps) {
      if (auto memAlloc = dyn_cast<memref::AllocOp>(allocOp)) {
        IRMapping map; // maps callee values -> parent values
        // Rebuild dynamic sizes in the parent.
        SmallVector<Value, 4> dynSizes;
        bool ok = true;
        for (Value sz : memAlloc.getDynamicSizes()) {
          Value m = materializeInParent(sz, map);
          if (!m) {
            ok = false;
            break;
          }
          dynSizes.push_back(m);
        }
        if (!ok) {
          // Skip hoisting this alloc if we cannot safely reconstruct sizes.
          continue;
        }
        // Create the alloc in the parent with reconstructed sizes.
        auto newAlloc = rewriter.create<memref::AllocOp>(
            allocOp->getLoc(), memAlloc.getType(), dynSizes);
        newAllocValues.push_back(newAlloc.getResult());
        continue;
      }
      if (auto gpuAlloc = dyn_cast<gpu::AllocOp>(allocOp)) {
        // GPU alloc has no dynamic sizes on the memref type; clone directly.
        Operation *cloned = rewriter.clone(*gpuAlloc);
        newAllocValues.append(cloned->result_begin(), cloned->result_end());
        continue;
      }
      if (auto constOp = dyn_cast<arith::ConstantOp>(allocOp)) {
        // Large dense constants: cloning is fine.
        Operation *cloned = rewriter.clone(*constOp);
        newAllocValues.push_back(cloned->getResult(0));
        continue;
      }
    }

    // Add the cloned allocs as extra operands to the callOp
    SmallVector<Value, 8> newOperands(callOp.getOperands().begin(),
                                      callOp.getOperands().end());
    newOperands.append(newAllocValues.begin(), newAllocValues.end());

    rewriter.setInsertionPoint(callOp);

    // Create a new callOp with the extended operands
    auto newCallOp =
      rewriter.create<func::CallOp>(callOp.getLoc(), callOp.getCallee(),
                      callOp.getResultTypes(), newOperands);

    // Replace the old callOp with the new one
    rewriter.replaceOp(callOp, newCallOp.getResults());

    return success();
  }
};

/// Pass to hoist memory allocations from actor functions to the main function
/// to reduce allocation overhead.
///
/// This pass optimizes memory allocation patterns in CAL programs that have
/// been lowered to functions by moving expensive allocation operations from
/// frequently-called actor functions to their call sites in the main function.
/// This transformation is particularly beneficial for CAL actors that execute
/// repeatedly in the main execution loop, where the same allocations would
/// otherwise occur on every iteration.
///
/// The pass operates by:
/// 1. Locating the main function and identifying the execution loop (scf.while
/// operation)
/// 2. Collecting all callee functions that are called within the loop body
/// (representing lowered CAL actors)
/// 3. Applying a two-phase transformation using rewrite patterns:
///    - First phase (UpdateCallOpPattern): Clones allocation operations from
///    callee functions to the main function's entry block and updates call
///    sites to pass these as arguments
///    - Second phase (HoistAllocsFromFuncPattern): Removes allocation
///    operations from callee functions and updates their signatures to accept
///    allocations as parameters
///
/// The pass specifically targets:
/// - memref.alloc operations (standard memory allocations)
/// - gpu.alloc operations (GPU memory allocations, which are particularly
/// expensive)
/// - arith.constant operations with dense tensor attributes (large constant
/// materializations)
///
/// This optimization assumes that the hoisted functions (originally CAL actors)
/// are executed multiple times, making the one-time allocation cost in the main
/// function worthwhile compared to repeated allocations in each function call.
///
/// Prerequisites: This pass should only be run after CAL actors have been
/// lowered to functions using passes like convert-cal-to-func, as it operates
/// on func.func operations rather than cal.actor operations.
class HoistAllocsPass : public impl::HoistAllocsPassBase<HoistAllocsPass> {
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

    // Find the last occurring scf::WhileOp directly under the main function
    scf::WhileOp lastWhileOp = nullptr;
    for (auto whileOp : mainFunc.getBody().front().getOps<scf::WhileOp>()) {
      lastWhileOp = whileOp;
    }
    if (!lastWhileOp) {
      // We skip the pass if no scf::WhileOp is found
      return;
    }

    // Collect all callee functions from the last while loop
    auto module = mainFunc->getParentOfType<ModuleOp>();
    SmallVector<func::FuncOp, 8> callees;
    for (auto funcCall : lastWhileOp.getAfterBody()->getOps<func::CallOp>()) {
      auto callee = module.lookupSymbol<func::FuncOp>(funcCall.getCallee());
      if (!callee) {
        mlir::emitError(funcCall.getLoc(), "Callee function not found: ")
            << funcCall.getCallee();
        signalPassFailure();
      }
      callees.push_back(callee);
    }

    auto *ctx = &getContext();

    // First pass: Update call operations to include cloned allocations
    RewritePatternSet patterns1(ctx);
    patterns1.add<UpdateCallOpPattern>(ctx, callees, mainFunc);

    if (failed(applyPatternsGreedily(getOperation(), std::move(patterns1)))) {
      signalPassFailure();
    }

    // Second pass: Hoist allocations from function bodies to parameters
    RewritePatternSet patterns2(ctx);
    patterns2.add<HoistAllocsFromFuncPattern>(ctx, callees);

    if (failed(applyPatternsGreedily(getOperation(), std::move(patterns2)))) {
      signalPassFailure();
    }
  }
};
} // namespace mlir
