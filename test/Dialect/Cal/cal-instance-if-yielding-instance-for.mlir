// RUN: cal-opt --resolve-instance-if %s | FileCheck %s

cal.actor @A()
    ports_in(%in: !fifo.output_port<i32>)
    ports_out(%out: !fifo.input_port<i32>)
{
}

// An instance_if that yields the result of an instance_for.
// Note: cal.instance_for must be at network scope (not inside the if body),
// so each branch yields a precomputed array value.
cal.network @n() {
  %c0 = arith.constant 0 : index
  %c3 = arith.constant 3 : index
  %c1 = arith.constant 1 : index

  // Two base handles to produce distinct arrays.
  %base0 = cal.instantiate @A : !cal.instance<@A>
  %base1 = cal.instantiate @A : !cal.instance<@A>

  // Build two arrays of the same type using instance_for.
  %arr0 = cal.instance_for(%c0, %c3, %c1) {
    cal.instance_yield %base0 : !cal.instance<@A>
  } : !cal.instance.array<@A, 3>

  %arr1 = cal.instance_for(%c0, %c3, %c1) {
    cal.instance_yield %base1 : !cal.instance<@A>
  } : !cal.instance.array<@A, 3>

  // Choose between the two arrays via instance_if. With a constant condition,
  // resolve pass should fold this away and inline the chosen value.
  %true = arith.constant true
  %chosen = cal.instance_if %true {
    cal.instance_yield %arr0 : !cal.instance.array<@A, 3>
  } else {
    cal.instance_yield %arr1 : !cal.instance.array<@A, 3>
  } : !cal.instance.array<@A, 3>

  // Consume the chosen array to keep it live.
  %h0 = cal.instance_at %chosen[%c0] : !cal.instance.array<@A, 3>, index -> !cal.instance<@A>
  %h1 = cal.instance_at %chosen[%c1] : !cal.instance.array<@A, 3>, index -> !cal.instance<@A>

  // CHECK-LABEL: cal.network @n()
  // CHECK: cal.instance_for
  // CHECK: cal.instance_for
  // CHECK: cal.instance_at
  // CHECK: cal.instance_at
  // CHECK-NOT: cal.instance_if
}
