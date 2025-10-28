// Dead-state FSM example: actor terminates after entering S3 (no outgoing transitions)
// How to run:
//   cal-opt --lower-cal-to-llvm examples/fsm/dead_state.mlir \
//     | cal-translate --mlir-to-llvmir \
//     | lli

// Actor with 4 states: S0->a0->S1->a1->S2->a2->S3 (terminal)
// S3 has no outgoing transitions; once reached, the actor performs no further actions.
cal.actor @dead_demo(%max: i32)
    ports_out(%out0: !fifo.input_port<i32>)
{
    %ctr = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%ctr: !cal.state_ref<i32>, %c0: i32)

    cal.fsm {
        cal.state @S0 { cal.transition action("a0") -> @S1 } { initial }
        cal.state @S1 { cal.transition action("a1") -> @S2 }
        cal.state @S2 { cal.transition action("a2") -> @S3 }
        // Terminal state: no transitions
        cal.state @S3 { }
    }

    // a0 increments and emits
    cal.action "a0" {
        cal.predicate {
            %v = cal.get(%ctr: !cal.state_ref<i32>) : i32
            %ok = arith.cmpi slt, %v, %max : i32
            cal.predicate_result %ok : i1
        }
        %v0 = cal.get(%ctr: !cal.state_ref<i32>) : i32
        fifo.print("A0 %d\0A\00", %v0) : (i32)
        %one = arith.constant 1 : i32
        %v1 = arith.addi %v0, %one : i32
        cal.set(%ctr: !cal.state_ref<i32>, %v1: i32)
        fifo.push(%out0: !fifo.input_port<i32>, %v0: i32)
    }

    // a1 emits without increment
    cal.action "a1" {
        cal.predicate {
            %v = cal.get(%ctr: !cal.state_ref<i32>) : i32
            %ok = arith.cmpi slt, %v, %max : i32
            cal.predicate_result %ok : i1
        }
        %v0 = cal.get(%ctr: !cal.state_ref<i32>) : i32
        fifo.print("A1 %d\0A\00", %v0) : (i32)
        fifo.push(%out0: !fifo.input_port<i32>, %v0: i32)
    }

    // a2 emits and moves to S3 (terminal)
    cal.action "a2" {
        cal.predicate {
            %v = cal.get(%ctr: !cal.state_ref<i32>) : i32
            %ok = arith.cmpi slt, %v, %max : i32
            cal.predicate_result %ok : i1
        }
        %v0 = cal.get(%ctr: !cal.state_ref<i32>) : i32
        fifo.print("A2 %d\0A\00", %v0) : (i32)
        fifo.push(%out0: !fifo.input_port<i32>, %v0: i32)
    }
}

cal.actor @sink()
    ports_in(%in0: !fifo.output_port<i32>)
{
    cal.action {
        %t = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        fifo.print("Got %d\0A\00", %t) : (i32)
    }
}

cal.network @dead_net() {
    %lim = arith.constant 3 : i32
    %in0, %out0 = fifo.create<i32>(4) : !fifo.input_port<i32>, !fifo.output_port<i32>

    cal.create_instance @dead_demo "demo" (%lim : i32)
        ports_out(%in0 : !fifo.input_port<i32>)

    cal.create_instance @sink "sink" ()
        ports_in(%out0 : !fifo.output_port<i32>)
}
