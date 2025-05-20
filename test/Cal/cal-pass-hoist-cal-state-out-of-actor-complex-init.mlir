// RUN: cal-opt --hoist-cal-state-out-of-actor  %s | FileCheck %s

cal.actor @src(%temp: i32)
    ports_out(%out0: !fifo.input_port<i32>)
{
    %num_tokens_sent_state = cal.create_state_var<i32> : !cal.state_ref<i32>
    
    %zero = arith.constant 0 : i32
    %cond = arith.cmpi sgt, %temp, %zero : i32
    %result = scf.if %cond -> (i32) {
        %c1 = arith.constant 1 : i32
        %res = arith.addi %temp, %c1 : i32
        scf.yield %res : i32
    } else {
        %c2 = arith.constant 2 : i32
        %res = arith.subi %temp, %c2 : i32
        scf.yield %res : i32
    }
    cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %result: i32)

    cal.execution_body
    {
        %true = arith.constant 1 : i1
        cal.action_done %true : i1
    }
}

// CHECK:  cal.actor @src(%arg0: i32, %arg2: !cal.state_ref<i32>, %arg3: i1, %arg4: i32)
// CHECK-NEXT:    ports_out (
// CHECK-NEXT:      %arg1: !fifo.input_port<i32>
// CHECK-NEXT:    )
// CHECK-NEXT:  {
// CHECK-NEXT:    %true = arith.constant true
// CHECK-NEXT:    cal.execution_body {
// CHECK-NEXT:      cal.action_done %true : i1
// CHECK-NEXT:    }
// CHECK-NEXT:  }

  




cal.network {
    %0 = arith.constant 10 : i32
    %1 = arith.constant 10 : i32

    %in0, %out0 = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %in1, %out1 = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>

    cal.create_instance @src "srcA" (%0: i32)
            ports_out(%in0 : !fifo.input_port<i32>)

// CHECK:  cal.network {
// CHECK-NEXT:    %c8_i32 = arith.constant 8 : i32
// CHECK-NEXT:    %c11_i32 = arith.constant 11 : i32
// CHECK-NEXT:    %true = arith.constant true
// CHECK-NEXT:    %c10_i32 = arith.constant 10 : i32
// CHECK-NEXT:    %inputPort, %outputPort = fifo.create<i32> (3) : !fifo.input_port<i32>, !fifo.output_port<i32>
// CHECK-NEXT:    %inputPort_0, %outputPort_1 = fifo.create<i32> (3) : !fifo.input_port<i32>, !fifo.output_port<i32>
// CHECK-NEXT:    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
// CHECK-NEXT:    %1 = scf.if %true -> (i32) {
// CHECK-NEXT:      scf.yield %c11_i32 : i32
// CHECK-NEXT:    } else {
// CHECK-NEXT:      scf.yield %c8_i32 : i32
// CHECK-NEXT:    }
// CHECK-NEXT:    cal.set(%0 : !cal.state_ref<i32>, %1 : i32)
// CHECK-NEXT:    cal.create_instance @src "srcA" (%c10_i32, %0, %true, %1 : i32, !cal.state_ref<i32>, i1, i32)
// CHECK-NEXT:        ports_out (%inputPort : !fifo.input_port<i32>)
// CHECK-NEXT:  }

}