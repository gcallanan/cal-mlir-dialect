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
// CHECK: memref.store %c15_i32, %alloc_0[%c0] : memref<2xi32>


// Check that fifo tuples are decomposed when they are passed as arguments
func.func @main(%tuple_arg: tuple<memref<15xi32>, memref<2xi32>, i32> ) -> i32 {
    // CHECK: func.func @main(%arg0: memref<15xi32>, %arg1: memref<2xi32>, %arg2: i32) -> i32 {
    %0 = fifo.get_tuple_element %tuple_arg[2] : tuple<memref<15xi32>, memref<2xi32>, i32> -> i32
    func.return %0 : i32
    // CHECK: return %arg2 : i32
}

%result = func.call @main(%tuple) : (tuple<memref<15xi32>, memref<2xi32>, i32>) -> i32
// CHECK: %0 = func.call @main(%alloc, %alloc_0, %c15_i32) : (memref<15xi32>, memref<2xi32>, i32) -> i32


func.func @if_result(%arg0: tuple<memref<15xi32>, memref<2xi32>, i32>, %arg1: i1) -> tuple<memref<15xi32>, memref<2xi32>, i32> {
  // CHECK: func.func @if_result(%arg0: memref<15xi32>, %arg1: memref<2xi32>, %arg2: i32, %arg3: i1) -> (memref<15xi32>, memref<2xi32>, i32) {
  %0 = scf.if %arg1 -> (tuple<memref<15xi32>, memref<2xi32>, i32>) {
    scf.yield %arg0 : tuple<memref<15xi32>, memref<2xi32>, i32>
    // CHECK: scf.yield %arg0, %arg1, %arg2 : memref<15xi32>, memref<2xi32>, i32
  } else {
    scf.yield %arg0 : tuple<memref<15xi32>, memref<2xi32>, i32>
    // CHECK: scf.yield %arg0, %arg1, %arg2 : memref<15xi32>, memref<2xi32>, i32
  }
  return %0 : tuple<memref<15xi32>, memref<2xi32>, i32>
  // CHECK: return %1#0, %1#1, %1#2 : memref<15xi32>, memref<2xi32>, i3
}

func.func @while_operands_results(%arg0: tuple<tuple<>, i1, tuple<i2>>, %arg1: i1) -> tuple<tuple<>, i1, tuple<i2>> {
  %0 = scf.while (%arg2 = %arg0) : (tuple<tuple<>, i1, tuple<i2>>) -> tuple<tuple<>, i1, tuple<i2>> {
    scf.condition(%arg1) %arg2 : tuple<tuple<>, i1, tuple<i2>>
  } do {
  ^bb0(%arg2: tuple<tuple<>, i1, tuple<i2>>):
    scf.yield %arg2 : tuple<tuple<>, i1, tuple<i2>>
  }
  return %0 : tuple<tuple<>, i1, tuple<i2>>
}

// CHECK: func.func @while_operands_results(%arg0: i1, %arg1: i2, %arg2: i1) -> (i1, i2) {
// CHECK:   %1:2 = scf.while (%arg3 = %arg0, %arg4 = %arg1) : (i1, i2) -> (i1, i2) {
// CHECK:     scf.condition(%arg2) %arg3, %arg4 : i1, i2
// CHECK:   } do {
// CHECK:   ^bb0(%arg3: i1, %arg4: i2):
// CHECK:     scf.yield %arg3, %arg4 : i1, i2
// CHECK:   }
// CHECK:   return %1#0, %1#1 : i1, i2
// CHECK: }

