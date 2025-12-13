// RUN: cal-opt %s --cal-materialize-rc-ops | FileCheck %s

// Test that the materialize-rc-ops pass transforms marked state operations
// into actual RC operations, including changing the state type to !cal.rc<T>.

// Define a recursive List variant type for testing
!list_type = !cal.variant<"List", [("Nil", []), ("Cons", [i32, !llvm.ptr])]>

// CHECK-LABEL: cal.actor @test_rc_materialize
cal.actor @test_rc_materialize()
    ports_in(%in0: !fifo.output_port<!list_type>)
    ports_out(%out0: !fifo.input_port<!list_type>)
{
    // State variable marked as RC-managed - type should change to !cal.rc<T>
    // CHECK: cal.create_state_var<!cal.rc<!cal.variant<"List"
    %state = cal.create_state_var<!list_type> {cal.rc_managed, cal.recursive_type} : !cal.state_ref<!list_type>

    cal.execution_body {
        // Get operation should use rc.load to extract value
        // CHECK: cal.get
        // CHECK: cal.rc.load
        %old_val = cal.get(%state: !cal.state_ref<!list_type>) {cal.rc_borrowed} : !list_type
        
        // A new value comes from FIFO pop
        %new_val = fifo.pop(%in0: !fifo.output_port<!list_type>) : !list_type
        
        // Set operation should include rc.release and rc.alloc
        // CHECK: cal.get
        // CHECK: cal.rc.release
        // CHECK: cal.rc.alloc
        // CHECK: cal.set
        cal.set(%state: !cal.state_ref<!list_type>, %new_val: !list_type) {cal.rc_release_old, cal.rc_needs_alloc, cal.rc_updated}
        
        // Another get to push out
        // CHECK: cal.get
        // CHECK: cal.rc.load
        %current = cal.get(%state: !cal.state_ref<!list_type>) {cal.rc_borrowed} : !list_type
        fifo.push(%out0: !fifo.input_port<!list_type>, %current: !list_type)
        
        %true = arith.constant 1 : i1
        cal.action_done %true : i1
    }
}

// Test case where only rc_release_old is set (no explicit alloc flag, but we alloc anyway)
// CHECK-LABEL: cal.actor @test_rc_release_only
cal.actor @test_rc_release_only()
    ports_in(%in0: !fifo.output_port<!list_type>)
{
    // CHECK: cal.create_state_var<!cal.rc<!cal.variant
    %state = cal.create_state_var<!list_type> {cal.rc_managed, cal.recursive_type} : !cal.state_ref<!list_type>

    cal.execution_body {
        %new_val = fifo.pop(%in0: !fifo.output_port<!list_type>) : !list_type
        
        // CHECK: cal.rc.release
        // CHECK: cal.rc.alloc
        // CHECK: cal.set
        cal.set(%state: !cal.state_ref<!list_type>, %new_val: !list_type) {cal.rc_release_old, cal.rc_updated}
        
        %true = arith.constant 1 : i1
        cal.action_done %true : i1
    }
}

// Test that unmarked operations are not transformed
// CHECK-LABEL: cal.actor @test_no_transform
cal.actor @test_no_transform()
{
    // Non-recursive state variable (no RC management)
    // CHECK: cal.create_state_var<i32>
    // CHECK-NOT: cal.rc
    %state = cal.create_state_var<i32> : !cal.state_ref<i32>

    cal.execution_body {
        %c1 = arith.constant 1 : i32
        // Plain set without RC attributes - should not be transformed
        // CHECK-NOT: cal.rc.release
        // CHECK-NOT: cal.rc.alloc
        // CHECK: cal.set
        cal.set(%state: !cal.state_ref<i32>, %c1: i32)
        
        %true = arith.constant 1 : i1
        cal.action_done %true : i1
    }
}
