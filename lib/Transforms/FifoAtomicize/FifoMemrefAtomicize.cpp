//===- FifoMemrefAtomicize.cpp - Atomicize FIFO memref operations -------===//
//
// This file implements a pass that converts regular memref.load and memref.store
// operations on FIFO counter metadata to atomic operations for thread safety.
//
//===----------------------------------------------------------------------===//

#include "Transforms/FifoAtomicize/FifoAtomicize.h"
#include "Dialect/Fifo/FifoOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Support/LogicalResult.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "llvm/ADT/SetVector.h"

using namespace mlir;

namespace {

/// Pattern to convert memref.load on FIFO counters to atomic loads
class AtomicizeMemrefLoads : public OpRewritePattern<memref::LoadOp> {
  const llvm::SetVector<Value> &fifoCounterMemrefs;

public:
  AtomicizeMemrefLoads(MLIRContext *context, const llvm::SetVector<Value> &counterMemrefs)
    : OpRewritePattern<memref::LoadOp>(context), fifoCounterMemrefs(counterMemrefs) {}

  LogicalResult matchAndRewrite(memref::LoadOp loadOp,
                               PatternRewriter &rewriter) const override {
    // Check if this load accesses a FIFO counter memref
    Value memref = loadOp.getMemRef();
    
    if (!fifoCounterMemrefs.contains(memref)) {
      return failure(); // Not a FIFO counter access
    }

    // Only atomicize i64 loads (FIFO counters should be i64 in SPSC mode)
    auto memrefType = mlir::cast<MemRefType>(memref.getType());
    if (!memrefType.getElementType().isInteger(64)) {
      return failure();
    }

    // For atomic loads, we use atomic_rmw with "maxu" operation where we pass
    // 0 as operand - this effectively returns the current value (atomic load)
    auto zero = rewriter.create<arith::ConstantOp>(loadOp.getLoc(), 
        loadOp.getResult().getType(), rewriter.getIntegerAttr(loadOp.getResult().getType(), 0));
    
    auto atomicLoad = rewriter.create<memref::AtomicRMWOp>(
        loadOp.getLoc(),
        arith::AtomicRMWKind::maxu,  // max with 0 returns the current value
        zero.getResult(),
        loadOp.getMemRef(),
        loadOp.getIndices()
    );

    rewriter.replaceOp(loadOp, atomicLoad.getResult());
    return success();
  }
};

/// Pattern to convert memref.store on FIFO counters to atomic stores
class AtomicizeMemrefStores : public OpRewritePattern<memref::StoreOp> {
  const llvm::SetVector<Value> &fifoCounterMemrefs;

public:
  AtomicizeMemrefStores(MLIRContext *context, const llvm::SetVector<Value> &counterMemrefs)
    : OpRewritePattern<memref::StoreOp>(context), fifoCounterMemrefs(counterMemrefs) {}

