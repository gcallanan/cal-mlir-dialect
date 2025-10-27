// Availability-driven arbiter: chooses between two inputs based on fifo.size>0.
// Run:
//   cal-opt --lower-cal-fsm-to-execution-body --lower-cal-to-llvm examples/fsm/availability_arbiter.mlir \
//     | cal-translate --mlir-to-llvmir \
//     | lli

// Source actor (same pattern as other examples)
cal.actor @src(%max_tokens_to_send: i32, %actor_index: i32)
    ports_out(%out0: !fifo.input_port<i32>)
{
    %num = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%num: !cal.state_ref<i32>, %c0: i32)

    cal.action "send" {
        cal.predicate {
            %v = cal.get(%num: !cal.state_ref<i32>) : i32
            %ok = arith.cmpi slt, %v, %max_tokens_to_send : i32
            cal.predicate_result %ok : i1
        }
        %one = arith.constant 1 : i32
        %v0 = cal.get(%num: !cal.state_ref<i32>) : i32
        %v1 = arith.addi %v0, %one : i32
        cal.set(%num: !cal.state_ref<i32>, %v1: i32)
        %hund = arith.constant 100 : i32
        %idx100 = arith.muli %actor_index, %hund : i32
        %val = arith.addi %v0, %idx100 : i32
        fifo.push(%out0: !fifo.input_port<i32>, %val: i32)
        fifo.print("Src %d -> %d\0A\00", %actor_index, %val) : (i32, i32)
    }
}

// Arbiter FSM: one state, two transitions to itself; pick in0 if available, else in1
cal.actor @arbiter()
    ports_in(%in0: !fifo.output_port<i32>, %in1: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>)
{
    cal.fsm {
        cal.state @S {
            cal.transition action("from0") -> @S
            cal.transition action("from1") -> @S
        } { initial }
    }

    cal.action "from0" {
        cal.predicate {
            %sz = fifo.size(%in0: !fifo.output_port<i32>) : index
            %zero = arith.constant 0 : index
            %ok = arith.cmpi sgt, %sz, %zero : index
            cal.predicate_result %ok : i1
        }
        %t = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        fifo.print("ARB 0 %d\0A\00", %t) : (i32)
        fifo.push(%out0: !fifo.input_port<i32>, %t: i32)
    }

    cal.action "from1" {
        cal.predicate {
            %sz = fifo.size(%in1: !fifo.output_port<i32>) : index
            %zero = arith.constant 0 : index
            %ok = arith.cmpi sgt, %sz, %zero : index
            cal.predicate_result %ok : i1
        }
        %t = fifo.pop(%in1: !fifo.output_port<i32>) : i32
        fifo.print("ARB 1 %d\0A\00", %t) : (i32)
        fifo.push(%out0: !fifo.input_port<i32>, %t: i32)
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

cal.network @arbiter_net() {
    %ten = arith.constant 10 : i32
    %one = arith.constant 1 : i32
    %two = arith.constant 2 : i32

    %a_in, %a_out = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %b_in, %b_out = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %s_in, %s_out = fifo.create<i32>(6) : !fifo.input_port<i32>, !fifo.output_port<i32>

    cal.create_instance @src "A" (%ten, %one : i32, i32)
        ports_out(%a_in : !fifo.input_port<i32>)
    cal.create_instance @src "B" (%ten, %two : i32, i32)
        ports_out(%b_in : !fifo.input_port<i32>)

    cal.create_instance @arbiter "arb" ()
        ports_in(%a_out, %b_out : !fifo.output_port<i32>, !fifo.output_port<i32>)
        ports_out(%s_in : !fifo.input_port<i32>)

    cal.create_instance @sink "sink" ()
        ports_in(%s_out : !fifo.output_port<i32>)
}
