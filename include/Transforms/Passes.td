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

def DenseConstantsToGpuPass : Pass<"convert-dense-constant-to-gpu"> {
    let summary = "Transform dense tensor constants into GPU memory allocations.";
    let description = [{
        This pass transforms arith.constant operations with dense tensor values
        into explicit GPU memory allocations with element-by-element initialization.
        
        The pass is necessary because dense tensor constants would normally be
        allocated to host memory during the bufferization pass. By transforming
        them beforehand, we ensure they are placed in GPU memory.
        
        The transformation process:
        1. Allocates both host and GPU memory buffers
        2. Stores each constant element individually to the host buffer
        3. Copies the data from host to GPU memory
        4. Deallocates the host buffer
        5. Returns a tensor view of the GPU-allocated memory
        
        Input:
          %cst = arith.constant dense<[1.0, 2.0, 3.0]> : tensor<3xf64>
        
        Output:
          %alloc_host = memref.alloc() : memref<3xf64>
          %alloc_gpu = gpu.alloc() : memref<3xf64>
          // ... individual stores for each element ...
          gpu.memcpy %alloc_gpu, %alloc_host : memref<3xf64>, memref<3xf64>
          memref.dealloc %alloc_host : memref<3xf64>
          %tensor = bufferization.to_tensor %alloc_gpu : memref<3xf64>
    }];
    
    let dependentDialects = [
        "mlir::gpu::GPUDialect",
        "mlir::tensor::TensorDialect",
        "mlir::memref::MemRefDialect",
        "mlir::bufferization::BufferizationDialect"
    ];
}

#endif // CAL_TRANSFORM_PASSES