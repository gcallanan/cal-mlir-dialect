// RUN: cal-opt %s -network-elements-elab --split-input-file | FileCheck %s

// Define a simple actor with ports so we can connect instances
cal.actor @A()
  ports_in(%in: !fifo.output_port<i32>)
  ports_out(%out: !fifo.input_port<i32>)
{
}

// Build a 1D dynamic instance array for @A using a trivial loop and unroll it
// while preserving per-iteration structure (no flattening to instantiate_array).
cal.network @BuildLoop() {
  %N = arith.constant 4 : index
  %init = cal.instance.array.init(%N : index) : !cal.instance.array<@A, [?]>
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %arr = scf.for %i = %c0 to %N step %c1 iter_args(%a = %init) -> !cal.instance.array<@A, [?]> {
    %h = cal.instantiate @A : !cal.instance<@A>
    %a2 = cal.instance.array.set %a[%i], %h : !cal.instance.array<@A, [?]>, !cal.instance<@A> -> !cal.instance.array<@A, [?]>
    scf.yield %a2 : !cal.instance.array<@A, [?]>
  }
  // Extract handles and connect them in a chain: 0->1, 1->2, 2->3
  %h0 = cal.instance_at %arr[%c0] : !cal.instance.array<@A, [?]> -> !cal.instance<@A>
  %h1 = cal.instance_at %arr[%c1] : !cal.instance.array<@A, [?]> -> !cal.instance<@A>
  %c2 = arith.constant 2 : index
  %h2 = cal.instance_at %arr[%c2] : !cal.instance.array<@A, [?]> -> !cal.instance<@A>
  %c3 = arith.constant 3 : index
  %h3 = cal.instance_at %arr[%c3] : !cal.instance.array<@A, [?]> -> !cal.instance<@A>
  cal.connect %h0 : !cal.instance<@A> "out" -> %h1 : !cal.instance<@A> "in"
  cal.connect %h1 : !cal.instance<@A> "out" -> %h2 : !cal.instance<@A> "in"
  cal.connect %h2 : !cal.instance<@A> "out" -> %h3 : !cal.instance<@A> "in"
}

// CHECK: cal.network @BuildLoop()
// CHECK-COUNT-4: cal.instantiate @A
// CHECK-COUNT-4: cal.instance_at
// CHECK-COUNT-3: cal.connect
// CHECK-NOT: scf.for
