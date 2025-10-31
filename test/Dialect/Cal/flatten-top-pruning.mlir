// RUN: cal-opt -pass-pipeline='builtin.module(flatten-cal-networks{top=Top})' %s | FileCheck %s

cal.actor @A()
  in_names ["in"] out_names ["out"]
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// Inner network: wires its boundary ports to an @A instance
cal.network @Inner()
  ports_in(%pi: !fifo.output_port<i32>)
  ports_out(%po: !fifo.input_port<i32>) {
  %h = cal.instantiate @A : !cal.instance<@A>
  cal.connect %pi : !fifo.output_port<i32> "in" -> %h : !cal.instance<@A> "in"
  cal.connect %h : !cal.instance<@A> "out" -> %po : !fifo.input_port<i32> "out"
}

// Another network that should be pruned when top=Top
cal.network @Other() {
  %c0 = arith.constant 0 : i32
}

// Top network instantiates Inner and wires it to a local fifo
cal.network @Top() {
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  cal.create_instance @Inner "inner0" ()
      ports_in(%out0 : !fifo.output_port<i32>)
      ports_out(%in0 : !fifo.input_port<i32>)
}

// CHECK: cal.network @Top()
// CHECK-NOT: cal.network @Inner()
// CHECK-NOT: cal.network @Other()
// CHECK: cal.create_instance @A
