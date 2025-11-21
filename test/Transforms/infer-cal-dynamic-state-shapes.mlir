// RUN: cal-opt %s --pass-pipeline="builtin.module(infer-cal-dynamic-state-memref-shapes)" | FileCheck %s

// This test verifies that the infer-cal-dynamic-state-memref-shapes pass
// rewrites dynamic shaped state variables with constant size operands into
// fully static types, and leaves non-constant ones untouched.

cal.actor @test(%sz: index) {
  // Constant size -> should specialize to memref<16xi32>
  %c16 = arith.constant 16 : index
  %state = cal.create_state_var<memref<?xi32>>(%c16 : index) : !cal.state_ref<memref<?xi32>>

  // Constant expression (10 + 6) -> should also specialize to 16
  %c10 = arith.constant 10 : index
  %c6 = arith.constant 6 : index
  %sum = arith.addi %c10, %c6 : index
  %state2 = cal.create_state_var<memref<?xi32>>(%sum : index) : !cal.state_ref<memref<?xi32>>

  // Non-constant (actor param) -> should remain dynamic
  %state3 = cal.create_state_var<memref<?xi32>>(%sz : index) : !cal.state_ref<memref<?xi32>>

  // Tensor dynamic -> constant size operand -> specialize to tensor<16xi32>
  %stateT = cal.create_state_var<tensor<?xi32>>(%c16 : index) : !cal.state_ref<tensor<?xi32>>

  cal.execution_body {
    %false = arith.constant 0 : i1
    cal.action_done %false : i1
  }
}

// CHECK: cal.actor @test(%{{.*}}: index) {
// CHECK: %c16 = arith.constant 16 : index
// CHECK: %state = cal.create_state_var<memref<16xi32>> : !cal.state_ref<memref<16xi32>>
// CHECK: %c10 = arith.constant 10 : index
// CHECK: %c6 = arith.constant 6 : index
// CHECK: %sum = arith.addi %c10, %c6 : index
// CHECK: %state2 = cal.create_state_var<memref<16xi32>> : !cal.state_ref<memref<16xi32>>
// CHECK: %state3 = cal.create_state_var<memref<?xi32>>(%{{.*}} : index) : !cal.state_ref<memref<?xi32>>
// CHECK: %stateT = cal.create_state_var<tensor<16xi32>> : !cal.state_ref<tensor<16xi32>>
// CHECK-NOT: cal.create_state_var<memref<?xi32>>(%c16
// CHECK-NOT: cal.create_state_var<memref<?xi32>>(%sum
