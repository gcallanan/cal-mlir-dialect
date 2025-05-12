// RUN: cal-opt %s | FileCheck %s

cal.actor @my_actor()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out (%out0: !fifo.input_port<i32>)
{
    %c1 = arith.constant 10 : i32

    cal.action
    {
        %c2 = arith.constant 11 : i32
        %c3 = arith.addi %c1, %c2 : i32
        cal.action_done
    }

    cal.action
    {
        %c2 = arith.constant 11 : i32
        %c3 = arith.addi %c1, %c2 : i32
        cal.action_not_done
    }

    cal.action
    {
        %0 = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        cal.action_done
    }

}

// CHECK: module {
// CHECK-NEXT:   cal.actor @my_actor()
// CHECK-NEXT:     ports_in (
// CHECK-NEXT:       %arg0: !fifo.output_port<i32>
// CHECK-NEXT:     )
// CHECK-NEXT:     ports_out (
// CHECK-NEXT:       %arg1: !fifo.input_port<i32>
// CHECK-NEXT:     )
// CHECK-NEXT:   {
// CHECK-NEXT:     %c10_i32 = arith.constant 10 : i32
// CHECK-NEXT:     cal.action {
// CHECK-NEXT:       %c11_i32 = arith.constant 11 : i32
// CHECK-NEXT:       %0 = arith.addi %c10_i32, %c11_i32 : i32
// CHECK-NEXT:       cal.action_done
// CHECK-NEXT:     }
// CHECK-NEXT:     cal.action {
// CHECK-NEXT:       %c11_i32 = arith.constant 11 : i32
// CHECK-NEXT:       %0 = arith.addi %c10_i32, %c11_i32 : i32
// CHECK-NEXT:       cal.action_not_done
// CHECK-NEXT:     }
// CHECK-NEXT:     cal.action {
// CHECK-NEXT:       %0 = fifo.pop(%arg0 : !fifo.output_port<i32>) : i32
// CHECK-NEXT:       cal.action_done
// CHECK-NEXT:     }
// CHECK-NEXT:   }
// CHECK: }
