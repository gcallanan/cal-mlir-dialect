// RUN: cal-opt --convert-cal-to-func -split-input-file %s -verify-diagnostics

// expected-error @+1 {{cal.actor contains cal.action - cannot convert to func dialect}}
cal.actor @src(%max_tokens_to_send: i32)
    ports_out(%out0: !fifo.input_port<i32>)
{
    %c1 = arith.constant 10 : i32
    %s1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%s1: !cal.state_ref<i32>, %c1: i32)

    cal.action {   
    }

    cal.action {
    }
}

cal.network{
    %0 = arith.constant 11 : i32

    %in0, %out0 = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>

    cal.create_instance @src "srcA" (%0: i32)
            ports_out(%in0 : !fifo.input_port<i32>)
}