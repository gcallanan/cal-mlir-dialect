// RUN: cal-opt %s --insert-fanout-on-multisink | FileCheck %s

module {
  // Minimal sink actor with one input port; name the port to aid readability
  cal.actor @sink()
      in_names ["IN"]
      ports_in(
        %in0: !fifo.output_port<i32>
      )
  {
    cal.action {
      %t = fifo.pop(%in0 : !fifo.output_port<i32>) : i32
    }
  }

  // Network with one fifo output port feeding two sinks (multi-sink pattern)
  cal.network @net() {
    %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %a = cal.instantiate @sink : <@sink>
    %b = cal.instantiate @sink : <@sink>

    // Two connects from same network port to two distinct sinks
    cal.connect %out0 : !fifo.output_port<i32> "src" -> %a : !cal.instance<@sink> "IN"
    cal.connect %out0 : !fifo.output_port<i32> "src" -> %b : !cal.instance<@sink> "IN"
  }
}

// CHECK: module {
// CHECK:   cal.actor @__fanout_i32_2()
// CHECK:   ports_in (
// CHECK:   !fifo.output_port<i32>
// CHECK:   )
// CHECK:   ports_out (
// CHECK:   !fifo.input_port<i32>
// CHECK:   !fifo.input_port<i32>
// CHECK:   cal.network @net() {
// CHECK:     %[[SINKA:.*]] = cal.instantiate @sink
// CHECK:     %[[SINKB:.*]] = cal.instantiate @sink
// CHECK:     %[[F:.*]] = cal.instantiate @__fanout_i32_2
// CHECK:     cal.connect %out0 : !fifo.output_port<i32> "src" -> %[[F]] : !cal.instance<@__fanout_i32_2> "in"
// CHECK:     cal.connect %[[F]] : !cal.instance<@__fanout_i32_2> "out0" -> %[[SINKA]] : !cal.instance<@sink> "IN"
// CHECK:     cal.connect %[[F]] : !cal.instance<@__fanout_i32_2> "out1" -> %[[SINKB]] : !cal.instance<@sink> "IN"
// CHECK:   }
// CHECK: }
