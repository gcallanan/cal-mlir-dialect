// RUN: cal-opt --flatten-cal-networks -split-input-file %s -verify-diagnostics

cal.actor @A()
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @DupSrc() {
  %in0, %out0 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>

  %h = cal.instantiate @A : !cal.instance<@A>
  // First connection OK
  // expected-remark @+1 {{first connection to this port was here}}
  cal.connect %out0 : !fifo.output_port<i32> "out" -> %h : !cal.instance<@A> "in"
  // Second connection to same source port should error
  // expected-error @+1 {{destination port already connected}}
  cal.connect %out1 : !fifo.output_port<i32> "out" -> %h : !cal.instance<@A> "in"
}

// -----

cal.actor @A()
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @DupDst() {
  %in0, %out0 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>

  %h = cal.instantiate @A : !cal.instance<@A>
  // First connection OK
  // expected-remark @+1 {{first connection to this port was here}}
  cal.connect %h : !cal.instance<@A> "out" -> %in0 : !fifo.input_port<i32> "in"
  // Second connection to same source port should error
  // expected-error @+1 {{source port already connected}}
  cal.connect %h : !cal.instance<@A> "out" -> %in0 : !fifo.input_port<i32> "in"
}