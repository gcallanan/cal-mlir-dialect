// RUN: cal-opt --flatten-cal-networks %s | FileCheck %s

cal.actor @A()
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @TopCap() {
  %in0, %out0 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>

  %h = cal.instantiate @A : !cal.instance<@A>
  cal.connect %out0 : !fifo.output_port<i32> "out" -> %h : !cal.instance<@A> "in" capacity(7)
  cal.connect %h : !cal.instance<@A> "out" -> %in1 : !fifo.input_port<i32> "in"
}

// CHECK: cal.network @TopCap()
// CHECK: fifo.create<i32>(7)
// CHECK: cal.create_instance @A