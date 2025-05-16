// RUN: cal-opt --decompose-fifo-tuples %s | FileCheck %s

module {
  cal.actor @inputs_and_output(%arg0: i32, %arg1: tuple<memref<?xi32>, memref<2xi32>, i32>, %arg2: tuple<memref<?xi32>, memref<2xi32>, i32>, %arg3: tuple<memref<?xi32>, memref<2xi32>, i32>)
  {
  }
  // CHECK: cal.actor @inputs_and_output(%arg0: i32, %arg1: memref<?xi32>, %arg2: memref<2xi32>, %arg3: i32, %arg4: memref<?xi32>, %arg5: memref<2xi32>, %arg6: i32, %arg7: memref<?xi32>, %arg8: memref<2xi32>, %arg9: i32)

  
  cal.network {
    %c10_i32 = arith.constant 10 : i32
    %alloc = memref.alloc() : memref<4xi32>
    %alloc_0 = memref.alloc() : memref<2xi32>
    %c4_i32 = arith.constant 4 : i32
    %0 = fifo.make_tuple(%alloc, %alloc_0, %c4_i32) : memref<4xi32>, memref<2xi32>, i32 -> tuple<memref<4xi32>, memref<2xi32>, i32>
    %1 = fifo.get_tuple_element %0[0] : tuple<memref<4xi32>, memref<2xi32>, i32> -> memref<4xi32>
    %2 = fifo.get_tuple_element %0[1] : tuple<memref<4xi32>, memref<2xi32>, i32> -> memref<2xi32>
    %3 = fifo.get_tuple_element %0[2] : tuple<memref<4xi32>, memref<2xi32>, i32> -> i32
    %cast = memref.cast %1 : memref<4xi32> to memref<?xi32>
    %4 = fifo.make_tuple(%cast, %2, %3) : memref<?xi32>, memref<2xi32>, i32 -> tuple<memref<?xi32>, memref<2xi32>, i32>
    %c0_i32 = arith.constant 0 : i32
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    memref.store %c0_i32, %alloc_0[%c0] : memref<2xi32>
    memref.store %c0_i32, %alloc_0[%c1] : memref<2xi32>
    %alloc_1 = memref.alloc() : memref<4xi32>
    %alloc_2 = memref.alloc() : memref<2xi32>
    %c4_i32_3 = arith.constant 4 : i32
    %5 = fifo.make_tuple(%alloc_1, %alloc_2, %c4_i32_3) : memref<4xi32>, memref<2xi32>, i32 -> tuple<memref<4xi32>, memref<2xi32>, i32>
    %6 = fifo.get_tuple_element %5[0] : tuple<memref<4xi32>, memref<2xi32>, i32> -> memref<4xi32>
    %7 = fifo.get_tuple_element %5[1] : tuple<memref<4xi32>, memref<2xi32>, i32> -> memref<2xi32>
    %8 = fifo.get_tuple_element %5[2] : tuple<memref<4xi32>, memref<2xi32>, i32> -> i32
    %cast_4 = memref.cast %6 : memref<4xi32> to memref<?xi32>
    %9 = fifo.make_tuple(%cast_4, %7, %8) : memref<?xi32>, memref<2xi32>, i32 -> tuple<memref<?xi32>, memref<2xi32>, i32>
    %c0_i32_5 = arith.constant 0 : i32
    %c0_6 = arith.constant 0 : index
    %c1_7 = arith.constant 1 : index
    memref.store %c0_i32_5, %alloc_2[%c0_6] : memref<2xi32>
    memref.store %c0_i32_5, %alloc_2[%c1_7] : memref<2xi32>
    cal.create_instance @inputs_and_output(%c10_i32, %4, %9, %4 : i32, tuple<memref<?xi32>, memref<2xi32>, i32>, tuple<memref<?xi32>, memref<2xi32>, i32>, tuple<memref<?xi32>, memref<2xi32>, i32>)
    // CHECK: cal.create_instance @inputs_and_output(%c10_i32, %cast, %alloc_0, %c4_i32, %cast_3, %alloc_2, %c4_i32, %cast, %alloc_0, %c4_i32 : i32, memref<?xi32>, memref<2xi32>, i32, memref<?xi32>, memref<2xi32>, i32, memref<?xi32>, memref<2xi32>, i32)
  }
}
