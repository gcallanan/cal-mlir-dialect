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

def HoistAllocsPass : Pass<"hoist-allocs"> {
    let summary = "Hoist memory allocations from called functions to their call sites in the main function to reduce allocation overhead";
    let description = [{
        This pass optimizes memory allocation patterns by moving expensive allocation 
        operations from frequently-called functions to their call sites in the main function. 
        It targets `memref.alloc`, `gpu.alloc`, and `arith.constant` operations with dense 
        tensor attributes that would otherwise be repeated in execution loops.

        The pass specifically looks for the main function containing an `scf.while` loop 
        and identifies all callee functions called within that loop. This is particularly 
        beneficial for CAL actors that have been lowered to functions, where the same 
        allocations would occur on every loop iteration.

        The transformation operates in two phases:
        1. **Call Site Update**: Clones allocation operations from target functions to the 
           main function's entry block and updates call sites to pass these allocations 
           as additional operands.
        2. **Function Signature Update**: Modifies target functions to accept hoisted 
           allocations as parameters and removes the original allocation operations from 
           their bodies.

        This optimization significantly reduces allocation overhead, especially for expensive 
        GPU allocations, by performing allocations once rather than repeatedly in loops.

        Prerequisites: Run after CAL actors have been lowered to functions.

        Description originally written by Gareth Callanan and refined using ChatGPT.
    }];

    let dependentDialects = [
        "mlir::gpu::GPUDialect",
        "mlir::memref::MemRefDialect",
        "mlir::bufferization::BufferizationDialect",
        "mlir::arith::ArithDialect",
        "mlir::tensor::TensorDialect"
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