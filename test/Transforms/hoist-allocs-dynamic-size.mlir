// REQUIRES: cal-dialect
// RUN: cal-opt %s --pass-pipeline="builtin.module(hoist-cal-state-out-of-actor,convert-cal-to-func,lower-cal-state-to-memref,hoist-allocs)" | FileCheck %s

// Purpose: Regression test for hoisting dynamic memref state allocation whose
// size depends on an actor parameter. The hoist pass must reconstruct the
// size-producing ops (here an index_cast of the parameter) in @main so the
// cloned memref.alloc does not depend on values defined inside the callee.
// It then updates the callee function signature to accept the hoisted memref
// as an extra argument and erases the original alloc inside the function.

// Actor with dynamic-sized state memref. The state var uses a size operand
// derived from the actor parameter (%n : i32) via index_cast.
cal.actor @A(%sz: index) {
  %state = cal.create_state_var<memref<?xi32>>(%sz : index) : !cal.state_ref<memref<?xi32>>
  cal.execution_body {
    %m = cal.get(%state : !cal.state_ref<memref<?xi32>>) : memref<?xi32>
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// Network creates a constant size (16) and instantiates the actor.
cal.network @top() {
  %c16 = arith.constant 16 : index
  cal.create_instance @A "a0" (%c16 : index)
}

// CHECK-LABEL: func.func @A(
// CHECK-SAME: index
// CHECK-SAME: memref<?xi32>
// CHECK-NOT: memref.alloc

// CHECK-LABEL: func.func @main(
// CHECK: memref.alloc
// CHECK: func.call @A