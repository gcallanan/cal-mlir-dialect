// RUN: cal-opt -pass-pipeline='builtin.module(flatten-cal-networks{allow-partial-connectivity})' %s -verify-diagnostics

// Define a simple actor with 1 in and 1 out port
cal.actor @A()
  in_names ["in"] out_names ["out"]
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// Allow mode: skip materialization and emit a remark instead of error
cal.network @Allow() {
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  // expected-remark@+1 {{skipping materialization of partially-connected instance}}
  %h = cal.instantiate @A : !cal.instance<@A>
  cal.connect %h : !cal.instance<@A> "out" -> %in0 : !fifo.input_port<i32> "out"
}
