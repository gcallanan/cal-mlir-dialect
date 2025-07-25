// RUN: cal-opt %s --convert-dense-constant-to-gpu | FileCheck %s

%cst_0 = arith.constant dense<[[[1.100000e-03, 9.988000e-01, 1.000000e-04]]]> : tensor<1x1x3xf64>
fifo.print_tensor(%cst_0) : tensor<1x1x3xf64>

%cst_1 = arith.constant dense<[
    [[1, 2, 3], [4, 5, 6], [7, 8, 9]],
    [[10, 11, 12], [13, 14, 15], [16, 17, 18]],
    [[19, 20, 21], [22, 23, 24], [25, 26, 27]]
]> : tensor<3x3x3xi32>
fifo.print_tensor(%cst_1) : tensor<3x3x3xi32>

// Results are for cst_1 and then cst_0. Not sure why the order has changed
// CHECK: %alloc = memref.alloc() : memref<3x3x3xi32>
// CHECK: %memref = gpu.alloc  () : memref<3x3x3xi32>
// CHECK: memref.store %c1_i32, %alloc[%c0, %c0, %c0] : memref<3x3x3xi32>
// CHECK: memref.store %c2_i32, %alloc[%c0, %c0, %c1] : memref<3x3x3xi32>
// CHECK: memref.store %c3_i32, %alloc[%c0, %c0, %c2] : memref<3x3x3xi32>
// CHECK: memref.store %c4_i32, %alloc[%c0, %c1, %c0] : memref<3x3x3xi32>
// CHECK: memref.store %c5_i32, %alloc[%c0, %c1, %c1] : memref<3x3x3xi32>
// CHECK: memref.store %c6_i32, %alloc[%c0, %c1, %c2] : memref<3x3x3xi32>
// CHECK: memref.store %c7_i32, %alloc[%c0, %c2, %c0] : memref<3x3x3xi32>
// CHECK: memref.store %c8_i32, %alloc[%c0, %c2, %c1] : memref<3x3x3xi32>
// CHECK: memref.store %c9_i32, %alloc[%c0, %c2, %c2] : memref<3x3x3xi32>
// CHECK: memref.store %c10_i32, %alloc[%c1, %c0, %c0] : memref<3x3x3xi32>
// CHECK: memref.store %c11_i32, %alloc[%c1, %c0, %c1] : memref<3x3x3xi32>
// CHECK: memref.store %c12_i32, %alloc[%c1, %c0, %c2] : memref<3x3x3xi32>
// CHECK: memref.store %c13_i32, %alloc[%c1, %c1, %c0] : memref<3x3x3xi32>
// CHECK: memref.store %c14_i32, %alloc[%c1, %c1, %c1] : memref<3x3x3xi32>
// CHECK: memref.store %c15_i32, %alloc[%c1, %c1, %c2] : memref<3x3x3xi32>
// CHECK: memref.store %c16_i32, %alloc[%c1, %c2, %c0] : memref<3x3x3xi32>
// CHECK: memref.store %c17_i32, %alloc[%c1, %c2, %c1] : memref<3x3x3xi32>
// CHECK: memref.store %c18_i32, %alloc[%c1, %c2, %c2] : memref<3x3x3xi32>
// CHECK: memref.store %c19_i32, %alloc[%c2, %c0, %c0] : memref<3x3x3xi32>
// CHECK: memref.store %c20_i32, %alloc[%c2, %c0, %c1] : memref<3x3x3xi32>
// CHECK: memref.store %c21_i32, %alloc[%c2, %c0, %c2] : memref<3x3x3xi32>
// CHECK: memref.store %c22_i32, %alloc[%c2, %c1, %c0] : memref<3x3x3xi32>
// CHECK: memref.store %c23_i32, %alloc[%c2, %c1, %c1] : memref<3x3x3xi32>
// CHECK: memref.store %c24_i32, %alloc[%c2, %c1, %c2] : memref<3x3x3xi32>
// CHECK: memref.store %c25_i32, %alloc[%c2, %c2, %c0] : memref<3x3x3xi32>
// CHECK: memref.store %c26_i32, %alloc[%c2, %c2, %c1] : memref<3x3x3xi32>
// CHECK: memref.store %c27_i32, %alloc[%c2, %c2, %c2] : memref<3x3x3xi32>
// CHECK: gpu.memcpy  %memref, %alloc : memref<3x3x3xi32>, memref<3x3x3xi32>
// CHECK: memref.dealloc %alloc : memref<3x3x3xi32>


// CHECK: %alloc_2 = memref.alloc() : memref<1x1x3xf64>
// CHECK: %memref_3 = gpu.alloc  () : memref<1x1x3xf64>
// CHECK: memref.store %cst_1, %alloc_2[%c0, %c0, %c0] : memref<1x1x3xf64>
// CHECK: memref.store %cst_0, %alloc_2[%c0, %c0, %c1] : memref<1x1x3xf64>
// CHECK: memref.store %cst, %alloc_2[%c0, %c0, %c2] : memref<1x1x3xf64>
// CHECK: gpu.memcpy  %memref_3, %alloc_2 : memref<1x1x3xf64>, memref<1x1x3xf64>
// CHECK: memref.dealloc %alloc_2 : memref<1x1x3xf64>
// CHECK: %1 = bufferization.to_tensor %memref_3 restrict : memref<1x1x3xf64> to tensor<1x1x3xf64>