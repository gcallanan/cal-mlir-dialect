// RUN: cal-opt --lower-fifo-print-to-llvm="tensors-on-gpu" %s | FileCheck %s

%vals2d = arith.constant dense<[
    [1.0, 2.0],
    [3.0, 4.0]
    ]> : tensor<2x2xf32>
fifo.print("2x2 matrix:\n")
fifo.print_tensor(%vals2d) : tensor<2x2xf32>

// CHECK: %4 = bufferization.to_memref %cst : tensor<2x2xf32> to memref<2x2xf32>
// CHECK: %alloc = memref.alloc() : memref<2x2xf32>
// CHECK: gpu.memcpy  %alloc, %4 : memref<2x2xf32>, memref<2x2xf32>

// CHECK: scf.for %arg0 = %c0 to %c2_1 step %c1 {
// CHECK:     scf.for %arg1 = %c0 to %c2_2 step %c1 {
// CHECK:       %9 = memref.load %alloc[%arg0, %arg1] : memref<2x2xf32>
// CHECK:       %10 = llvm.mlir.addressof @fmt_string_1 : !llvm.ptr
// CHECK:       %11 = llvm.mlir.constant(0 : index) : i64
// CHECK:       %12 = llvm.getelementptr %10[%11, %11] : (!llvm.ptr, i64, i64) -> !llvm.ptr, !llvm.array<4 x i8>
// CHECK:       %13 = llvm.fpext %9 : f32 to f64
// CHECK:       %14 = llvm.call @printf(%12, %13) vararg(!llvm.func<i32 (ptr, ...)>) : (!llvm.ptr, f64) -> i32
// CHECK:     }
// CHECK:     %5 = llvm.mlir.addressof @fmt_string_2 : !llvm.ptr
// CHECK:     %6 = llvm.mlir.constant(0 : index) : i64
// CHECK:     %7 = llvm.getelementptr %5[%6, %6] : (!llvm.ptr, i64, i64) -> !llvm.ptr, !llvm.array<2 x i8>
// CHECK:     %8 = llvm.call @printf(%7) vararg(!llvm.func<i32 (ptr, ...)>) : (!llvm.ptr) -> i32
// CHECK:   }


