// RUN: cal-opt --flatten-cal-networks -split-input-file %s -verify-diagnostics

// Simple actor with single in/out to make duplicate connections easy to express
cal.actor @A()
  in_names ["in"] out_names ["out"]
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// Duplicate destination port connection: two sources to the same actor input
cal.network @DupDest() {
  %in0, %out0 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %h = cal.instantiate @A : !cal.instance<@A>
  // expected-remark@+1 {{first connection to this port was here}}
  cal.connect %out0 : !fifo.output_port<i32> "out" -> %h : !cal.instance<@A> "in"
  // expected-error@+1 {{destination port already connected}}
  cal.connect %out1 : !fifo.output_port<i32> "out" -> %h : !cal.instance<@A> "in"
}

// -----

// Re-declare actor for the split section
cal.actor @A()
  in_names ["in"] out_names ["out"]
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// Duplicate source port connection: same actor output to two sinks
cal.network @DupSrc() {
  %in0, %out0 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %h = cal.instantiate @A : !cal.instance<@A>
  // expected-remark@+1 {{first connection to this port was here}}
  cal.connect %h : !cal.instance<@A> "out" -> %in0 : !fifo.input_port<i32> "in"
  // expected-error@+1 {{source port already connected}}
  cal.connect %h : !cal.instance<@A> "out" -> %in1 : !fifo.input_port<i32> "in"
}
