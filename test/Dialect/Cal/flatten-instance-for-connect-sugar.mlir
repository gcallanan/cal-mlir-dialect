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

// Use connect sugar directly on the array result of instance_for with constant indices.
cal.network @ConnectSugar() {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  %base0 = cal.instantiate @A : !cal.instance<@A>

  %arr = cal.instance_for(%c0, %c1, %c1) {
    // single iteration yields base0
    cal.instance_yield %base0 : !cal.instance<@A>
  } : !cal.instance.array<@A, 1>

  // expected: lower-instance-for rewrites these connects to use direct handles (no indices)
  cal.connect %out0 : !fifo.output_port<i32> "in" -> %arr[%c0] : !cal.instance.array<@A, 1> "in"
  cal.connect %arr[%c0] : !cal.instance.array<@A, 1> "out" -> %in0 : !fifo.input_port<i32> "out"
}

// CHECK: cal.network @ConnectSugar()
// CHECK: cal.instantiate @A : <@A>
// CHECK: cal.connect %outputPort : !fifo.output_port<i32> "in" -> %
// CHECK: cal.connect % : !cal.instance<@A> "out" -> %inputPort : !fifo.input_port<i32> "out"
