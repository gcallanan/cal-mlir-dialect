// RUN: cal-opt %s --buffer-deallocation | FileCheck %s 

module {
  func.func @main() -> memref<2x2xf32, strided<[?, ?], offset: ?>> {
    %cst = arith.constant 1.000000e+00 : f32
    %cst_0 = arith.constant 2.000000e+00 : f32
    %memref = gpu.alloc  host_shared () : memref<2x2xf32>
    %memref_1 = gpu.alloc  host_shared () : memref<2x2xf32>
    linalg.fill ins(%cst : f32) outs(%memref : memref<2x2xf32>)
    linalg.fill ins(%cst_0 : f32) outs(%memref_1 : memref<2x2xf32>)
    linalg.add ins(%memref, %memref_1 : memref<2x2xf32>, memref<2x2xf32>) outs(%memref : memref<2x2xf32>)
    %cast = memref.cast %memref : memref<2x2xf32> to memref<2x2xf32, strided<[?, ?], offset: ?>>

    // CHECK: linalg.add ins(%memref, %memref_1 : memref<2x2xf32>, memref<2x2xf32>) outs(%memref : memref<2x2xf32>)
    // CHECK: gpu.dealloc  %memref_1 : memref<2x2xf32>
    // CHECK: %cast = memref.cast %memref : memref<2x2xf32> to memref<2x2xf32, strided<[?, ?], offset: ?>>

    return %cast : memref<2x2xf32, strided<[?, ?], offset: ?>>
  }
}
