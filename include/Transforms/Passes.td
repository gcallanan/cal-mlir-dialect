//===- Passes.td - GPU-Aware Bufferization Pass Definition ----*- tablegen -*-===//
//
// This file defines the GpuAwareBufferizePass for MLIR.
//
//===----------------------------------------------------------------------===//

#ifndef CAL_TRANSFORM_PASSES
#define CAL_TRANSFORM_PASSES

include "mlir/Pass/PassBase.td"

def CalPrepareGpuAsyncRegionsPass : Pass<"cal-prepare-gpu-async-regions"> {
    let summary = "Thread gpu.async.tokens through main loop and callees to coordinate all asynchronous GPU operations on a single stream.";

    let description = [{
        This pass rewrites the main function and its callees to enable correct, single-stream
        asynchronous execution of GPU operations by threading `gpu.async.token` values through
        the main loop and all relevant function calls.

        The pass expects input in the format produced by earlier CAL transformation passes,
        where the main computation is structured as a `scf.while` loop and GPU operations
        are present in the main function and its callees.

        Specifically, this pass:
        - Adds a `gpu.async.token` argument and result to the main `scf.while` loop.
        - Threads the token through the loop's condition and body blocks.
        - Updates all `func.call` operations within the loop body so that they take and return
          a `gpu.async.token`, allowing GPU operations in called functions to be coordinated
          asynchronously.
        - Makes all GPU operations in the main function and its callees asynchronous and
          chained on a single stream.
        - Inserts initial and intermediate `gpu.wait` operations as needed to produce and
          synchronize the async token before and after the loop.
        - Makes all operations before the while loop asynchronous (by threading an async token),
          but synchronizes (waits) after each one to ensure completion. This is done to support
          further passes that expect all GPU ops to be asynchronous, even though these ops
          still execute synchronously from the host's perspective.

        Example main loop transformation:

        Before:
        ```mlir
        scf.while (%arg0 = %true) : (i1) -> () {
          scf.condition(%arg0)
        } do {
          %1 = func.call @src(...) : (...) -> i1
          %2 = func.call @accumulator(...) : (...) -> i1
          %3 = arith.ori %2, %1 : i1
          scf.yield %3 : i1
        }
        ```

        After:
        ```mlir
        %10 = gpu.wait async
        %11 = scf.while (%arg0 = %true, %arg1 = %10) : (i1, !gpu.async.token) -> !gpu.async.token {
          scf.condition(%arg0) %arg1 : !gpu.async.token
        } do {
        ^bb0(%arg0: !gpu.async.token):
          %12:2 = func.call @src(..., %arg0) : (..., !gpu.async.token) -> (i1, !gpu.async.token)
          %13:2 = func.call @accumulator(..., %12#1) : (..., !gpu.async.token) -> (i1, !gpu.async.token)
          %14 = arith.ori %13#0, %12#0 : i1
          scf.yield %14, %13#1 : i1, !gpu.async.token
        }
        ```

        Example callee transformation:

        Before:
        ```mlir
        func.func @accumulator(%arg0: i32, %arg1: memref<10x10xi32>) -> i1 {
          %0 = gpu.launch_func @kernel ...
          %1 = gpu.memcpy %arg1, %arg1 : memref<10x10xi32>, memref<10x10xi32>
          return %true : i1
        }
        ```

        After:
        ```mlir
        func.func @accumulator(%arg0: i32, %arg1: memref<10x10xi32>, %token: !gpu.async.token) -> (i1, !gpu.async.token) {
          %0 = gpu.launch_func async [%token] @kernel ...
          %1 = gpu.memcpy async [%0] %arg1, %arg1 : memref<10x10xi32>, memref<10x10xi32>
          return %true, %1 : i1, !gpu.async.token
        }
        ```

        TODO: Not all operations are currently supported. In particular, `scf.for` and `scf.while`
        are not yet handled and will be ignored by this pass.
    }];
    let dependentDialects = [
        "mlir::gpu::GPUDialect",
        "mlir::memref::MemRefDialect",
    ];
}

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

