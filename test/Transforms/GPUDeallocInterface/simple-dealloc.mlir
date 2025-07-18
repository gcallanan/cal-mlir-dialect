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

  func.func @main2() {
    %c0 = arith.constant 0 : index
    %c4 = arith.constant 4 : index
    %c1 = arith.constant 1 : index

    %buf = gpu.alloc host_shared () : memref<2x2xf32>
    scf.for %i = %c0 to %c4 step %c1 {
      %zero = arith.constant 0.0 : f32
      linalg.fill ins(%zero : f32) outs(%buf : memref<2x2xf32>)
    }
  // CHECK: gpu.dealloc  %memref : memref<2x2xf32>

  return
}
}
