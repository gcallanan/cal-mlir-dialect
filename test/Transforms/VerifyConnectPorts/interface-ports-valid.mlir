// RUN: cal-opt --composite-fixed-point-pass="pipeline=cal-structural-elaboration" %s | FileCheck %s --allow-empty

// Define an interface with one out and one in port (names only).
cal.interface @I { 
  inPortNames = ["in0"], 
  inPortTypes = [!fifo.output_port<i32>],
  outPortNames = ["out0"],
  outPortTypes = [!fifo.input_port<i32>]
}

// We don't need a concrete entity for the late port verifier to accept
// interface-typed handles; it validates names against the interface.

cal.network @N() {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index

  %arr = cal.instantiate_array.iface @I count(2) : !cal.instance.array.iface<@I, [2]>
  %h0 = cal.instance_at %arr[%c0] : !cal.instance.array.iface<@I, [2]> -> !cal.instance.iface<@I>
  %h1 = cal.instance_at %arr[%c1] : !cal.instance.array.iface<@I, [2]> -> !cal.instance.iface<@I>

  // Valid ports per interface
  cal.connect %h0 : !cal.instance.iface<@I> "out0" -> %h1 : !cal.instance.iface<@I> "in0"
}

// CHECK-NOT: error: