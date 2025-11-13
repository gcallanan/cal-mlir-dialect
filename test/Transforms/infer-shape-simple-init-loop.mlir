// RUN: cal-opt %s -infer-cal-instance-array-shape | FileCheck %s

cal.actor @A() {
  cal.execution_body {
    %t = arith.constant 1 : i1
    cal.action_done %t : i1
  }
}

// Build 1-D dynamic array via loop of trip count 4.
// Expect upgrade to !cal.instance.array<@A, 4>
// CHECK-LABEL: func.func @build_simple()
cal.network @build_simple() {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c4 = arith.constant 4 : index
  %dyn = cal.instance.array.init : !cal.instance.array<@A, [?]>
  %loop = scf.for %i = %c0 to %c4 step %c1 iter_args(%arg0 = %dyn) -> (!cal.instance.array<@A, [?]>) {
    %inst = cal.instantiate @A : !cal.instance<@A>
    %arr = cal.instance.array.set %arg0[%i], %inst : !cal.instance.array<@A, [?]>, !cal.instance<@A> -> !cal.instance.array<@A, [?]>
    scf.yield %arr : !cal.instance.array<@A, [?]>
  }
}

// CHECK: cal.network @build_simple()
// CHECK: !cal.instance.array<@A, 4>
