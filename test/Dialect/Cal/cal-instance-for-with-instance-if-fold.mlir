// RUN: cal-opt --resolve-instance-if %s | FileCheck %s

// Minimal actor with ports to mirror typical shape; body is irrelevant here.
cal.actor @A()
    ports_in(%in: !fifo.output_port<i32>)
    ports_out(%out: !fifo.input_port<i32>)
{
}

// Use cal.instance_if at network scope to choose a handle, then consume it
// inside cal.instance_for. With --resolve-instance-if, the conditional should
// fold away and only the loop and chosen handle remain.
cal.network @use_if_in_for() {
  %c0 = arith.constant 0 : index
  %c3 = arith.constant 3 : index
  %c1 = arith.constant 1 : index

  %hA = cal.instantiate @A : !cal.instance<@A>
  %hB = cal.instantiate @A : !cal.instance<@A>

  %true = arith.constant true
  %chosen = cal.instance_if %true {
    cal.instance_yield %hA : !cal.instance<@A>
  } else {
    cal.instance_yield %hB : !cal.instance<@A>
  } : !cal.instance<@A>

  // Build an array by yielding the chosen handle at each iteration.
  %arr = cal.instance_for(%c0, %c3, %c1) {
    cal.instance_yield %chosen : !cal.instance<@A>
  } : !cal.instance.array<@A, 3>

  // Use the result to ensure it survives canonicalization.
  %h0 = cal.instance_at %arr[%c0] : !cal.instance.array<@A, 3>, index -> !cal.instance<@A>
  %h1 = cal.instance_at %arr[%c1] : !cal.instance.array<@A, 3>, index -> !cal.instance<@A>

  // CHECK-LABEL: cal.network @use_if_in_for()
  // CHECK: cal.instance_for
  // CHECK: cal.instance_at
  // CHECK: cal.instance_at
  // CHECK-NOT: cal.instance_if
}
