// RUN: cal-opt -pass-pipeline='builtin.module(flatten-cal-networks{allow-dynamic-indices})' %s -verify-diagnostics

cal.actor @A()
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @DynConnSkip() {
  %in0, %out0 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %arr = cal.instantiate_array @A count(2) : !cal.instance.array<@A, [2]>

  %idx = fifo.size(%out0 : !fifo.output_port<i32>) : index
  // expected-remark @+1 {{skipping connect with dynamic ND array index during elaboration}}
  cal.connect %arr[%idx] : !cal.instance.array<@A, [2]> "out" -> %in0 : !fifo.input_port<i32> "in"
}
