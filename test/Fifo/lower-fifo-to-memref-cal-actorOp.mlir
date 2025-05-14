// RUN: cal-opt --lower-fifo-to-memref %s | FileCheck %s

cal.actor @my_actor (%c5: i32, %c4: i32)
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out (%out0: !fifo.input_port<i32>)
{
    cal.action
    {
        %0 = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        %true = arith.constant true
        cal.action_done %true : i1
    }

}

// CHECK: cal.actor @my_actor(%arg0: i32, %arg1: i32, %arg2: tuple<memref<?xi32>, memref<2xi32>, i32>, %arg3: tuple<memref<?xi32>, memref<2xi32>, i32>)
// CHECK-NEXT: {
// CHECK-NEXT:   cal.action {
// CHECK-NEXT:     %0 = fifo.get_tuple_element %arg2[0] : tuple<memref<?xi32>, memref<2xi32>, i32> -> memref<?xi32>
// CHECK-NEXT:     %1 = fifo.get_tuple_element %arg2[1] : tuple<memref<?xi32>, memref<2xi32>, i32> -> memref<2xi32>
// CHECK-NEXT:     %2 = fifo.get_tuple_element %arg2[2] : tuple<memref<?xi32>, memref<2xi32>, i32> -> i32
// CHECK-NEXT:     %c0 = arith.constant 0 : index
// CHECK-NEXT:     %3 = memref.load %1[%c0] : memref<2xi32>
// CHECK-NEXT:     %4 = arith.index_cast %3 : i32 to index
// CHECK-NEXT:     %5 = memref.load %0[%4] : memref<?xi32>
// CHECK-NEXT:     %c1_i32 = arith.constant 1 : i32
// CHECK-NEXT:     %6 = arith.addi %3, %c1_i32 : i32
// CHECK-NEXT:     %7 = arith.remsi %6, %2 : i32
// CHECK-NEXT:     memref.store %7, %1[%c0] : memref<2xi32>
// CHECK-NEXT:     %true = arith.constant true
// CHECK-NEXT:     cal.action_done %true : i1
// CHECK-NEXT:   }
// CHECK-NEXT: }