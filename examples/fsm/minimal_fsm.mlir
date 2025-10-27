// Minimal example: cal.fsm scheduling a single action in a loop
//
// How to run (from repo root):
// 1) Lower FSM and CAL to LLVM dialect, translate to LLVM IR, and run:
//    cal-opt --lower-cal-fsm-to-execution-body --lower-cal-to-llvm examples/fsm/minimal_fsm.mlir \
//      | cal-translate --mlir-to-llvmir \
//      | lli
//
// Expected output: ten lines from the source and ten lines from the sink
// (order may interleave depending on scheduling), e.g.:
//   Src 1, pushed token: 0
//   Popped Token: 0
//   ... up to 9

// Source actor with an FSM: repeatedly fires action "send" while tokens < max
cal.actor @src_fsm(%max_tokens_to_send: i32, %actor_index: i32)
    ports_out(%out0: !fifo.input_port<i32>)
{
    // State initialization
    %num_tokens_sent_state = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %c0: i32)

    // Finite State Machine: single initial state S0 that loops on action "send"
    cal.fsm {
        cal.state @S0 {
            cal.transition action("send") -> @S0
    } { initial }
    }

    // Action to send a token while under the limit
    cal.action "send" {
        cal.predicate {
            %num_tokens_sent = cal.get(%num_tokens_sent_state: !cal.state_ref<i32>) : i32
            %cmp_sent = arith.cmpi slt, %num_tokens_sent, %max_tokens_to_send : i32
            cal.predicate_result %cmp_sent : i1
        }
        // Update counter
        %one_i32 = arith.constant 1 : i32
        %tokens_sent = cal.get(%num_tokens_sent_state: !cal.state_ref<i32>) : i32
        %tokens_sent_plus_one = arith.addi %tokens_sent, %one_i32 : i32
        cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %tokens_sent_plus_one: i32)

        // Compute value to send
        %one_hundred = arith.constant 100 : i32
        %actor_index_by_100 = arith.muli %actor_index, %one_hundred : i32
        %value_to_send = arith.addi %tokens_sent, %actor_index_by_100 : i32

        // Send and print
        fifo.push(%out0: !fifo.input_port<i32>, %value_to_send: i32)
        fifo.print("Src %d, pushed token: %d\0A\00", %actor_index ,%value_to_send) : (i32, i32)
    }
}

// Sink actor that pops and prints
cal.actor @sink()
    ports_in(%in0: !fifo.output_port<i32>)
{
    cal.action {
        %token = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        fifo.print("Popped Token: %d\0A\00", %token) : (i32)
    }
}

// Network wiring source to sink via a small FIFO
cal.network @fsm_net() {
    %ten   = arith.constant 10 : i32
    %one   = arith.constant 1  : i32

    %in0, %out0 = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>

    cal.create_instance @src_fsm "src" (%ten, %one : i32, i32)
            ports_out(%in0 : !fifo.input_port<i32>)

    cal.create_instance @sink "sink" ()
            ports_in(%out0 : !fifo.output_port<i32>)
}
