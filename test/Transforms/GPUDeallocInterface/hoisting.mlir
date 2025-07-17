// RUN: cal-opt %s --buffer-deallocation | FileCheck %s 

func.func @main() {
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

