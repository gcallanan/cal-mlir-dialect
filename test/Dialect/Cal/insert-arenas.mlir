// RUN: cal-opt --cal-insert-arenas %s | FileCheck %s

// Test arena insertion for actors with recursive algebraic types.
// Arenas should be created at execution_body entry and destroyed before action_done.
// These tests use operations pre-marked with cal.recursive_type or cal.recursive_token
// attributes, as would be done by the cal-detect-recursive-types pass.

// -----------------------------------------------------------------------------
// Test 1: Actor with operation marked as recursive
// Arena should be inserted because the operation has cal.recursive_type attr
// -----------------------------------------------------------------------------

// CHECK-LABEL: cal.actor @actor_with_recursive_ops
// CHECK:       cal.execution_body
// CHECK-NEXT:    %[[ARENA:.*]] = cal.arena.create : !cal.arena
// CHECK:         cal.arena.destroy %[[ARENA]] : !cal.arena
// CHECK-NEXT:    cal.action_done

cal.actor @actor_with_recursive_ops()
    ports_out(%out0: !fifo.input_port<i32>)
{
    cal.execution_body {
        // Simulate a variant.create operation that is marked as recursive
        // The detect-recursive-types pass would add this attribute
        %c42 = arith.constant {cal.recursive_type} 42 : i32
        
        fifo.push(%out0: !fifo.input_port<i32>, %c42: i32)
        
        %true = arith.constant 1 : i1
        cal.action_done %true : i1
    }
}

// -----------------------------------------------------------------------------
// Test 2: Actor without recursive types (no arena needed)
// -----------------------------------------------------------------------------

// CHECK-LABEL: cal.actor @simple_actor
// CHECK:       cal.execution_body
// CHECK-NOT:   cal.arena.create
// CHECK:       cal.action_done

cal.actor @simple_actor()
    ports_out(%out0: !fifo.input_port<i32>)
{
    cal.execution_body {
        %c42 = arith.constant 42 : i32
        fifo.push(%out0: !fifo.input_port<i32>, %c42: i32)
        %true = arith.constant 1 : i1
        cal.action_done %true : i1
    }
}

// -----------------------------------------------------------------------------
// Test 3: Actor with FIFO operation marked as recursive token
// -----------------------------------------------------------------------------

// CHECK-LABEL: cal.actor @fifo_recursive_actor
// CHECK:       cal.execution_body
// CHECK-NEXT:    %[[ARENA:.*]] = cal.arena.create : !cal.arena
// CHECK:         cal.arena.destroy %[[ARENA]] : !cal.arena
// CHECK-NEXT:    cal.action_done

cal.actor @fifo_recursive_actor()
    ports_in(%in0: !fifo.output_port<i32>)
{
    cal.execution_body {
        // This pop is marked as transferring a recursive type token
        %token = fifo.pop(%in0: !fifo.output_port<i32>) {cal.recursive_token} : i32
        
        %true = arith.constant 1 : i1
        cal.action_done %true : i1
    }
}

// -----------------------------------------------------------------------------
// Test 4: Multiple operations with recursive attributes
// -----------------------------------------------------------------------------

// CHECK-LABEL: cal.actor @multiple_recursive_ops
// CHECK:       cal.execution_body
// CHECK-NEXT:    %[[ARENA:.*]] = cal.arena.create : !cal.arena
// CHECK:         cal.arena.destroy %[[ARENA]] : !cal.arena
// CHECK-NEXT:    cal.action_done

cal.actor @multiple_recursive_ops()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>)
{
    cal.execution_body {
        // Pop with recursive token
        %token = fifo.pop(%in0: !fifo.output_port<i32>) {cal.recursive_token} : i32
        
        // Some computation marked as recursive
        %result = arith.addi %token, %token {cal.recursive_type} : i32
        
        // Push with recursive token
        fifo.push(%out0: !fifo.input_port<i32>, %result: i32) {cal.recursive_token}
        
        %true = arith.constant 1 : i1
        cal.action_done %true : i1
    }
}
