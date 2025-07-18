// RUN: cal-opt %s --buffer-loop-hoisting | FileCheck %s 

func.func @hoist_one_loop(
  %lb: index,
  %ub: index,
  %step: index,
  %buf: memref<2xf32>,
  %res: memref<2xf32>) {
  %0 = gpu.alloc host_shared() : memref<2xf32>
  %1 = scf.for %i = %lb to %ub step %step
    iter_args(%iterBuf = %buf) -> memref<2xf32> {
      %2 = gpu.alloc host_shared() : memref<2xf32>
      scf.yield %0 : memref<2xf32>
  }
  //test.copy(%1, %res) : (memref<2xf32>, memref<2xf32>)
  return
}

//CHECK: %memref = gpu.alloc  host_shared () : memref<2xf32>
//CHECK: %memref_0 = gpu.alloc  host_shared () : memref<2xf32>
//CHECK: %0 = scf.for %arg5 = %arg0 to %arg1 step %arg2 iter_args(%arg6 = %arg3) -> (memref<2xf32>) {
//CHECK:     scf.yield %memref : memref<2xf32>
//CHECK: }


