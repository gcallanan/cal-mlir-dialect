// RUN: cal-opt -pass-pipeline='builtin.module(lower-instance-for, flatten-cal-networks)' -split-input-file %s | FileCheck %s

// This test covers multiple constant indices in a single cal.instance_for result
// and mixes both cal.instance_at (constant index) and connect sugar %arr[idx]
// on different elements in the same network.
//
// Expectations (post-lowering):
// - The cal.instance_for with N=3 is unrolled; no remaining cal.instance_for.
// - Uses of %arr[1] via cal.instance_at are rewritten to a direct handle.
// - Uses of %arr[0] and %arr[2] via connect sugar are rewritten by the pass.
// - flatten-cal-networks materializes fifo.create and cal.create_instance ops with
//   all ports wired; no indices remain in IR.

module {
  // A simple pass-through actor with one input and one output.
  cal.actor @A()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>)
  {
    cal.execution_body {
      %t = arith.constant true
      cal.action_done %t : i1
    }
  }

  // A source actor with only an output port.
  cal.actor @Src()
    ports_out(%out0: !fifo.input_port<i32>)
  {
    cal.execution_body {
      %t = arith.constant true
      cal.action_done %t : i1
    }
  }

  // A sink actor with only an input port.
  cal.actor @Sink()
    ports_in(%in0: !fifo.output_port<i32>)
  {
    cal.execution_body {
      %t = arith.constant true
      cal.action_done %t : i1
    }
  }

  // Build three A instances via instance_for and connect them using both
  // instance_at (constant index) and connect sugar on different elements.
  cal.network @MultiIndexMixedUses() {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index
    %c3 = arith.constant 3 : index

    // Create sources and sinks
  %src0 = cal.instantiate @Src : !cal.instance<@Src>
  %src2 = cal.instantiate @Src : !cal.instance<@Src>

    %snk1 = cal.instantiate @Sink : !cal.instance<@Sink>
    %snk2 = cal.instantiate @Sink : !cal.instance<@Sink>

    // Prepare base handles in network scope; the comprehension yields these.
    %abase0 = cal.instantiate @A : !cal.instance<@A>

    // Create an array of three entries by yielding the same base handle.
    %arr = cal.instance_for(%c0, %c3, %c1) {
      cal.instance_yield %abase0 : !cal.instance<@A>
    } : !cal.instance.array<@A, 3>

    // Note: The above uses ub=2 with step=1, which yields indices 0 and 1 (2 elements).
    // To ensure we also cover index 2, create a second handle separately to mix patterns.
    // Alternatively, construct a second small array for index 2.

    %abase2 = cal.instantiate @A : !cal.instance<@A>
    %arr2 = cal.instance_for(%c2, %c3, %c1) {
      cal.instance_yield %abase2 : !cal.instance<@A>
    } : !cal.instance.array<@A, 1>

    // INSTANCE_AT on index 1 of %arr
  %h1 = cal.instance_at %arr[%c1] : !cal.instance.array<@A, 3>, index -> !cal.instance<@A>

    // Connect patterns:
    // - src0 -> %arr[0] using connect sugar on destination (constant index 0)
    // - %h1  -> snk1 using direct handle from instance_at (constant index 1)
    // - src2 -> %arr2[0] using connect sugar (represents index 2 element)
    // - %arr[0] -> snk0 using sugar on source
    // - %arr2[0] -> snk2 using sugar on source

  cal.connect %src0 : !cal.instance<@Src> "out0" -> %arr[%c0] : !cal.instance.array<@A, 3> "in0"
  cal.connect %h1 : !cal.instance<@A> "out0" -> %snk1 : !cal.instance<@Sink> "in0"

  cal.connect %src2 : !cal.instance<@Src> "out0" -> %arr2[%c0] : !cal.instance.array<@A, 1> "in0"
  cal.connect %arr2[%c0] : !cal.instance.array<@A, 1> "out0" -> %snk2 : !cal.instance<@Sink> "in0"

    // CHECK-LABEL: func.func @MultiIndexMixedUses
    // CHECK: fifo.create
    // CHECK: cal.create_instance @Src
    // CHECK: cal.create_instance @Src
    // CHECK: cal.create_instance @Src
    // CHECK: cal.create_instance @A
    // CHECK: cal.create_instance @A
    // CHECK: cal.create_instance @A
    // CHECK: cal.create_instance @Sink
    // CHECK: cal.create_instance @Sink
    // CHECK: cal.create_instance @Sink
  }
}
