// Priority attribute example: two transitions with both predicates true; the higher priority action fires
// regardless of textual order.
// Run:
//   cal-opt --lower-cal-fsm-to-execution-body --lower-cal-to-llvm examples/fsm/priority_attribute.mlir \
//     | cal-translate --mlir-to-llvmir \
//     | lli

cal.actor @chooser(%n: i32)
    ports_out(%out0: !fifo.input_port<i32>)
{
    %c = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%c: !cal.state_ref<i32>, %c0: i32)

    // FSM single state
    cal.fsm { cal.state @S { cal.transition action("low") -> @S cal.transition action("high") -> @S } { initial } }

    // Note: textual order lists "low" first, but "high" has greater priority
    cal.action "low" priority=1
    {
        cal.predicate {
            %v = cal.get(%c: !cal.state_ref<i32>) : i32
            %ok = arith.cmpi slt, %v, %n : i32
            cal.predicate_result %ok : i1
        }
        %v0 = cal.get(%c: !cal.state_ref<i32>) : i32
        fifo.print("LOW %d\0A\00", %v0) : (i32)
        %one = arith.constant 1 : i32
        %v1 = arith.addi %v0, %one : i32
        cal.set(%c: !cal.state_ref<i32>, %v1: i32)
        fifo.push(%out0: !fifo.input_port<i32>, %v0: i32)
    }

    cal.action "high" priority=10
    {
        cal.predicate {
            %v = cal.get(%c: !cal.state_ref<i32>) : i32
            %ok = arith.cmpi slt, %v, %n : i32
            cal.predicate_result %ok : i1
        }
        %v0 = cal.get(%c: !cal.state_ref<i32>) : i32
        fifo.print("HIGH %d\0A\00", %v0) : (i32)
        %one = arith.constant 1 : i32
        %v1 = arith.addi %v0, %one : i32
        cal.set(%c: !cal.state_ref<i32>, %v1: i32)
        fifo.push(%out0: !fifo.input_port<i32>, %v0: i32)
    }
}

cal.actor @sink()
    ports_in(%in0: !fifo.output_port<i32>)
{
    cal.action {
        %t = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        fifo.print("SINK %d\0A\00", %t) : (i32)
    }
}

cal.network @chooser_priority() {
    %ten = arith.constant 5 : i32
    %in0, %out0 = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>

    cal.create_instance @chooser "chooser" (%ten : i32)
        ports_out(%in0 : !fifo.input_port<i32>)

    cal.create_instance @sink "sink" ()
        ports_in(%out0 : !fifo.output_port<i32>)
}
