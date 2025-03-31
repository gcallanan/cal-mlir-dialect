// Here we want to check that when we call the --decompose-fifo-tuples pass that all the 
// fifo.make_tuple and fifo.get_tuple_element operations are removed and where 
// fifo.get_tuple_element is used, the tuple element is replaced with the operand stored in the
// corresponding fifo.make_tuple operation.
// RUN: cal-opt --decompose-fifo-tuples  %s | FileCheck %s
%alloc = memref.alloc() : memref<15xi32>
%alloc_0 = memref.alloc() : memref<2xi32>
%c15_i32 = arith.constant 15 : i32 
%tuple = fifo.make_tuple (%alloc, %alloc_0, %c15_i32) : memref<15xi32>, memref<2xi32>, i32 -> tuple<memref<15xi32>, memref<2xi32>, i32>

%c0 = arith.constant 0 : index
%stored_value = fifo.get_tuple_element %tuple[2] : tuple<memref<15xi32>, memref<2xi32>, i32> -> i32
%accessed_memref1 = fifo.get_tuple_element %tuple[0] : tuple<memref<15xi32>, memref<2xi32>, i32> -> memref<15xi32>
memref.store %stored_value, %accessed_memref1[%c0] : memref<15xi32>
// CHECK: memref.store %c15_i32, %alloc[%c0] : memref<15xi32>
%accessed_memref2 = fifo.get_tuple_element %tuple[1] : tuple<memref<15xi32>, memref<2xi32>, i32> -> memref<2xi32>
memref.store %stored_value, %accessed_memref2[%c0] : memref<2xi32>
// CEHCK: memref.store %c15_i32, %alloc_0[%c0] : memref<2xi32>