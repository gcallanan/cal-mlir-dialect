#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Rewrite/FrozenRewritePatternSet.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

#include "Transforms/DenseConstantsToGPU/DenseConstantsToGPU.h"
#include "Transforms/Passes.h"

namespace mlir {

#define GEN_PASS_DEF_DENSECONSTANTSTOGPUPASS
#include "Transforms/Passes.h.inc"

// This class defines a rewrite pattern for the arith.constant operation. Its goal is
// to transform dense tensor constants into GPU memory allocations with explicit
// element-by-element initialization. The pattern allocates both host and GPU memory,
// stores each constant element individually to the host memory, then copies the data
// to GPU memory before deallocating the host memory and returning a tensor view of
// the GPU allocation.
//
// Input example:
//   %cst_0 = arith.constant dense<[[[1.100000e-03, 9.988000e-01, 1.000000e-04]]]> : tensor<1x1x3xf64>
//
// Transformed output:
//   %cst_0 = arith.constant 1.100000e-03 : f64
//   %cst_1 = arith.constant 9.988000e-01 : f64
//   %cst_2 = arith.constant 1.000000e-04 : f64
//   %c0 = arith.constant 0 : index
//   %c1 = arith.constant 1 : index
//   %c2 = arith.constant 2 : index
//   %alloc = memref.alloc() : memref<1x1x3xf64>
//   %memref = gpu.alloc() : memref<1x1x3xf64>
//   memref.store %cst_0, %alloc[%c0, %c0, %c0] : memref<1x1x3xf64>
//   memref.store %cst_1, %alloc[%c0, %c0, %c1] : memref<1x1x3xf64>
//   memref.store %cst_2, %alloc[%c0, %c0, %c2] : memref<1x1x3xf64>
//   gpu.memcpy %memref, %alloc : memref<1x1x3xf64>, memref<1x1x3xf64>
//   memref.dealloc %alloc : memref<1x1x3xf64>
//   %tensor = bufferization.to_tensor %memref : memref<1x1x3xf64> -> tensor<1x1x3xf64>
//
struct ConstantToGPUAllocPattern : public OpRewritePattern<arith::ConstantOp> {
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(arith::ConstantOp op,
                                PatternRewriter &rewriter) const override {
    // Only process ranked tensor constants
    auto tensorType = op.getResult().getType().dyn_cast<RankedTensorType>();
    if (!tensorType)
      return failure();

    // Only process dense element attributes
    auto attr = op.getValue().dyn_cast<DenseElementsAttr>();
    if (!attr)
      return failure();

    auto memrefType =
        MemRefType::get(tensorType.getShape(), tensorType.getElementType());
    auto loc = op.getLoc();

    // 1. Allocate host and GPU memory
    auto hostAlloc = rewriter.create<memref::AllocOp>(loc, memrefType);
    auto gpuAlloc = rewriter.create<gpu::AllocOp>(
        loc, memrefType, /*asyncToken=*/Type(),
        /*asyncDependencies=*/ValueRange(),
        /*dynamicSizes=*/ValueRange(), /*symbolOperands=*/ValueRange(),
        /*hostShared=*/false);

    // 2. Write each element to the host memref
    for (auto it = attr.value_begin<Attribute>(), 
              end = attr.value_end<Attribute>(); 
         it != end; ++it) {
      auto idx = std::distance(attr.value_begin<Attribute>(), it);
      SmallVector<Value, 4> indices;
      int64_t offset = idx;
      
      // Calculate multi-dimensional indices from linear index
      for (int64_t d = tensorType.getRank() - 1; d >= 0; --d) {
        int64_t dim = tensorType.getDimSize(d);
        indices.insert(indices.begin(), 
                      rewriter.create<arith::ConstantIndexOp>(loc, offset % dim));
        offset /= dim;
      }
      
      auto valueAttr = *it;
      auto value = rewriter.create<arith::ConstantOp>(
          loc, valueAttr.cast<TypedAttr>());
      rewriter.create<memref::StoreOp>(
          loc, value, hostAlloc.getResult(), indices);
    }

    // 3. Copy data from host to GPU memory
    rewriter.create<gpu::MemcpyOp>(loc,
                                   /*asyncToken=*/Type(),
                                   /*asyncDependencies=*/ValueRange(),
                                   /*dst=*/gpuAlloc.getResult(0),
                                   /*src=*/hostAlloc.getResult());

    // 4. Deallocate host memory
    rewriter.create<memref::DeallocOp>(loc, hostAlloc.getResult());
    
    // 5. Convert GPU memref back to tensor and add restrict attribute
    auto tensorRes = rewriter.create<bufferization::ToTensorOp>(
        loc, tensorType, gpuAlloc.getResult(0));
    tensorRes->setAttr("restrict", rewriter.getUnitAttr());

    rewriter.replaceOp(op, tensorRes);
    return success();
  }
};


// This pass transforms dense tensor constants into GPU memory allocations.
// It applies the ConstantToGPUAllocPattern to convert arith.constant operations
// with dense tensor values into explicit GPU memory allocations with
// element-by-element initialization.
class DenseConstantsToGpuPass
    : public impl::DenseConstantsToGpuPassBase<DenseConstantsToGpuPass> {
public:
  void runOnOperation() override {

    auto *ctx = &getContext();
    RewritePatternSet patterns(ctx);
    patterns.add<ConstantToGPUAllocPattern>(ctx);
    if (failed(applyPatternsGreedily(getOperation(), std::move(patterns))))
      signalPassFailure();
  }
};
} // namespace mlir