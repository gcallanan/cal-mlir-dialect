// RUN: cal-opt -pass-pipeline='builtin.module(lower-instance-for, flatten-cal-networks)' -split-input-file %s | FileCheck %s

cal.actor @A()
    ports_in(%in: !fifo.output_port<i32>)
    ports_out(%out: !fifo.input_port<i32>)
{
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// Mixed usage: use instance_at and connect sugar on the same array element.
cal.network @MixedUses() {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index

  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  %base = cal.instantiate @A : !cal.instance<@A>

  %arr = cal.instance_for(%c0, %c1, %c1) {
    // single iteration yields base
    cal.instance_yield %base : !cal.instance<@A>
  } : !cal.instance.array<@A, 1>

  %h0 = cal.instance_at %arr[%c0] : !cal.instance.array<@A, 1>, index -> !cal.instance<@A>

  // One side uses direct handle via instance_at; the other uses sugar on the array
  cal.connect %out0 : !fifo.output_port<i32> "in" -> %h0 : !cal.instance<@A> "in"
  cal.connect %arr[%c0] : !cal.instance.array<@A, 1> "out" -> %in0 : !fifo.input_port<i32> "out"
}

// CHECK: cal.network @MixedUses()
// CHECK: cal.instantiate @A : <@A>
// CHECK: cal.connect
// CHECK: cal.connect
