//===- Passes.td - GPU-Aware Bufferization Pass Definition ----*- tablegen -*-===//
//
// This file defines the GpuAwareBufferizePass for MLIR.
//
//===----------------------------------------------------------------------===//

#ifndef CAL_TRANSFORM_PASSES
#define CAL_TRANSFORM_PASSES

include "mlir/Pass/PassBase.td"

def GpuAwareBufferizePass : Pass<"gpu-aware-bufferize", "mlir::ModuleOp"> {
    let summary = "Run One-Shot Bufferization with GPU memory support.";
    let description = [{
        This pass runs One-Shot Bufferization with GPU memory allocation support.
        It overrides the default allocation behavior to use `gpu.alloc` operations
        for tensor-to-memref conversion, ensuring all allocations are placed in
        GPU memory with host-shared access.

        Specifically:
        - All tensor types are converted to equivalent memref types.
        - Memory allocations use `gpu.alloc` with the `host_shared` attribute.
        - Function boundaries are properly bufferized.
        - Operations work directly on GPU-allocated memrefs.

        As of 2025/07/17, MLIR's One-Shot Bufferization does not natively support
        GPU memory allocation. This pass provides a workaround by customizing the
        allocation behavior, wrapping One-Shot Bufferization and ensuring tensors
        are allocated in GPU memory. Ideally, this should be part of the upstream
        bufferization pass, but until then, this pass serves as a practical solution.
    }];
    let constructor = "mlir::createGpuAwareBufferizePass()";
    let dependentDialects = [
        "mlir::gpu::GPUDialect",
        "mlir::memref::MemRefDialect",
        "mlir::bufferization::BufferizationDialect"
    ];
}

#endif // CAL_TRANSFORM_PASSES