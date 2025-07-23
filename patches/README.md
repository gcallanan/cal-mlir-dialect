# MLIR Patches

This directory contains patches applied to the MLIR version pulled for this repository to fix various issues and add functionality.

## 1. gpu-memcpy-fix.patch

**Based on:** https://github.com/llvm/llvm-project/pull/115687
**Title:** "[mlir][GPU] Lower gpu.memcpy with an offset to memcpy"

### Problem
Previously, `gpu.memcpy` could not handle memref types with strides and offsets. For example, the following code would fail to convert:

```mlir
%subview = memref.subview %arg0[%10, 0, 0] [1, 2, 2] [1, 1, 1] : memref<?x2x2xi32> to memref<1x2x2xi32, strided<[4, 2, 1], offset: ?>>
%collapse_shape = memref.collapse_shape %subview [[0, 1], [2]] : memref<1x2x2xi32, strided<[4, 2, 1], offset: ?>> into memref<2x2xi32, strided<[2, 1], offset: ?>>
%alloc = memref.alloc() : memref<2x2xi32>
%15 = gpu.wait async
%16 = gpu.memcpy async [%15] %alloc, %collapse_shape : memref<2x2xi32>, memref<2x2xi32, strided<[2, 1], offset: ?>>
```

The `gpu.memcpy` operation could not handle `memref<2x2xi32, strided<[2, 1], offset: ?>>` types due to the stride and offset information.

### Solution
This patch extends the GPU memcpy lowering to handle contiguous memrefs with offsets.

This fix enables GPU memcpy operations on memrefs created from subviews and other operations that introduce strides and offsets. This is particularly important as the FIFOs created in this project create subviews all the time.