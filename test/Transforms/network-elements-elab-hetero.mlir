// RUN: cal-opt %s -network-elements-elab --split-input-file | FileCheck %s

// Two minimal actors to exercise heterogeneity; A has ports for connections
cal.actor @A()
  ports_in(%in: !fifo.output_port<i32>)
  ports_out(%out: !fifo.input_port<i32>)
{}
cal.actor @B() {}

// Build 1-D dynamic instance array choosing A or B based on parity of IV.
// The pass should unroll, preserve inner scf.if and cal.instance.array.set, and remove scf.for.
cal.network @Hetero() {
  %N = arith.constant 4 : index
  %init = cal.instance.array.init(%N : index) : !cal.instance.array<@A, [?]>
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c2 = arith.constant 2 : index
  %arr = scf.for %i = %c0 to %N step %c1 iter_args(%a = %init) -> !cal.instance.array<@A, [?]> {
    // is_even = ((i & 1) == 0)
    %i_mask = arith.andi %i, %c1 : index
    %is_zero = arith.cmpi eq, %i_mask, %c0 : index
    %h_sel = scf.if %is_zero -> (!cal.instance<@A>) {
      %hA = cal.instantiate @A : !cal.instance<@A>
      scf.yield %hA : !cal.instance<@A>
    } else {
      %hAlt = cal.instantiate @A instance("alt") : !cal.instance<@A>
      scf.yield %hAlt : !cal.instance<@A>
    }
    %a_next = cal.instance.array.set %a[%i], %h_sel : !cal.instance.array<@A, [?]>, !cal.instance<@A> -> !cal.instance.array<@A, [?]>
    scf.yield %a_next : !cal.instance.array<@A, [?]>
  }
  // Connect the selected instances in a simple chain using instance_at
  %h0 = cal.instance_at %arr[%c0] : !cal.instance.array<@A, [?]> -> !cal.instance<@A>
  %h1 = cal.instance_at %arr[%c1] : !cal.instance.array<@A, [?]> -> !cal.instance<@A>
  %h2 = cal.instance_at %arr[%c2] : !cal.instance.array<@A, [?]> -> !cal.instance<@A>
  %c3 = arith.constant 3 : index
  %h3 = cal.instance_at %arr[%c3] : !cal.instance.array<@A, [?]> -> !cal.instance<@A>
  cal.connect %h0 : !cal.instance<@A> "out" -> %h1 : !cal.instance<@A> "in"
  cal.connect %h1 : !cal.instance<@A> "out" -> %h2 : !cal.instance<@A> "in"
  cal.connect %h2 : !cal.instance<@A> "out" -> %h3 : !cal.instance<@A> "in"
}

// CHECK: cal.network @Hetero()
// CHECK-NOT: scf.for
// CHECK-COUNT-4: cal.instantiate @A
// CHECK-COUNT-4: cal.instance_at
// CHECK-COUNT-3: cal.connect
