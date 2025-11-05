// RUN: cal-opt --flatten-cal-networks %s | FileCheck %s

// Define a trivial source actor with one output and a trivial sink with one input.
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

// A single source connected to two sinks should synthesize a 1-to-2 fanout actor.
cal.network @TopFan() {
  %src = cal.instantiate @Src : !cal.instance<@Src>
  %s0  = cal.instantiate @Sink : !cal.instance<@Sink>
  %s1  = cal.instantiate @Sink : !cal.instance<@Sink>
  // Both edges specify the same capacity; source->fan and fan->sinks should materialize with (5).
  cal.connect %src : !cal.instance<@Src> "out" -> %s0 : !cal.instance<@Sink> "in" capacity(5)
  cal.connect %src : !cal.instance<@Src> "out" -> %s1 : !cal.instance<@Sink> "in" capacity(5)
}

// CHECK: cal.actor @__cal_fanout_2_
// CHECK-LABEL: cal.network @TopFan()
// CHECK: cal.create_instance @__cal_fanout_2_
// CHECK: fifo.create<i32>(5)
// CHECK: fifo.create<i32>(5)
// CHECK: fifo.create<i32>(5)
