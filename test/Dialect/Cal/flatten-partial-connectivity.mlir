// RUN: cal-opt --flatten-cal-networks -split-input-file %s -verify-diagnostics

cal.actor @A()
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// Connect only source -> network sink (missing network source -> actor input)
cal.network @PartialMissingInput() {
  %in0, %out0 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
  // expected-error @+1 {{not all ports connected for instance; connect all ports before elaboration}}
  %h = cal.instantiate @A : !cal.instance<@A>
  // Wire only the actor's output port
  cal.connect %h : !cal.instance<@A> "out" -> %in0 : !fifo.input_port<i32> "in"
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

// Connect only network source -> actor input (missing actor output -> network sink)
cal.network @PartialMissingOutput() {
  %in0, %out0 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
  // expected-error @+1 {{not all ports connected for instance; connect all ports before elaboration}}
  %h = cal.instantiate @A : !cal.instance<@A>
  // Wire only the actor's input port
  cal.connect %out0 : !fifo.output_port<i32> "out" -> %h : !cal.instance<@A> "in"
}
