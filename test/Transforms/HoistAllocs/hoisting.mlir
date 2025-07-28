// RUN: cal-opt %s --canonicalize --hoist-allocs | FileCheck %s

//CHECK: func.func @src(%arg0: memref<2x2xi32>, %arg1: memref<2x2xi32>) -> i1 {
//CHECK:     %true = arith.constant true
//CHECK:     gpu.memcpy  %arg0, %arg1 : memref<2x2xi32>, memref<2x2xi32>
//CHECK:     return %true : i1
//CHECK: }
func.func @src(%arg0: memref<2x2xi32>) -> i1 {
    %true = arith.constant true
    %memref = gpu.alloc  () : memref<2x2xi32>
    gpu.memcpy  %arg0, %memref : memref<2x2xi32>, memref<2x2xi32>
    return %true : i1
}

// CHECK: func.func @accumulator(%arg0: memref<2x2xi32>, %arg1: memref<2x2xi32>) -> i1 {
// CHECK:     %true = arith.constant true
// CHECK:     gpu.memcpy  %arg0, %arg1 : memref<2x2xi32>, memref<2x2xi32>
// CHECK:     return %true : i1
// CHECK: }
func.func @accumulator(%arg0: memref<2x2xi32>) -> i1 {
    %true = arith.constant true
    %memref = gpu.alloc  () : memref<2x2xi32>
    gpu.memcpy  %arg0, %memref : memref<2x2xi32>, memref<2x2xi32>
    return %true : i1
}
func.func @main() {
    %true = arith.constant true
    %memref = gpu.alloc  () : memref<2x2xi32>
    %memref_0 = gpu.alloc  () : memref<2x2xi32>
    //CHECK: %memref = gpu.alloc  () : memref<2x2xi32>
    //CHECK: %memref_0 = gpu.alloc  () : memref<2x2xi32>
    //CHECK: %memref_1 = gpu.alloc  () : memref<2x2xi32>
    //CHECK: %memref_2 = gpu.alloc  () : memref<2x2xi32>
    scf.while (%arg0 = %true) : (i1) -> () {
        scf.condition(%arg0)
    } do {
        //CHECK: %0 = func.call @src(%memref_1, %memref) : (memref<2x2xi32>, memref<2x2xi32>) -> i1
        //CHECK: %1 = func.call @accumulator(%memref_2, %memref_0) : (memref<2x2xi32>, memref<2x2xi32>) -> i1
        %0 = func.call @src(%memref) : (memref<2x2xi32>) -> i1
        %1 = func.call @accumulator(%memref_0) : (memref<2x2xi32>) -> i1
        %2 = arith.ori %1, %0 : i1
        scf.yield %2 : i1
    }
    return
}


