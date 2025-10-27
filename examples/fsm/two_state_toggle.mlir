// Two-state toggle FSM: alternates between S0 and S1 until a limit
// How to run:
//   cal-opt --lower-cal-fsm-to-execution-body --lower-cal-to-llvm examples/fsm/two_state_toggle.mlir \
//     | cal-translate --mlir-to-llvmir \
//     | lli

cal.actor @toggle(%max: i32)
    ports_out(%out0: !fifo.input_port<i32>)
{
    // State: shared counter
    %counter = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%counter: !cal.state_ref<i32>, %c0: i32)

    // FSM: S0 -> a0 -> S1, S1 -> a1 -> S0
    cal.fsm {
        cal.state @S0 {
            cal.transition action("a0") -> @S1
        } { initial }
        cal.state @S1 {
            cal.transition action("a1") -> @S0
        }
    }

    // Action a0: prints "A0" with current counter, increments if counter < max
    cal.action "a0" {
        cal.predicate {
            %v = cal.get(%counter: !cal.state_ref<i32>) : i32
            %ok = arith.cmpi slt, %v, %max : i32
            cal.predicate_result %ok : i1
        }
        %v0 = cal.get(%counter: !cal.state_ref<i32>) : i32
        fifo.print("A0 %d\0A\00", %v0) : (i32)
        %one = arith.constant 1 : i32
        %v1 = arith.addi %v0, %one : i32
        cal.set(%counter: !cal.state_ref<i32>, %v1: i32)
        fifo.push(%out0: !fifo.input_port<i32>, %v0: i32)
    }

    // Action a1: prints "A1" with current counter
    cal.action "a1" {
        cal.predicate {
            %v = cal.get(%counter: !cal.state_ref<i32>) : i32
            %ok = arith.cmpi slt, %v, %max : i32
            cal.predicate_result %ok : i1
        }
        %v0 = cal.get(%counter: !cal.state_ref<i32>) : i32
        fifo.print("A1 %d\0A\00", %v0) : (i32)
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

cal.network @toggle_net() {
    %limit = arith.constant 6 : i32
    %in0, %out0 = fifo.create<i32>(4) : !fifo.input_port<i32>, !fifo.output_port<i32>

    cal.create_instance @toggle "toggle" (%limit : i32)
        ports_out(%in0 : !fifo.input_port<i32>)

    cal.create_instance @sink "sink" ()
        ports_in(%out0 : !fifo.output_port<i32>)
}
