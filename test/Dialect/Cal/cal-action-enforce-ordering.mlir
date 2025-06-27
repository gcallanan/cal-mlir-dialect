// Here we check that the cal.action operation produces expected errors
// RUN: cal-opt -split-input-file %s -verify-diagnostics

// -----

cal.actor @my_actor()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out (%out0: !fifo.input_port<i32>)
{
    %c1 = arith.constant 10 : i32
    %s1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%s1: !cal.state_ref<i32>, %c1: i32)

    // expected-error @+1 {{'cal.action' op cal.set operations must be after fifo.pop and cal.predicate operations and before fifo.push operations in the body of the cal.action}}
    cal.action {
        cal.predicate {
            %true = arith.constant 1 : i1
            cal.predicate_result %true : i1
        }
        cal.predicate {
            %true = arith.constant 1 : i1
            cal.predicate_result %true : i1
        }
        %0 = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        %c2 = arith.constant 10 : i32
        %2 = cal.get(%s1: !cal.state_ref<i32>) : i32
        %3 = arith.addi %0, %2 : i32
        %4 = arith.addi %3, %c2 : i32
        %1 = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        fifo.push(%out0: !fifo.input_port<i32>, %3: i32)
        cal.set(%s1: !cal.state_ref<i32>, %4: i32)
        fifo.push(%out0: !fifo.input_port<i32>, %0: i32)
    }
}

// -----

cal.actor @my_actor()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out (%out0: !fifo.input_port<i32>)
{
    %c1 = arith.constant 10 : i32
    %s1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%s1: !cal.state_ref<i32>, %c1: i32)

    // expected-error @+1 {{'cal.action' op fifo.pop operations must be before cal.set and fifo.push operations and after cal.predicate operations in the body of the cal.action}}
    cal.action {
        cal.predicate {
            %true = arith.constant 1 : i1
            cal.predicate_result %true : i1
        }
        cal.predicate {
            %true = arith.constant 1 : i1
            cal.predicate_result %true : i1
        }
        %0 = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        %c2 = arith.constant 10 : i32
        %2 = cal.get(%s1: !cal.state_ref<i32>) : i32
        %3 = arith.addi %0, %2 : i32
        %4 = arith.addi %3, %c2 : i32
        cal.set(%s1: !cal.state_ref<i32>, %4: i32)
        %1 = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        fifo.push(%out0: !fifo.input_port<i32>, %3: i32)
        fifo.push(%out0: !fifo.input_port<i32>, %0: i32)
    }
}

// -----

cal.actor @my_actor()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out (%out0: !fifo.input_port<i32>)
{
    %c1 = arith.constant 10 : i32
    %s1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%s1: !cal.state_ref<i32>, %c1: i32)

    // expected-error @+1 {{'cal.action' op cal.predicate operations must be before fifo.pop, cal.set, and fifo.push operations in the body of the cal.action}}
    cal.action {
        cal.predicate {
            %true = arith.constant 1 : i1
            cal.predicate_result %true : i1
        }
        %0 = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        cal.predicate {
            %true = arith.constant 1 : i1
            cal.predicate_result %true : i1
        }
        %1 = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        %c2 = arith.constant 10 : i32
        %2 = cal.get(%s1: !cal.state_ref<i32>) : i32
        %3 = arith.addi %0, %2 : i32
        %4 = arith.addi %3, %c2 : i32
        cal.set(%s1: !cal.state_ref<i32>, %4: i32)
        fifo.push(%out0: !fifo.input_port<i32>, %3: i32)
        fifo.push(%out0: !fifo.input_port<i32>, %0: i32)
    }
}

// -----