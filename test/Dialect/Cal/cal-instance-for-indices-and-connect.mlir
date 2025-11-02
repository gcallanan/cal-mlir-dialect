// REQUIRES: legacy-ops
// RUN: cal-opt %s | FileCheck %s

// Define a simple actor with one input and one output port so we can connect instances.
cal.actor @A()
    ports_in(%in: !fifo.output_port<i32>)
    ports_out(%out: !fifo.input_port<i32>)
{
}

// Build an instance array using cal.instance_for, then pick multiple elements
// via cal.instance_at and connect them.
cal.network @m() {
  %lb = arith.constant 0 : index
  %ub = arith.constant 3 : index
  %st = arith.constant 1 : index

  // Create a base handle in network scope; the comprehension yields it per iteration.
  %base = cal.instantiate @A : !cal.instance<@A>

  // Build an array of length 3 by yielding the same base handle for simplicity.
  %arr = cal.instance_for(%lb, %ub, %st) {
    cal.instance_yield %base : !cal.instance<@A>
  } : !cal.instance.array<@A, 3>

  // Extract handles at two constant indices.
  %i0 = arith.constant 0 : index
  %i2 = arith.constant 2 : index
  %h0 = cal.instance_at %arr[%i0] : !cal.instance.array<@A, 3>, index -> !cal.instance<@A>
  %h2 = cal.instance_at %arr[%i2] : !cal.instance.array<@A, 3>, index -> !cal.instance<@A>

  // Connect output of instance 0 to input of instance 2.
  cal.connect %h0 : !cal.instance<@A> "out" -> %h2 : !cal.instance<@A> "in" capacity(4)

  // CHECK-LABEL: cal.network @m()
  // CHECK: cal.instance_for
  // CHECK: cal.instance_at
  // CHECK: cal.instance_at
  // CHECK: cal.connect
}
