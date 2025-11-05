// RUN: not cal-opt --flatten-cal-networks=insert-fanout-on-multisink=false %s -verify-diagnostics

cal.actor @Src()
  out_names ["out"]
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.actor @Sink()
  in_names ["in"]
  ports_in(%i: !fifo.output_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @TopFanErr() {
  %src = cal.instantiate @Src : !cal.instance<@Src>
  %s0  = cal.instantiate @Sink : !cal.instance<@Sink>
  %s1  = cal.instantiate @Sink : !cal.instance<@Sink>
  // expected-remark@+1 {{first connection to this port was here}}
  cal.connect %src : !cal.instance<@Src> "out" -> %s0 : !cal.instance<@Sink> "in"
  // expected-error@+1 {{source port already connected}}
  cal.connect %src : !cal.instance<@Src> "out" -> %s1 : !cal.instance<@Sink> "in"
}
