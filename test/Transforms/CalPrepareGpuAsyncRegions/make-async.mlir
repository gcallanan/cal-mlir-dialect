// RUN: cal-opt %s --cal-prepare-gpu-async-regions | FileCheck %s 

#map = affine_map<(d0)[s0, s1] -> ((d0 - s0) ceildiv s1)>
#map1 = affine_map<(d0)[s0, s1] -> (d0 * s0 + s1)>
module attributes {gpu.container_module} {
  llvm.mlir.global internal constant @fmt_string_2("\0A\00") {addr_space = 0 : i32}
  llvm.mlir.global internal constant @fmt_string_1("%d \00") {addr_space = 0 : i32}
  llvm.mlir.global internal constant @fmt_string_0("accumulator: final state:\0A\00") {addr_space = 0 : i32}
  llvm.func @printf(!llvm.ptr, ...) -> i32
  // CHECK: func.func @src(%arg0: i32, %arg1: memref<?x10x10xi32>, %arg2: memref<2xi32>, %arg3: i32, %arg4: memref<1xi32>, %arg5: memref<10x10xi32>, %arg6: !gpu.async.token) -> (i1, !gpu.async.token) {
  func.func @src(%arg0: i32, %arg1: memref<?x10x10xi32>, %arg2: memref<2xi32>, %arg3: i32, %arg4: memref<1xi32>, %arg5: memref<10x10xi32>) -> i1 {
    %c10 = arith.constant 10 : index
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c1_i32 = arith.constant 1 : i32
    %0 = memref.load %arg2[%c1] : memref<2xi32>
    %1 = memref.load %arg2[%c0] : memref<2xi32>
    %2 = arith.subi %0, %1 : i32
    %3 = arith.addi %2, %arg3 : i32
    %4 = arith.remsi %3, %arg3 : i32
    %5 = arith.subi %arg3, %4 : i32
    %6 = arith.subi %5, %c1_i32 : i32
    %7 = arith.cmpi sge, %6, %c1_i32 : i32
    %8 = memref.load %arg4[%c0] : memref<1xi32>
    %9 = arith.cmpi slt, %8, %arg0 : i32
    %10 = arith.andi %9, %7 : i1
    scf.if %10 {
      %11 = memref.load %arg4[%c0] : memref<1xi32>
      %12 = arith.addi %11, %c1_i32 : i32
      memref.store %12, %arg4[%c0] : memref<1xi32>
      %13 = affine.apply #map(%c10)[%c0, %c1]
      // CHECK: %14 = gpu.launch_func async [%arg6] @src_kernel::@src_kernel blocks in (%c10, %c10, %c1) threads in (%c1, %c1, %c1)  args(%c1 : index, %c0 : index, %13 : i32, %arg5 : memref<10x10xi32>)
      gpu.launch_func  @src_kernel::@src_kernel blocks in (%13, %13, %c1) threads in (%c1, %c1, %c1)  args(%c1 : index, %c0 : index, %12 : i32, %arg5 : memref<10x10xi32>)
      %14 = memref.load %arg2[%c1] : memref<2xi32>
      %15 = arith.index_cast %14 : i32 to index
      %subview = memref.subview %arg1[%15, 0, 0] [1, 10, 10] [1, 1, 1] : memref<?x10x10xi32> to memref<1x10x10xi32, strided<[100, 10, 1], offset: ?>>
      %collapse_shape = memref.collapse_shape %subview [[0, 1], [2]] : memref<1x10x10xi32, strided<[100, 10, 1], offset: ?>> into memref<10x10xi32, strided<[10, 1], offset: ?>>
      gpu.memcpy  %collapse_shape, %arg5 : memref<10x10xi32, strided<[10, 1], offset: ?>>, memref<10x10xi32>
      //CHECK: %17 = gpu.memcpy async [%14] %collapse_shape, %arg5 : memref<10x10xi32, strided<[10, 1], offset: ?>>, memref<10x10xi32>
      %16 = arith.addi %14, %c1_i32 : i32
      %17 = arith.remsi %16, %arg3 : i32
      memref.store %17, %arg2[%c1] : memref<2xi32>
      // CHECK: scf.yield %17 : !gpu.async.token
    }
    //CHECK: else {
    //CHECK:   scf.yield %arg6 : !gpu.async.token
    //CHECK: }
    return %10 : i1
    // CHECK: return %10, %11 : i1, !gpu.async.token
  }
  gpu.module @src_kernel {
    gpu.func @src_kernel(%arg0: index, %arg1: index, %arg2: i32, %arg3: memref<10x10xi32>) kernel attributes {known_block_size = array<i32: 1, 1, 1>} {
      %block_id_x = gpu.block_id  x
      %block_id_y = gpu.block_id  y
      %0 = affine.apply #map1(%block_id_x)[%arg0, %arg1]
      %1 = affine.apply #map1(%block_id_y)[%arg0, %arg1]
      memref.store %arg2, %arg3[%0, %1] : memref<10x10xi32>
      gpu.return
    }
  }
  // CHECK:  func.func @accumulator(%arg0: i32, %arg1: memref<?x10x10xi32>, %arg2: memref<2xi32>, %arg3: i32, %arg4: memref<10x10xi32>, %arg5: memref<10x10xi32, strided<[?, ?], offset: ?>>, %arg6: memref<10x10xi32, strided<[?, ?], offset: ?>>, %arg7: memref<1xi32>, %arg8: memref<10x10xi32>, %arg9: memref<10x10xi32>, %arg10: !gpu.async.token) -> (i1, !gpu.async.token)
  func.func @accumulator(%arg0: i32, %arg1: memref<?x10x10xi32>, %arg2: memref<2xi32>, %arg3: i32, %arg4: memref<10x10xi32>, %arg5: memref<10x10xi32, strided<[?, ?], offset: ?>>, %arg6: memref<10x10xi32, strided<[?, ?], offset: ?>>, %arg7: memref<1xi32>, %arg8: memref<10x10xi32>, %arg9: memref<10x10xi32>) -> i1 {
    %0 = llvm.mlir.addressof @fmt_string_2 : !llvm.ptr
    %1 = llvm.mlir.addressof @fmt_string_1 : !llvm.ptr
    %c10 = arith.constant 10 : index
    %2 = llvm.mlir.addressof @fmt_string_0 : !llvm.ptr
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %true = arith.constant true
    %c1_i32 = arith.constant 1 : i32
    %3 = memref.load %arg2[%c1] : memref<2xi32>
    %4 = memref.load %arg2[%c0] : memref<2xi32>
    %5 = arith.subi %3, %4 : i32
    %6 = arith.addi %5, %arg3 : i32
    %7 = arith.remsi %6, %arg3 : i32
    %8 = arith.cmpi sge, %7, %c1_i32 : i32
    %9 = memref.load %arg7[%c0] : memref<1xi32>
    %10 = arith.cmpi slt, %9, %arg0 : i32
    %11 = arith.andi %10, %8 : i1
    %12 = scf.if %11 -> (i1) {
      //CHECK:  %12:2 = scf.if %11 -> (i1, !gpu.async.token) {
      %13 = memref.load %arg2[%c0] : memref<2xi32>
      %14 = arith.index_cast %13 : i32 to index
      %subview = memref.subview %arg1[%14, 0, 0] [1, 10, 10] [1, 1, 1] : memref<?x10x10xi32> to memref<1x10x10xi32, strided<[100, 10, 1], offset: ?>>
      %collapse_shape = memref.collapse_shape %subview [[0, 1], [2]] : memref<1x10x10xi32, strided<[100, 10, 1], offset: ?>> into memref<10x10xi32, strided<[10, 1], offset: ?>>
      %15 = arith.addi %13, %c1_i32 : i32
      %16 = arith.remsi %15, %arg3 : i32
      memref.store %16, %arg2[%c0] : memref<2xi32>
      %17 = affine.apply #map(%c10)[%c0, %c1]
      gpu.launch_func  @accumulator_kernel::@accumulator_kernel blocks in (%17, %17, %c1) threads in (%c1, %c1, %c1)  args(%c1 : index, %c0 : index, %collapse_shape : memref<10x10xi32, strided<[10, 1], offset: ?>>, %arg4 : memref<10x10xi32>, %arg9 : memref<10x10xi32>)
      gpu.memcpy  %arg4, %arg9 : memref<10x10xi32>, memref<10x10xi32>
      //CHECK: %17 = gpu.launch_func async [%arg10] @accumulator_kernel::@accumulator_kernel blocks in (%c10, %c10, %c1) threads in (%c1, %c1, %c1)  args(%c1 : index, %c0 : index, %collapse_shape : memref<10x10xi32, strided<[10, 1], offset: ?>>, %arg4 : memref<10x10xi32>, %arg9 : memref<10x10xi32>)
      //CHECK: %18 = gpu.memcpy async [%17] %arg4, %arg9 : memref<10x10xi32>, memref<10x10xi32>
      %18 = memref.load %arg7[%c0] : memref<1xi32>
      %19 = arith.addi %18, %c1_i32 : i32
      memref.store %19, %arg7[%c0] : memref<1xi32>
      scf.yield %true : i1
    } else {
      %13 = arith.cmpi eq, %9, %arg0 : i32
      scf.if %13 {
        %14 = llvm.getelementptr %2[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<27 x i8>
        %15 = llvm.call @printf(%14) vararg(!llvm.func<i32 (ptr, ...)>) : (!llvm.ptr) -> i32
        gpu.memcpy  %arg8, %arg4 : memref<10x10xi32>, memref<10x10xi32>
        //CHECK: %17 = gpu.memcpy async [%arg10] %arg8, %arg4 : memref<10x10xi32>, memref<10x10xi32>
        //CHECK: gpu.wait [%17]
        //CHECK: %18 = gpu.wait async
        scf.for %arg10 = %c0 to %c10 step %c1 {
          scf.for %arg11 = %c0 to %c10 step %c1 {
            %20 = memref.load %arg8[%arg10, %arg11] : memref<10x10xi32>
            %21 = llvm.getelementptr %1[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<4 x i8>
            %22 = llvm.call @printf(%21, %20) vararg(!llvm.func<i32 (ptr, ...)>) : (!llvm.ptr, i32) -> i32
          }
          %18 = llvm.getelementptr %0[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2 x i8>
          %19 = llvm.call @printf(%18) vararg(!llvm.func<i32 (ptr, ...)>) : (!llvm.ptr) -> i32
        }
        %16 = memref.load %arg7[%c0] : memref<1xi32>
        %17 = arith.addi %16, %c1_i32 : i32
        memref.store %17, %arg7[%c0] : memref<1xi32>
        // CHECK: scf.yield %18 : !gpu.async.token
      }
      // CHECK: else {
      // CHECK:   scf.yield %arg10 : !gpu.async.token
      // CHECK: }

      scf.yield %13 : i1
      // CHECK: scf.yield %13, %arg10 : i1, !gpu.async.token
    }
    return %12 : i1
    // CHECK: return %12#0, %12#1 : i1, !gpu.async.token
  }
  gpu.module @accumulator_kernel {
    gpu.func @accumulator_kernel(%arg0: index, %arg1: index, %arg2: memref<10x10xi32, strided<[10, 1], offset: ?>>, %arg3: memref<10x10xi32>, %arg4: memref<10x10xi32>) kernel attributes {known_block_size = array<i32: 1, 1, 1>} {
      %block_id_x = gpu.block_id  x
      %block_id_y = gpu.block_id  y
      %0 = affine.apply #map1(%block_id_x)[%arg0, %arg1]
      %1 = affine.apply #map1(%block_id_y)[%arg0, %arg1]
      %2 = memref.load %arg2[%0, %1] : memref<10x10xi32, strided<[10, 1], offset: ?>>
      %3 = memref.load %arg3[%0, %1] : memref<10x10xi32>
      %4 = arith.addi %2, %3 : i32
      memref.store %4, %arg4[%0, %1] : memref<10x10xi32>
      gpu.return
    }
  }
  func.func @main() {
    %c10 = arith.constant 10 : index
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %true = arith.constant true
    %c4_i32 = arith.constant 4 : i32
    %c0_i32 = arith.constant 0 : i32
    %c5000_i32 = arith.constant 5000 : i32
    %memref = gpu.alloc  () : memref<10x10xi32>
    %memref_0 = gpu.alloc  () : memref<10x10xi32>
    %alloc = memref.alloc() : memref<10x10xi32>
    %memref_1 = gpu.alloc  () : memref<4x10x10xi32>
    %alloc_2 = memref.alloc() : memref<2xi32>
    %cast = memref.cast %memref_1 : memref<4x10x10xi32> to memref<?x10x10xi32>
    memref.store %c0_i32, %alloc_2[%c0] : memref<2xi32>
    memref.store %c0_i32, %alloc_2[%c1] : memref<2xi32>
    %alloc_3 = memref.alloc() : memref<1xi32>
    memref.store %c0_i32, %alloc_3[%c0] : memref<1xi32>
    %memref_4 = gpu.alloc  () : memref<10x10xi32>
    %memref_5 = gpu.alloc  () : memref<10x10xi32>
    %0 = affine.apply #map(%c10)[%c0, %c1]
    gpu.launch_func  @main_kernel::@main_kernel blocks in (%0, %0, %c1) threads in (%c1, %c1, %c1)  args(%c1 : index, %c0 : index, %c4_i32 : i32, %memref_5 : memref<10x10xi32>)
    gpu.memcpy  %memref_4, %memref_5 : memref<10x10xi32>, memref<10x10xi32>
    %alloc_6 = memref.alloc() : memref<1xi32>
    memref.store %c0_i32, %alloc_6[%c0] : memref<1xi32>

    // CHECK: %0 = gpu.wait async
    // CHECK: %memref, %asyncToken = gpu.alloc async [%0] () : memref<10x10xi32>
    // CHECK: gpu.wait [%asyncToken]
    // CHECK: %1 = gpu.wait async
    // CHECK: %memref_0, %asyncToken_1 = gpu.alloc async [%1] () : memref<10x10xi32>
    // CHECK: gpu.wait [%asyncToken_1]
    // CHECK: %2 = gpu.wait async
    // CHECK: %memref_2, %asyncToken_3 = gpu.alloc async [%2] () : memref<4x10x10xi32>
    // CHECK: gpu.wait [%asyncToken_3]
    // CHECK: %3 = gpu.wait async
    // CHECK: %memref_6, %asyncToken_7 = gpu.alloc async [%3] () : memref<10x10xi32>
    // CHECK: gpu.wait [%asyncToken_7]
    // CHECK: %4 = gpu.wait async
    // CHECK: %memref_8, %asyncToken_9 = gpu.alloc async [%4] () : memref<10x10xi32>
    // CHECK: gpu.wait [%asyncToken_9]
    // CHECK: %5 = gpu.wait async
    // CHECK: %6 = gpu.launch_func async [%5] @main_kernel::@main_kernel blocks in (%c10, %c10, %c1) threads in (%c1, %c1, %c1)  args(%c1 : index, %c0 : index, %c4_i32 : i32, %memref_8 : memref<10x10xi32>)
    // CHECK: gpu.wait [%6]
    // CHECK: %7 = gpu.wait async
    // CHECK: %8 = gpu.memcpy async [%7] %memref_6, %memref_8 : memref<10x10xi32>, memref<10x10xi32>
    // CHECK: gpu.wait [%8]
    // CHECK: %9 = gpu.wait async
    // CHECK: gpu.wait [%9]


    scf.while (%arg0 = %true) : (i1) -> () {
      scf.condition(%arg0)
    } do {
      %1 = func.call @src(%c5000_i32, %cast, %alloc_2, %c4_i32, %alloc_3, %memref) : (i32, memref<?x10x10xi32>, memref<2xi32>, i32, memref<1xi32>, memref<10x10xi32>) -> i1
      %cast_7 = memref.cast %memref_4 : memref<10x10xi32> to memref<10x10xi32, strided<[?, ?], offset: ?>>
      %cast_8 = memref.cast %memref_5 : memref<10x10xi32> to memref<10x10xi32, strided<[?, ?], offset: ?>>
      %2 = func.call @accumulator(%c5000_i32, %cast, %alloc_2, %c4_i32, %memref_4, %cast_7, %cast_8, %alloc_6, %alloc, %memref_0) : (i32, memref<?x10x10xi32>, memref<2xi32>, i32, memref<10x10xi32>, memref<10x10xi32, strided<[?, ?], offset: ?>>, memref<10x10xi32, strided<[?, ?], offset: ?>>, memref<1xi32>, memref<10x10xi32>, memref<10x10xi32>) -> i1
      %3 = arith.ori %2, %1 : i1
      scf.yield %3 : i1
    }

    // CHECK: %10 = gpu.wait async
    // CHECK: %11 = scf.while (%arg0 = %true, %arg1 = %10) : (i1, !gpu.async.token) -> !gpu.async.token {
    // CHECK:   scf.condition(%arg0) %arg1 : !gpu.async.token
    // CHECK: } do {
    // CHECK: ^bb0(%arg0: !gpu.async.token):
    // CHECK:   %12:2 = func.call @src(%c5000_i32, %cast, %alloc_4, %c4_i32, %alloc_5, %memref, %arg0) : (i32, memref<?x10x10xi32>, memref<2xi32>, i32, memref<1xi32>, memref<10x10xi32>, !gpu.async.token) -> (i1, !gpu.async.token)
    // CHECK:   %13:2 = func.call @accumulator(%c5000_i32, %cast, %alloc_4, %c4_i32, %memref_6, %cast_11, %cast_12, %alloc_10, %alloc, %memref_0, %12#1) : (i32, memref<?x10x10xi32>, memref<2xi32>, i32, memref<10x10xi32>, memref<10x10xi32, strided<[?, ?], offset: ?>>, memref<10x10xi32, strided<[?, ?], offset: ?>>, memref<1xi32>, memref<10x10xi32>, memref<10x10xi32>, !gpu.async.token) -> (i1, !gpu.async.token)
    // CHECK:   %14 = arith.ori %13#0, %12#0 : i1
    // CHECK:   scf.yield %14, %13#1 : i1, !gpu.async.token
    // CHECK: }

    return
  }
  gpu.module @main_kernel {
    gpu.func @main_kernel(%arg0: index, %arg1: index, %arg2: i32, %arg3: memref<10x10xi32>) kernel attributes {known_block_size = array<i32: 1, 1, 1>} {
      %block_id_x = gpu.block_id  x
      %block_id_y = gpu.block_id  y
      %0 = affine.apply #map1(%block_id_x)[%arg0, %arg1]
      %1 = affine.apply #map1(%block_id_y)[%arg0, %arg1]
      memref.store %arg2, %arg3[%0, %1] : memref<10x10xi32>
      gpu.return
    }
  }
}

