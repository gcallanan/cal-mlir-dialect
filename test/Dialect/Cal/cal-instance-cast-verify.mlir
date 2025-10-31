// RUN: cal-opt -split-input-file %s -verify-diagnostics

// Positive: cast succeeds when implements exists
cal.interface @IF1 {
  inPortTypes = [!fifo.output_port<i32>]
}

cal.actor @Act1()
  ports_in(%in0: !fifo.output_port<i32>)
{
}

cal.implements @IF1 for @Act1

cal.network @N1() {
  %h = cal.instantiate @Act1 : !cal.instance<@Act1>
  %c = cal.instance.cast %h : !cal.instance<@Act1> -> !cal.instance.iface<@IF1>
}

// -----

// Negative: cast fails without implements
cal.interface @IF2 {
  outPortTypes = [!fifo.input_port<i32>]
}

cal.actor @Act2()
  ports_out(%out0: !fifo.input_port<i32>)
{
}

cal.network @N2() {
  %h2 = cal.instantiate @Act2 : !cal.instance<@Act2>
  // expected-error @+1 {{does not implement interface}}
  %c2 = cal.instance.cast %h2 : !cal.instance<@Act2> -> !cal.instance.iface<@IF2>
}
