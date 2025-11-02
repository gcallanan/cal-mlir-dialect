// REQUIRES: legacy-ops
// RUN: cal-opt -pass-pipeline='builtin.module(lower-instance-for, flatten-cal-networks)' -split-input-file %s | FileCheck %s

// Define a simple actor with one in and one out
cal.actor @A()
    ports_in(%in: !fifo.output_port<i32>)
    ports_out(%out: !fifo.input_port<i32>)
{
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// Network that uses instance_for to build two instances, then connects via instance_at
cal.network @UseInstanceFor() {
  %c0 = arith.constant 0 : index
  %c2 = arith.constant 2 : index
  %c1 = arith.constant 1 : index

  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  // Create a single instance handle in network scope; the comprehension will yield it.
  %base = cal.instantiate @A : !cal.instance<@A>

  %arr = cal.instance_for(%c0, %c2, %c1) {
    cal.instance_yield %base : !cal.instance<@A>
  } : !cal.instance.array<@A, 2>

  %h0 = cal.instance_at %arr[%c0] : !cal.instance.array<@A, 2>, index -> !cal.instance<@A>
  %h1 = cal.instance_at %arr[%c1] : !cal.instance.array<@A, 2>, index -> !cal.instance<@A>

  cal.connect %out0 : !fifo.output_port<i32> "in" -> %h0 : !cal.instance<@A> "in"
  cal.connect %h1 : !cal.instance<@A> "out" -> %in1 : !fifo.input_port<i32> "out"
}

// CHECK: cal.network @UseInstanceFor()
// CHECK: cal.instantiate @A : <@A>
// CHECK: cal.instantiate @A : <@A>
// CHECK: cal.connect
// CHECK: cal.connect
