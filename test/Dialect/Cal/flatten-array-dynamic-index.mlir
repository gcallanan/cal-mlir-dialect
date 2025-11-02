// RUN: cal-opt --flatten-cal-networks %s -verify-diagnostics

cal.actor @A()
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @DynIdx() {
  %in0, %out0 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %arr = cal.instantiate_array @A count (2) : !cal.instance.array<@A, [2]>

  // Produce a non-constant (dynamic) index
  %idx = fifo.size(%out0 : !fifo.output_port<i32>) : index
  // expected-error @+1 {{'cal.instance_at' op dynamic index not supported in elaboration; pass --allow-dynamic-indices to skip materialization and defer to later passes}}
  %h = cal.instance_at %arr[%idx] : !cal.instance.array<@A, [2]> -> !cal.instance<@A>

  // This connect is irrelevant once the error triggers, but keeps structure plausible
  cal.connect %h : !cal.instance<@A> "out" -> %in0 : !fifo.input_port<i32> "in"
}
