// RUN: cal-opt --flatten-cal-networks %s -verify-diagnostics

// Define a simple pipe interface
cal.interface @PipeLike { inPortNames = ["in"], inPortTypes = [!fifo.output_port<i32>], outPortNames = ["out"], outPortTypes = [!fifo.input_port<i32>] }

// Producer and Consumer actors implementing the interface
cal.actor @Prod()
  in_names ["in"] out_names ["out"]
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.actor @Cons()
  in_names ["in"] out_names ["out"]
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.implements @PipeLike for @Prod
cal.implements @PipeLike for @Cons

// Two connects on the same logical channel via interface names with differing capacities
cal.network @IfaceCap() {
  %hp = cal.instantiate @Prod : !cal.instance<@Prod>
  %hc = cal.instantiate @Cons : !cal.instance<@Cons>
  %ip = cal.instance.cast %hp : !cal.instance<@Prod> -> !cal.instance.iface<@PipeLike>
  %ic = cal.instance.cast %hc : !cal.instance<@Cons> -> !cal.instance.iface<@PipeLike>

  // expected-remark @+1 {{first capacity specified here}}
  cal.connect %ip : !cal.instance.iface<@PipeLike> "out" -> %ic : !cal.instance.iface<@PipeLike> "in" capacity(4)
  // expected-error@+1 {{conflicting capacity for channel: existing=4, new=8}}
  cal.connect %ip : !cal.instance.iface<@PipeLike> "out" -> %ic : !cal.instance.iface<@PipeLike> "in" capacity(8)
}