def FifoMemrefAtomicizePass : Pass<"fifo-memref-atomicize"> {
    let summary = "Convert FIFO counter memref operations to atomic operations for SPSC thread safety.";
    let description = [{
        This pass converts plain memref.load and memref.store operations on FIFO counter
        metadata to atomic operations with appropriate memory ordering for Single Producer
        Single Consumer (SPSC) thread safety.

        This is an alternative to FifoAtomicizePass that works at the memref dialect level
        instead of the LLVM dialect level, making pattern matching simpler and more reliable.

        The pass should be run after FIFO dialect lowering but before LLVM conversion:
        1. FIFO dialect lowering (--lower-fifo-to-memref='fifo-index-mode=spsc-lockfree')
        2. This pass (--fifo-memref-atomicize)
        3. Then LLVM conversion (--finalize-memref-to-llvm)

        The pass identifies FIFO metadata allocations (memref<2xi64> for readCount and
        writeCount) and converts subsequent load/store operations to use memref.atomic_rmw:

        - Loads become atomic_rmw assign with Acquire ordering
        - Stores become atomic_rmw assign with Release ordering

        Example transformation:
        Before:
          %metadata = memref.alloc() : memref<2xi64>
          %count = memref.load %metadata[%index] : memref<2xi64>
          memref.store %new_count, %metadata[%index] : memref<2xi64>

        After:
          %metadata = memref.alloc() : memref<2xi64>
          %count = memref.atomic_rmw assign %dummy, %metadata[%index] acquire : (i64, memref<2xi64>) -> i64
          memref.atomic_rmw assign %new_count, %metadata[%index] release : (i64, memref<2xi64>) -> i64
    }];

    let dependentDialects = [
        "mlir::memref::MemRefDialect"
    ];
}

 def FlattenCalNetworksPass : Pass<"flatten-cal-networks", "mlir::ModuleOp"> {
    let summary = "Inline (flatten) hierarchical cal.network instantiations so only actors remain";
    let description = [{
        This pass flattens hierarchical CAL networks by inlining the body of any
        instantiated `cal.network` (via `cal.create_instance`) into the parent
        network. After inlining, the `cal.create_instance` op referencing a
        network is erased. Actor instances are preserved.

        The transformation iterates until no `cal.create_instance` targets a
        network symbol. Operand mapping is performed as follows:
          - Parent actual operands (parameters and ports) map to the cloned
            network entry block arguments (in declared order).
          - Internal operations of the child network are cloned into the parent
            at the call site (maintaining relative order) except other network
            instances, which will be processed in subsequent iterations.

        Additional capabilities:
          - Detects and reports cycles in the network instantiation graph
            (including self-recursive networks) before attempting flattening.
          - Applies an iteration safeguard (soft limit) to abort with a
            diagnostic if unexpected growth indicates a hidden cycle.
          - (Optional) Prunes now-unreferenced network symbols after full
            flattening so only reachable networks remain (top-level networks
            that were instantiated but are no longer referenced are removed).

        Constraints / Notes:
          - Assumes all referenced network symbols are defined at module scope.
          - Ports and parameters are treated uniformly as positional operands.
          - After flattening, topology is preserved and verification of port
            arity/type remains enforced by existing verifiers.

        Result: Single-level network(s) containing only fifo ops, constants,
        and actor `cal.create_instance` operations, plus optional dead network
        pruning, enabling downstream lowers.
    }];

  let options = [
    Option<"disablePruning", "disable-pruning", "bool", /*default=*/"false",
       "Disable dead network pruning after flattening (retain all original network symbols even if unreferenced).">,
    Option<"emitStats", "emit-stats", "bool", /*default=*/"false",
     "Emit a remark summarizing flatten statistics (iterations, flattened instances, pruned networks).">,
   Option<"allowPartialConnectivity", "allow-partial-connectivity", "bool", /*default=*/"false",
     "Allow elaboration to proceed even if some instances are not fully connected. Fully-wired instances are materialized; partially wired instances and their symbolic ops are left intact for incremental builds.">,
   Option<"allowDynamicIndices", "allow-dynamic-indices", "bool", /*default=*/"false",
     "Permit dynamic indices in cal.instance_at or cal.connect array sugar. Such connections are skipped during elaboration with a remark (to be handled by later passes). When disabled (default), dynamic indices cause a failure.">
   , Option<"top", "top", "std::string", /*default=*/"\"\"",
      "If set, keep only the cal.network with this symbol name after flattening and erase all others. Useful to retain only the designated top network definition for downstream pipelines.">
  ];
}

#endif // CAL_TRANSFORM_PASSES