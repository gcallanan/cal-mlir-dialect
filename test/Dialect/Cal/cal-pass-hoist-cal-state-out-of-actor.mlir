// RUN: cal-opt --hoist-cal-state-out-of-actor  %s | FileCheck %s

// CHECK:  cal.actor @src(%arg0: i32, %arg2: !cal.state_ref<i32>)
// CHECK-NEXT:    ports_out (
// CHECK-NEXT:      %arg1: !fifo.input_port<i32>
// CHECK-NEXT:    )
// CHECK-NEXT:  {
// CHECK-NEXT:    %true = arith.constant true
// CHECK-NEXT:    cal.execution_body {
// CHECK-NEXT:      cal.action_done %true : i1
// CHECK-NEXT:    }
// CHECK-NEXT:  }
cal.actor @src(%max_tokens_to_send: i32)
    ports_out(%out0: !fifo.input_port<i32>)
{
    %num_tokens_sent_state = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %c0: i32)

    cal.execution_body
    {
        %true = arith.constant 1 : i1
        cal.action_done %true : i1
    }
}

// CHECK: cal.actor @src2(%arg0: i32, %arg2: !cal.state_ref<i32>)
// CHECK-NEXT:     ports_out (
// CHECK-NEXT:       %arg1: !fifo.input_port<i32>
// CHECK-NEXT:     )
// CHECK-NEXT:   {
// CHECK-NEXT:     %c20_i32 = arith.constant 20 : i32
// CHECK-NEXT:     %c10_i32 = arith.constant 10 : i32
// CHECK-NEXT:     cal.action
cal.actor @src2(%max_tokens_to_send: i32)
    ports_out(%out0: !fifo.input_port<i32>)
{
    %num_tokens_sent_state = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %c0: i32)

    cal.action
    {
        %c10 = arith.constant 10 : i32
        cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %c10: i32)
    }

    cal.action
    {
        %c20 = arith.constant 20 : i32
        cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %c20: i32)
    }
}

cal.network {
    %0 = arith.constant 10 : i32
    %1 = arith.constant 10 : i32

    %in0, %out0 = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %in1, %out1 = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>

    // CHECK:    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    // CHECK-NEXT:    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    // CHECK-NEXT:    cal.create_instance @src "srcA" (%c10_i32, %0 : i32, !cal.state_ref<i32>)
    // CHECK-NEXT:        ports_out (%inputPort : !fifo.input_port<i32>)
    cal.create_instance @src "srcA" (%0: i32)
            ports_out(%in0 : !fifo.input_port<i32>)

    // CHECK:    %1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    // CHECK-NEXT:    cal.set(%1 : !cal.state_ref<i32>, %c0_i32 : i32)
    // CHECK-NEXT:    cal.create_instance @src "srcB" (%c10_i32, %1 : i32, !cal.state_ref<i32>)
    // CHECK-NEXT:        ports_out (%inputPort_0 : !fifo.input_port<i32>)
    cal.create_instance @src "srcB" (%1: i32)
            ports_out(%in1 : !fifo.input_port<i32>)

    // CHECK: %2 = cal.create_state_var<i32> : !cal.state_ref<i32>
    // CHECK-NEXT: cal.set(%2 : !cal.state_ref<i32>, %c0_i32 : i32)
    // CHECK-NEXT: cal.create_instance @src2 "src2" (%c10_i32, %2 : i32, !cal.state_ref<i32>)
    // CHECK-NEXT:     ports_out (%inputPort_0 : !fifo.input_port<i32>)
    cal.create_instance @src2 "src2" (%1: i32)
            ports_out(%in1 : !fifo.input_port<i32>)
}