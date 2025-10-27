// Peek-based routing: route tokens to out0/out1 based on parity without consuming during predicate.
// Run:
//   cal-opt --lower-cal-fsm-to-execution-body --lower-cal-to-llvm examples/fsm/peek_routing.mlir \
//     | cal-translate --mlir-to-llvmir \
//     | lli

// Router FSM with one input and two outputs
cal.actor @router()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>, %out1: !fifo.input_port<i32>)
{
    cal.fsm {
        cal.state @S {
            cal.transition action("to0") -> @S
            cal.transition action("to1") -> @S
        } { initial }
    }

    // If fifo has data and next token is even -> to0
    cal.action "to0" {
        cal.predicate {
            %sz = fifo.size(%in0: !fifo.output_port<i32>) : index
            %zero = arith.constant 0 : index
            %has = arith.cmpi sgt, %sz, %zero : index
            // Peek at the front token
            %i0 = arith.constant 0 : index
            %peek = fifo.peek(%in0: !fifo.output_port<i32>, %i0: index) : i32
            %two = arith.constant 2 : i32
            %rem = arith.remsi %peek, %two : i32
            %zero_i32 = arith.constant 0 : i32
            %is_even = arith.cmpi eq, %rem, %zero_i32 : i32
            %ok = arith.andi %has, %is_even : i1
            cal.predicate_result %ok : i1
        }
        %t = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        fifo.print("ROUTER even %d\0A\00", %t) : (i32)
        fifo.push(%out0: !fifo.input_port<i32>, %t: i32)
    }

    // Else if odd -> to1
    cal.action "to1" {
        cal.predicate {
            %sz = fifo.size(%in0: !fifo.output_port<i32>) : index
            %zero = arith.constant 0 : index
            %has = arith.cmpi sgt, %sz, %zero : index
            %i0 = arith.constant 0 : index
            %peek = fifo.peek(%in0: !fifo.output_port<i32>, %i0: index) : i32
            %two = arith.constant 2 : i32
            %rem = arith.remsi %peek, %two : i32
            %zero_i32 = arith.constant 0 : i32
            %is_odd = arith.cmpi ne, %rem, %zero_i32 : i32
            %ok = arith.andi %has, %is_odd : i1
            cal.predicate_result %ok : i1
        }
        %t = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        fifo.print("ROUTER odd %d\0A\00", %t) : (i32)
        fifo.push(%out1: !fifo.input_port<i32>, %t: i32)
    }
}

// Simple source and dual sinks
cal.actor @src(%n: i32)
    ports_out(%out0: !fifo.input_port<i32>)
{
    %c = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%c: !cal.state_ref<i32>, %c0: i32)
    cal.action "send" {
        cal.predicate {
            %v = cal.get(%c: !cal.state_ref<i32>) : i32
            %ok = arith.cmpi slt, %v, %n : i32
            cal.predicate_result %ok : i1
        }
        %v0 = cal.get(%c: !cal.state_ref<i32>) : i32
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
        fifo.print("S %d\0A\00", %t) : (i32)
    }
}

cal.network @router_net() {
    %ten = arith.constant 10 : i32
    %in_src, %out_src = fifo.create<i32>(6) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %in0, %out0 = fifo.create<i32>(6) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %in1, %out1 = fifo.create<i32>(6) : !fifo.input_port<i32>, !fifo.output_port<i32>

    cal.create_instance @src "src" (%ten : i32)
        ports_out(%in_src : !fifo.input_port<i32>)

    cal.create_instance @router "router" ()
        ports_in(%out_src : !fifo.output_port<i32>)
        ports_out(%in0, %in1 : !fifo.input_port<i32>, !fifo.input_port<i32>)

    cal.create_instance @sink "sink0" ()
        ports_in(%out0 : !fifo.output_port<i32>)
    cal.create_instance @sink "sink1" ()
        ports_in(%out1 : !fifo.output_port<i32>)
}
