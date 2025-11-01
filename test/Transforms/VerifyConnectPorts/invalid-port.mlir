// RUN: not cal-opt --composite-fixed-point-pass="pipeline=cal-structural-elaboration" %s 2>&1 | FileCheck %s

cal.actor @A()
    ports_in(%in: !fifo.output_port<i32>)
    ports_out(%out: !fifo.input_port<i32>) {
  cal.execution_body {
    %f = arith.constant false
    cal.action_done %f : i1
  }
}

cal.network @n() {
  // Make a valid instance handle
  %h = cal.instantiate @A : !cal.instance<@A>
  // Invalid connect: refer to non-existent destination port name "bad"
  // CHECK: error: invalid port 'bad' on actor '@A'
  cal.connect %h : !cal.instance<@A> "out" -> %h : !cal.instance<@A> "bad"
}
