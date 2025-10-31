// RUN: cal-opt -split-input-file %s -verify-diagnostics

cal.interface @ProducerSpec {
  outPortTypes = [!fifo.input_port<i32>]
}

cal.interface @ConsumerSpec {
  inPortTypes = [!fifo.output_port<i32>]
}

cal.actor @Prod()
  ports_out(%out0: !fifo.input_port<i32>)
{
}

cal.actor @Cons()
  ports_in(%in0: !fifo.output_port<i32>)
{
}

cal.implements @ProducerSpec for @Prod
cal.implements @ConsumerSpec for @Cons

cal.network @N() {
  %p = cal.instantiate @Prod : !cal.instance<@Prod>
  %c = cal.instantiate @Cons : !cal.instance<@Cons>
  %ip = cal.instance.cast %p : !cal.instance<@Prod> -> !cal.instance.iface<@ProducerSpec>
  %ic = cal.instance.cast %c : !cal.instance<@Cons> -> !cal.instance.iface<@ConsumerSpec>
  // Using interface-typed handles in connect should parse/verify.
  cal.connect %ip : !cal.instance.iface<@ProducerSpec> "out0" -> %ic : !cal.instance.iface<@ConsumerSpec> "in0"
}
