// RUN: cal-opt %s -infer-cal-instance-array-shape | FileCheck %s

cal.actor @A() {
  cal.execution_body { %t = arith.constant 1 : i1 cal.action_done %t : i1 }
}

// Build dynamic literal array (1-D) from three instantiations; expect static length 3.
// CHECK-LABEL: func.func @lit()
cal.network @lit_wrapper() {
  %i0 = cal.instantiate @A : !cal.instance<@A>
  %i1 = cal.instantiate @A : !cal.instance<@A>
  %i2 = cal.instantiate @A : !cal.instance<@A>
  %arr = cal.instance_array.literal(%i0, %i1, %i2) : !cal.instance<@A>, !cal.instance<@A>, !cal.instance<@A> -> !cal.instance.array<@A, [?]>
}
// CHECK: func.func @lit() -> !cal.instance.array<@A, 3>
// CHECK: cal.instance_array.literal(%i0, %i1, %i2) : !cal.instance<@A>, !cal.instance<@A>, !cal.instance<@A> -> !cal.instance.array<@A, 3>
