// RUN: cal-opt --cal-insert-rc-for-state %s | FileCheck %s

// Test RC insertion for state variables with recursive algebraic types.
// State variables marked with cal.recursive_type should be transformed to use
// RC operations for proper memory management across action firings.

// -----------------------------------------------------------------------------
// Test 1: State variable with recursive type gets RC management
// -----------------------------------------------------------------------------

// CHECK-LABEL: cal.actor @actor_with_recursive_state
// CHECK:       cal.create_state_var{{.*}}{cal.rc_managed, cal.recursive_type}
// CHECK:       cal.get{{.*}}{cal.rc_borrowed}
// CHECK:       cal.set{{.*}}{cal.rc_release_old, cal.rc_updated}

cal.actor @actor_with_recursive_state()
    ports_in(%in0: !fifo.output_port<i32>)
{
    // State variable marked as containing recursive type
    %state = cal.create_state_var<i32> {cal.recursive_type} : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%state: !cal.state_ref<i32>, %c0: i32)
    
    cal.execution_body {
        // Get from RC-managed state (borrow)
        %old = cal.get(%state: !cal.state_ref<i32>) : i32
        
        // Pop new value
        %new = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        
        // Set to RC-managed state (release old, update)
        cal.set(%state: !cal.state_ref<i32>, %new: i32)
        
        %true = arith.constant 1 : i1
        cal.action_done %true : i1
    }
}

// -----------------------------------------------------------------------------
// Test 2: Non-recursive state variable (no RC management needed)
// -----------------------------------------------------------------------------

// CHECK-LABEL: cal.actor @actor_with_normal_state
// CHECK:       cal.create_state_var
// CHECK-NOT:   cal.rc_managed
// CHECK:       cal.execution_body

cal.actor @actor_with_normal_state()
    ports_in(%in0: !fifo.output_port<i32>)
{
    // Normal state variable (no recursive type attribute)
    %state = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%state: !cal.state_ref<i32>, %c0: i32)
    
    cal.execution_body {
        %old = cal.get(%state: !cal.state_ref<i32>) : i32
        %new = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        cal.set(%state: !cal.state_ref<i32>, %new: i32)
        
        %true = arith.constant 1 : i1
        cal.action_done %true : i1
    }
}

// -----------------------------------------------------------------------------
// Test 3: Multiple recursive state variables
// -----------------------------------------------------------------------------

// CHECK-LABEL: cal.actor @actor_with_multiple_recursive_states
// CHECK:       cal.create_state_var{{.*}}{cal.rc_managed, cal.recursive_type}
// CHECK:       cal.create_state_var{{.*}}{cal.rc_managed, cal.recursive_type}

cal.actor @actor_with_multiple_recursive_states()
    ports_in(%in0: !fifo.output_port<i32>)
{
    %state1 = cal.create_state_var<i32> {cal.recursive_type} : !cal.state_ref<i32>
    %state2 = cal.create_state_var<i32> {cal.recursive_type} : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%state1: !cal.state_ref<i32>, %c0: i32)
    cal.set(%state2: !cal.state_ref<i32>, %c0: i32)
    
    cal.execution_body {
        %v1 = cal.get(%state1: !cal.state_ref<i32>) : i32
        %v2 = cal.get(%state2: !cal.state_ref<i32>) : i32
        
        %new = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        cal.set(%state1: !cal.state_ref<i32>, %new: i32)
        
        %true = arith.constant 1 : i1
        cal.action_done %true : i1
    }
}

// -----------------------------------------------------------------------------
// Test 4: RC needs_alloc when setting from arena-allocated value
// -----------------------------------------------------------------------------

// CHECK-LABEL: cal.actor @actor_with_arena_to_state
// CHECK:       cal.set{{.*}}{cal.rc_needs_alloc, cal.rc_release_old, cal.rc_updated}

cal.actor @actor_with_arena_to_state()
    ports_in(%in0: !fifo.output_port<i32>)
{
    %state = cal.create_state_var<i32> {cal.recursive_type} : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%state: !cal.state_ref<i32>, %c0: i32)
    
    cal.execution_body {
        // Simulate a value that came from arena allocation
        %arena_val = arith.constant {cal.arena_allocated} 42 : i32
        
        // Set from arena-allocated value - needs rc.alloc
        cal.set(%state: !cal.state_ref<i32>, %arena_val: i32)
        
        %true = arith.constant 1 : i1
        cal.action_done %true : i1
    }
}
