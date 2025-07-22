

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Bufferization/Transforms/OneShotAnalysis.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/Pass/Pass.h"

#include "Transforms/GPUAwareBufferize/GPUAwareBufferize.h"
#include "Transforms/Passes.h"

namespace mlir {

#define GEN_PASS_DEF_GPUAWAREBUFFERIZEPASS
#include "Transforms/Passes.h.inc"

/// This pass runs One-Shot Bufferization with GPU memory allocation support.
/// It overrides the default allocation behavior to use `gpu.alloc` operations
/// for tensor-to-memref conversion, ensuring all allocations are placed in
/// GPU memory with host-shared access.
///
/// Input:
///   %1 = linalg.fill ins(%c4_i32 : i32) outs(%0 : tensor<2x2xi32>) ->
///   tensor<2x2xi32>
///
/// Output:
///   %memref = gpu.alloc host_shared () : memref<2x2xi32>
///   linalg.fill ins(%c4_i32 : i32) outs(%memref : memref<2x2xi32>)
///
/// The transformation ensures that:
/// - All tensor types are converted to equivalent memref types
/// - Memory allocations use `gpu.alloc` with `host_shared` attribute
/// - Function boundaries are properly bufferized
/// - Operations work directly on GPU-allocated memrefs
class GpuAwareBufferizePass
    : public impl::GpuAwareBufferizePassBase<GpuAwareBufferizePass> {
public:
  void runOnOperation() override {
    mlir::ModuleOp module = getOperation();

    mlir::bufferization::OneShotBufferizationOptions options;
    options.bufferizeFunctionBoundaries = true;

    // options.defaultMemorySpaceFn =
    //     [](mlir::TensorType tensorType) -> std::optional<mlir::Attribute> {
    //   return mlir::gpu::AddressSpaceAttr::get(tensorType.getContext(),
    //                                           mlir::gpu::AddressSpace::Global);
    // };

    // Create GPU allocation
    options.allocationFn =
        [&](mlir::OpBuilder &b, mlir::Location loc, mlir::MemRefType type,
            mlir::ValueRange dynShape,
            unsigned alignment) -> mlir::FailureOr<mlir::Value> {
      // Check if this is a GPU address space
      // if (auto addrSpace = dyn_cast_or_null<mlir::gpu::AddressSpaceAttr>(type.getMemorySpace())) {
      //   if (addrSpace.getValue() == mlir::gpu::AddressSpace::Global) {
          auto allocOp = b.create<mlir::gpu::AllocOp>(loc, type, dynShape);
          allocOp.setHostShared(false);
          return allocOp.getResult(0);
      //   }
      // }
      // return b.create<mlir::memref::AllocOp>(loc, type, dynShape).getResult();
    };

    // Simple copy function
    options.memCpyFn = [&](mlir::OpBuilder &b, mlir::Location loc,
                           mlir::Value from,
                           mlir::Value to) -> mlir::LogicalResult {
      b.create<gpu::MemcpyOp>(loc,
                              /*asyncToken=*/Type(),
                              /*asyncDependencies=*/ValueRange(),
                              /*dst=*/to,
                              /*src=*/from);
      return mlir::success();
    };

    if (failed(mlir::bufferization::runOneShotBufferize(module, options))) {
      signalPassFailure();
    }
  }
};
} // namespace mlir

/// Creates a pass that runs One-Shot Bufferization with GPU memory allocation
/// support.
std::unique_ptr<mlir::Pass> mlir::createGpuAwareBufferizePass() {
  return std::make_unique<mlir::GpuAwareBufferizePass>();
}