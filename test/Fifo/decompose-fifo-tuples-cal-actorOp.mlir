
// RUN: cal-opt --decompose-fifo-tuples %s | FileCheck %s
cal.actor @my_actor(%arg0: i32, %arg1: i32, %arg2: tuple<memref<?xi32>, memref<2xi32>, i32>, %arg3: tuple<memref<?xi32>, memref<2xi32>, i32>)
  {
    cal.action {
      %0 = fifo.get_tuple_element %arg2[0] : tuple<memref<?xi32>, memref<2xi32>, i32> -> memref<?xi32>
      %1 = fifo.get_tuple_element %arg2[1] : tuple<memref<?xi32>, memref<2xi32>, i32> -> memref<2xi32>
      %2 = fifo.get_tuple_element %arg2[2] : tuple<memref<?xi32>, memref<2xi32>, i32> -> i32
      %c0 = arith.constant 0 : index
      %3 = memref.load %1[%c0] : memref<2xi32>
      %4 = arith.index_cast %3 : i32 to index
      %5 = memref.load %0[%4] : memref<?xi32>
      %c1_i32 = arith.constant 1 : i32
      %6 = arith.addi %3, %c1_i32 : i32
      %7 = arith.remsi %6, %2 : i32
      memref.store %7, %1[%c0] : memref<2xi32>
      %8 = arith.constant 1 : i1
      cal.action_done %8: i1
    }
  }

// CHECK: cal.actor @my_actor(%arg0: i32, %arg1: i32, %arg2: memref<?xi32>, %arg3: memref<2xi32>, %arg4: i32, %arg5: memref<?xi32>, %arg6: memref<2xi32>, %arg7: i32)
// CHECK-NEXT: {
// CHECK-NEXT:   %true = arith.constant true
// CHECK-NEXT:   %c1_i32 = arith.constant 1 : i32
// CHECK-NEXT:   %c0 = arith.constant 0 : index
// CHECK-NEXT:   cal.action {
// CHECK-NEXT:     %0 = memref.load %arg3[%c0] : memref<2xi32>
// CHECK-NEXT:     %1 = arith.addi %0, %c1_i32 : i32
// CHECK-NEXT:     %2 = arith.remsi %1, %arg4 : i32
// CHECK-NEXT:     memref.store %2, %arg3[%c0] : memref<2xi32>
// CHECK-NEXT:     cal.action_done %true : i1
// CHECK-NEXT:   }
// CHECK-NEXT: }

