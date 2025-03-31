// Tests if the FIFO lowering pass correctly lowers to fifo.create, fifo.push
// and fifo.pull operations to the memref dialect.

// RUN: cal-opt --lower-fifo-to-memref %s | FileCheck %s
%in0,%out0 = fifo.create<i32>(10) : !fifo.input_port<i32>, !fifo.output_port<i32>
// CHECK: %alloc = memref.alloc() : memref<10xi32>
// CHECK-NEXT: %alloc_0 = memref.alloc() : memref<2xi32>
// CHECK-NEXT: %c10_i32 = arith.constant 10 : i32
// CHECK-NEXT: %0 = fifo.make_tuple(%alloc, %alloc_0, %c10_i32) : memref<10xi32>, memref<2xi32>, i32 -> tuple<memref<10xi32>, memref<2xi32>, i32>
// CHECK-NEXT: %c0_i32 = arith.constant 0 : i32
// CHECK-NEXT: %c0 = arith.constant 0 : index
// CHECK-NEXT: %c1 = arith.constant 1 : index
// CHECK-NEXT: memref.store %c0_i32, %alloc_0[%c0] : memref<2xi32>
// CHECK-NEXT: memref.store %c0_i32, %alloc_0[%c1] : memref<2xi32>

%constant672 = arith.constant 672 : i32 
// CHECK-NEXT: %c672_i32 = arith.constant 672 : i32
fifo.push(%in0: !fifo.input_port<i32>, %constant672: i32)
// CHECK-NEXT: %1 = fifo.get_tuple_element %0[0] : tuple<memref<10xi32>, memref<2xi32>, i32> -> memref<10xi32>
// CHECK-NEXT: %2 = fifo.get_tuple_element %0[1] : tuple<memref<10xi32>, memref<2xi32>, i32> -> memref<2xi32>
// CHECK-NEXT: %3 = fifo.get_tuple_element %0[2] : tuple<memref<10xi32>, memref<2xi32>, i32> -> i32
// CHECK-NEXT: %c1_1 = arith.constant 1 : index
// CHECK-NEXT: %4 = memref.load %2[%c1_1] : memref<2xi32>
// CHECK-NEXT: %5 = arith.index_cast %4 : i32 to index
// CHECK-NEXT: memref.store %c672_i32, %1[%5] : memref<10xi32>
// CHECK-NEXT: %c0_i32_2 = arith.constant 0 : i32
// CHECK-NEXT: %c1_i32 = arith.constant 1 : i32
// CHECK-NEXT: %6 = arith.addi %4, %c1_i32 : i32
// CHECK-NEXT: %7 = arith.remsi %6, %3 : i32
// CHECK-NEXT: memref.store %7, %2[%c1_1] : memref<2xi32>


// Pop 672 from fifo, add 17 to it
%0 = fifo.pull(%out0: !fifo.output_port<i32>) : i32
// CHECK: %8 = fifo.get_tuple_element %0[0] : tuple<memref<10xi32>, memref<2xi32>, i32> -> memref<10xi32>
// CHECK-NEXT: %9 = fifo.get_tuple_element %0[1] : tuple<memref<10xi32>, memref<2xi32>, i32> -> memref<2xi32>
// CHECK-NEXT: %10 = fifo.get_tuple_element %0[2] : tuple<memref<10xi32>, memref<2xi32>, i32> -> i32
// CHECK-NEXT: %c0_3 = arith.constant 0 : index
// CHECK-NEXT: %11 = memref.load %9[%c0_3] : memref<2xi32>
// CHECK-NEXT: %12 = arith.index_cast %11 : i32 to index
// CHECK-NEXT: %13 = memref.load %8[%12] : memref<10xi32>
// CHECK-NEXT: %c0_i32_4 = arith.constant 0 : i32
// CHECK-NEXT: %c1_i32_5 = arith.constant 1 : i32
// CHECK-NEXT: %14 = arith.addi %11, %c1_i32_5 : i32
// CHECK-NEXT: %15 = arith.remsi %14, %10 : i32
// CHECK-NEXT: memref.store %15, %9[%c0_3] : memref<2xi32>

%constant17 = arith.constant 17 : i32
// CHECK-NEXT: %c17_i32 = arith.constant 17 : i32
%newResult = arith.addi %constant17, %0: i32
// CHECK-NEXT: %16 = arith.addi %c17_i32, %13 : i32

// Push new result to fifo
fifo.push(%in0: !fifo.input_port<i32>, %newResult: i32)
// CHECK: %17 = fifo.get_tuple_element %0[0] : tuple<memref<10xi32>, memref<2xi32>, i32> -> memref<10xi32>
// CHECK-NEXT: %18 = fifo.get_tuple_element %0[1] : tuple<memref<10xi32>, memref<2xi32>, i32> -> memref<2xi32>
// CHECK-NEXT: %19 = fifo.get_tuple_element %0[2] : tuple<memref<10xi32>, memref<2xi32>, i32> -> i32
// CHECK-NEXT: %c1_6 = arith.constant 1 : index
// CHECK-NEXT: %20 = memref.load %18[%c1_6] : memref<2xi32>
// CHECK-NEXT: %21 = arith.index_cast %20 : i32 to index
// CHECK-NEXT: memref.store %16, %17[%21] : memref<10xi32>
// CHECK-NEXT: %c0_i32_7 = arith.constant 0 : i32
// CHECK-NEXT: %c1_i32_8 = arith.constant 1 : i32
// CHECK-NEXT: %22 = arith.addi %20, %c1_i32_8 : i32
// CHECK-NEXT: %23 = arith.remsi %22, %19 : i32
// CHECK-NEXT: memref.store %23, %18[%c1_6] : memref<2xi32>

