// Example: Using cal.instance_for with lower-instance-for + flatten-cal-networks
// Try:
//   cal-opt -pass-pipeline='builtin.module(lower-instance-for, flatten-cal-networks)' examples/instance_for/instance_for.mlir

cal.actor @A()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>)
{
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.actor @Src()
    ports_out(%out0: !fifo.input_port<i32>)
{
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.actor @Sink()
    ports_in(%in0: !fifo.output_port<i32>)
{
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @Example() {
  %c0 = arith.constant 0 : index
  %c3 = arith.constant 3 : index
  %c1 = arith.constant 1 : index

  // Build a size-1 array for index 0 path.
  %hA0 = cal.instantiate @A : !cal.instance<@A>
  %arr0 = cal.instance_for(%c0, %c1, %c1) {
    cal.instance_yield %hA0 : !cal.instance<@A>
  } : !cal.instance.array<@A, 1>

  // Build a separate size-1 array and extract its element via instance_at.
  %hA1 = cal.instantiate @A : !cal.instance<@A>
  %arr1 = cal.instance_for(%c0, %c1, %c1) {
    cal.instance_yield %hA1 : !cal.instance<@A>
  } : !cal.instance.array<@A, 1>
  %h1 = cal.instance_at %arr1[%c0] : !cal.instance.array<@A, 1>, index -> !cal.instance<@A>

  // Two sources and two sinks.
  %s0 = cal.instantiate @Src : !cal.instance<@Src>
  %s1 = cal.instantiate @Src : !cal.instance<@Src>
  %k0 = cal.instantiate @Sink : !cal.instance<@Sink>
  %k1 = cal.instantiate @Sink : !cal.instance<@Sink>

  // Mix sugar and direct handle usage.
  cal.connect %s0 : !cal.instance<@Src> "out0" -> %arr0[%c0] : !cal.instance.array<@A, 1> "in0"
  cal.connect %arr0[%c0] : !cal.instance.array<@A, 1> "out0" -> %k0 : !cal.instance<@Sink> "in0"

  cal.connect %s1 : !cal.instance<@Src> "out0" -> %h1 : !cal.instance<@A> "in0"
  cal.connect %h1 : !cal.instance<@A> "out0" -> %k1 : !cal.instance<@Sink> "in0"
}
