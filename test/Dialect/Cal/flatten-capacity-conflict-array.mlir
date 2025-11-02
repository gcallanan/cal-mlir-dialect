// RUN: cal-opt --flatten-cal-networks %s -verify-diagnostics

cal.actor @A()
  in_names ["in"] out_names ["out"]
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.actor @B()
  in_names ["in"] out_names ["out"]
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// Two connects on the same array-indexed channel with differing capacities
cal.network @ArrayCap() {
  %c0 = arith.constant 0 : index
  %as = cal.instantiate_array @A count(2) : !cal.instance.array<@A, [2]>
  %bs = cal.instantiate_array @B count(2) : !cal.instance.array<@B, [2]>

  // expected-remark @+1 {{first capacity specified here}}
  cal.connect %as[%c0] : !cal.instance.array<@A, [2]> "out" -> %bs[%c0] : !cal.instance.array<@B, [2]> "in" capacity(4)
  // expected-error@+1 {{conflicting capacity for channel: existing=4, new=8}}
  cal.connect %as[%c0] : !cal.instance.array<@A, [2]> "out" -> %bs[%c0] : !cal.instance.array<@B, [2]> "in" capacity(8)
}
