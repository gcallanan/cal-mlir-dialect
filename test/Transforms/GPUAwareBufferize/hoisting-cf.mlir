// RUN: cal-opt %s --buffer-hoisting | FileCheck %s 

// This file checks the behaviour of BufferHoisting pass for moving Alloc
// operations to their correct positions.

// Test Case:
//    bb0
//   /   \
//  bb1  bb2 <- Initial position of AllocOp
//   \   /
//    bb3
// BufferHoisting expected behavior: It should move the existing AllocOp to
// the entry block.

func.func @condBranch(%arg0: i1, %arg1: memref<2xf32>, %arg2: memref<2xf32>) {
  cf.cond_br %arg0, ^bb1, ^bb2
^bb1:
  cf.br ^bb3(%arg1 : memref<2xf32>)
^bb2:
  %0 = gpu.alloc host_shared () : memref<2xf32>
  //test.buffer_based in(%arg1: memref<2xf32>) out(%0: memref<2xf32>)
  cf.br ^bb3(%0 : memref<2xf32>)
^bb3(%1: memref<2xf32>):
  //test.copy(%1, %arg2) : (memref<2xf32>, memref<2xf32>)
  return
}

//CHECK: func.func @condBranch(%arg0: i1, %arg1: memref<2xf32>, %arg2: memref<2xf32>) {
//CHECK:     %memref = gpu.alloc  host_shared () : memref<2xf32>
//CHECK:     cf.cond_br %arg0, ^bb1, ^bb2
//CHECK:   ^bb1:  // pred: ^bb0
//CHECK:     cf.br ^bb3(%arg1 : memref<2xf32>)
//CHECK:   ^bb2:  // pred: ^bb0
//CHECK:     cf.br ^bb3(%memref : memref<2xf32>)
//CHECK:   ^bb3(%0: memref<2xf32>):  // 2 preds: ^bb1, ^bb2
//CHECK:     return
//CHECK:   }

