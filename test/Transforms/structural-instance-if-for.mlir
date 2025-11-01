// RUN: cal-opt --composite-fixed-point-pass="pipeline=cal-structural-elaboration" %s | FileCheck %s

// Minimal actor; body irrelevant for structural elaboration tests
cal.actor @A() {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @use_if_and_for() {
  %c0 = arith.constant 0 : index
  %c2 = arith.constant 2 : index
  %c1 = arith.constant 1 : index

  %hA = cal.instantiate @A : !cal.instance<@A>
  %hB = cal.instantiate @A : !cal.instance<@A>

  %tru = arith.constant true
  %picked = cal.instance_if %tru {
    cal.instance_yield %hA : !cal.instance<@A>
  } else {
    cal.instance_yield %hB : !cal.instance<@A>
  } : !cal.instance<@A>

  %arr = cal.instance_for(%c0, %c2, %c1) {
    cal.instance_yield %picked : !cal.instance<@A>
  } : !cal.instance.array<@A, 2>

  // Make sure the array is used so it doesn't DCE away.
  %h0 = cal.instance_at %arr[%c0] : !cal.instance.array<@A, 2>, index -> !cal.instance<@A>
  %h1 = cal.instance_at %arr[%c1] : !cal.instance.array<@A, 2>, index -> !cal.instance<@A>
}

// CHECK-LABEL: cal.network @use_if_and_for()
// CHECK: cal.instantiate @A
// CHECK-NOT: cal.instance_if
// CHECK-NOT: cal.instance_for
