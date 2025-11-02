// Example: Building instance arrays without cal.instance_for
// Try:
//   cal-opt --verify-instance-array-fills examples/instance_for/instance_for.mlir
//   # Or run your usual structural pipeline; no cal.instance_for is used here.

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
  %arr0_init = cal.instance.array.init : !cal.instance.array<@A, 1>
  %arr0 = cal.instance.array.set %arr0_init[%c0], %hA0 : !cal.instance.array<@A, 1>, !cal.instance<@A> -> !cal.instance.array<@A, 1>

  // Build a separate size-1 array and extract its element via instance_at.
  %hA1 = cal.instantiate @A : !cal.instance<@A>
  %arr1_init = cal.instance.array.init : !cal.instance.array<@A, 1>
  %arr1 = cal.instance.array.set %arr1_init[%c0], %hA1 : !cal.instance.array<@A, 1>, !cal.instance<@A> -> !cal.instance.array<@A, 1>
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
