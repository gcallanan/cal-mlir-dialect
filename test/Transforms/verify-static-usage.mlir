// RUN: not cal-opt %s -cal-network-elab 2>&1 | FileCheck %s --check-prefix=FAIL
// RUN: cal-opt %s -infer-cal-instance-array-shape -verify-instance-array-static-usage | FileCheck %s --check-prefix=PASS

cal.actor @A() { cal.execution_body { %t = arith.constant 1 : i1 cal.action_done %t : i1 } }

// Network with deliberate out-of-bounds constant index to trigger error in pipeline form.
cal.network @bad_indices() {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c4 = arith.constant 4 : index
  %init = cal.instance.array.init(%c4 : index) : !cal.instance.array<@A, [?]>
  %arr = scf.for %i = %c0 to %c4 step %c1 iter_args(%a = %init) -> !cal.instance.array<@A, [?]> {
    %h = cal.instantiate @A : !cal.instance<@A>
    %a2 = cal.instance.array.set %a[%i], %h : !cal.instance.array<@A, [?]>, !cal.instance<@A> -> !cal.instance.array<@A, [?]>
    scf.yield %a2 : !cal.instance.array<@A, [?]>
  }
  // Out of bounds: using constant 5 for length 4 array after inference
  %c5 = arith.constant 5 : index
  %at = cal.instance_at %arr[%c5] : !cal.instance.array<@A, [?]> -> !cal.instance<@A>
}

// FAIL: index 5 out of bounds

// Separate good case (in-bounds) should pass explicit verification invocation.
cal.network @good_indices() {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c4 = arith.constant 4 : index
  %init = cal.instance.array.init(%c4 : index) : !cal.instance.array<@A, [?]>
  %arr = scf.for %i = %c0 to %c4 step %c1 iter_args(%a = %init) -> !cal.instance.array<@A, [?]> {
    %h = cal.instantiate @A : !cal.instance<@A>
    %a2 = cal.instance.array.set %a[%i], %h : !cal.instance.array<@A, [?]>, !cal.instance<@A> -> !cal.instance.array<@A, [?]>
    scf.yield %a2 : !cal.instance.array<@A, [?]>
  }
  %c2 = arith.constant 2 : index
  %at = cal.instance_at %arr[%c2] : !cal.instance.array<@A, [?]> -> !cal.instance<@A>
}
// PASS-NOT: out of bounds
