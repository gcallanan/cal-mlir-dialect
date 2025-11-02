// RUN: cal-opt --flatten-cal-networks %s | FileCheck %s

// cal.interface has attr-only assembly: use attribute dictionary
cal.interface @PipeLike { inPortNames = ["in"], inPortTypes = [!fifo.output_port<i32>], outPortNames = ["out"], outPortTypes = [!fifo.input_port<i32>] }

// Actor that conforms to @PipeLike
cal.actor @A()
  in_names ["in"] out_names ["out"] 
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// Declare conformance
cal.implements @PipeLike for @A

// Network using interface-typed handle and interface port names in connect
cal.network @top() {
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  %h = cal.instantiate @A : !cal.instance<@A>
  %ih = cal.instance.cast %h : !cal.instance<@A> -> !cal.instance.iface<@PipeLike>

  // Connect network out0 to actor input via interface name "in"
  cal.connect %out0 : !fifo.output_port<i32> "in" -> %ih : !cal.instance.iface<@PipeLike> "in"
  // Connect actor output via interface name "out" to network in0
  cal.connect %ih : !cal.instance.iface<@PipeLike> "out" -> %in0 : !fifo.input_port<i32> "out"
}

// CHECK: cal.network @top()
// CHECK: %[[IN:.*]], %[[OUT:.*]] = fifo.create<i32> (2)
// After elaboration, a cal.create_instance should be materialized for @A with ports wired
// CHECK: cal.create_instance @A