  LogicalResult matchAndRewrite(memref::StoreOp storeOp,
                               PatternRewriter &rewriter) const override {
    // Check if this store accesses a FIFO counter memref
    Value memref = storeOp.getMemRef();
    
    if (!fifoCounterMemrefs.contains(memref)) {
      return failure(); // Not a FIFO counter access
    }

    // Only atomicize i64 stores (FIFO counters should be i64 in SPSC mode)
    auto memrefType = mlir::cast<MemRefType>(memref.getType());
    if (!memrefType.getElementType().isInteger(64)) {
      return failure();
    }

    // For atomic stores, we use atomic_rmw with "assign" operation 
    rewriter.create<memref::AtomicRMWOp>(
        storeOp.getLoc(),
        arith::AtomicRMWKind::assign,  // assign effectively does an atomic store
        storeOp.getValue(),
        storeOp.getMemRef(),
        storeOp.getIndices()
    );

    rewriter.eraseOp(storeOp);
    return success();
  }
};

/// Pass implementation for FIFO memref atomicization.
///
/// This pass works in two phases:
/// 1. Analysis phase: Identify FIFO counter memrefs by looking for specific
///    allocation patterns (memref.alloc of type memref<2xi64>)
/// 2. Transform phase: Convert all memref.load and memref.store operations
///    on identified FIFO counter memrefs to atomic operations
class FifoMemrefAtomicizePass
    : public PassWrapper<FifoMemrefAtomicizePass, OperationPass<func::FuncOp>> {
public:
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(FifoMemrefAtomicizePass)

  StringRef getArgument() const final { return "fifo-memref-atomicize"; }
  StringRef getDescription() const final {
    return "Atomicize FIFO counter memref operations for thread safety";
  }

  void runOnOperation() final {
    func::FuncOp func = getOperation();
    llvm::SetVector<Value> fifoCounterMemrefs;

    // Phase 1: Identify FIFO counter memrefs
    func.walk([&](memref::AllocOp allocOp) {
      auto memrefType = mlir::dyn_cast<MemRefType>(allocOp.getType());
      if (!memrefType) return;
      
      // Look for memref<2xi64> allocations (FIFO metadata in SPSC mode)
      if (memrefType.getShape().size() == 1 && 
          memrefType.getShape()[0] == 2 && 
          memrefType.getElementType().isInteger(64)) {
        fifoCounterMemrefs.insert(allocOp.getResult());
        // Debug: llvm::outs() << "Found FIFO counter memref: " << allocOp.getResult() << "\n";
      }
    });

    if (fifoCounterMemrefs.empty()) {
      // No FIFO counter memrefs found, nothing to do
      return;
    }

    // Phase 1.5: Enhanced tuple tracing for FIFO counter memrefs
    // This expands our set to include values derived from original FIFO counter memrefs
    llvm::SetVector<Value> allFifoCounterValues = fifoCounterMemrefs;
    
    // Keep expanding until no new values are found (fixed-point iteration)
    bool changed = true;
    while (changed) {
      changed = false;
      
      // Walk all operations in the function to find tuple operations
      func.walk([&](Operation *op) {
        // Look for fifo.get_tuple_element operations
        if (op->getName().getStringRef() == "fifo.get_tuple_element") {
          Value tuple = op->getOperand(0);  // First operand is the tuple
          Value result = op->getResult(0);   // Result is the extracted value
          
          // Look for fifo.make_tuple operations that created this tuple
          if (auto makeTupleOp = tuple.getDefiningOp()) {
            if (makeTupleOp->getName().getStringRef() == "fifo.make_tuple") {
              // Check if any input to the make_tuple is a tracked FIFO counter memref
              for (Value input : makeTupleOp->getOperands()) {
                if (allFifoCounterValues.contains(input)) {
                  // This tuple contains a FIFO counter memref
                  // Check if this get_tuple_element extracts a memref<2xi64>
                  if (auto resultType = mlir::dyn_cast<MemRefType>(result.getType())) {
                    if (resultType.getShape().size() == 1 && 
                        resultType.getShape()[0] == 2 && 
                        resultType.getElementType().isInteger(64)) {
                      // This extracts the FIFO counter memref from the tuple
                      if (allFifoCounterValues.insert(result)) {
                        changed = true;
                      }
                    }
                  }
                  break;
                }
              }
            }
          }
        }
      });
    }

    // Phase 2: Apply atomic conversion patterns
    RewritePatternSet patterns(&getContext());
    patterns.add<AtomicizeMemrefLoads>(&getContext(), allFifoCounterValues);
    patterns.add<AtomicizeMemrefStores>(&getContext(), allFifoCounterValues);

    if (failed(applyPatternsGreedily(func, std::move(patterns)))) {
      signalPassFailure();
    }
  }
};

} // namespace

/// Creates a pass to atomicize FIFO counter memref operations.
std::unique_ptr<mlir::Pass> mlir::createFifoMemrefAtomicizePass() {
  return std::make_unique<FifoMemrefAtomicizePass>();
}