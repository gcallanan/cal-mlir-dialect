// RUN: cal-opt %s | cal-opt | FileCheck %s
%constant4 = arith.constant 4 : i32 
%constant5 = arith.constant 5 : i32 
%tuple1 = fifo.make_tuple (%constant4, %constant4) : i32, i32 -> tuple<i32, i32>
// CHECK: %0 = fifo.make_tuple(%c4_i32, %c4_i32) : i32, i32 -> tuple<i32, i32>
%output1 = fifo.get_tuple_element %tuple1[0] : tuple<i32, i32> -> i32
// CHECK: %1 = fifo.get_tuple_element %0[0] : tuple<i32, i32> -> i32

%alloc1 = memref.alloc() : memref<1xi32>
%alloc2 = memref.alloc() : memref<1xi32>
%tuple2 = fifo.make_tuple (%alloc1, %alloc2) : memref<1xi32>, memref<1xi32> -> tuple<memref<1xi32>, memref<1xi32>>
// CHECK: %2 = fifo.make_tuple(%alloc, %alloc_0) : memref<1xi32>, memref<1xi32> -> tuple<memref<1xi32>, memref<1xi32>>
%output2 = fifo.get_tuple_element %tuple2[0] : tuple<memref<1xi32>, memref<1xi32>> -> memref<1xi32>
// CHECK: %3 = fifo.get_tuple_element %2[0] : tuple<memref<1xi32>, memref<1xi32>> -> memref<1xi32>
