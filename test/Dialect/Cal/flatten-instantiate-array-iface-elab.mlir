// RUN: cal-opt --flatten-cal-networks -split-input-file %s -verify-diagnostics | FileCheck %s --implicit-check-not=cal.create_instance

// Case: Elaborate interface-typed instance array with connects; expect remarks and no materialization
cal.interface @PipeLike { inPortNames = ["in"], inPortTypes = [!fifo.output_port<i32>], outPortNames = ["out"], outPortTypes = [!fifo.input_port<i32>] }

cal.network @TopIfaceArray() {
  %c0 = arith.constant 0 : index
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %arr = cal.instantiate_array.iface @PipeLike count(1) : !cal.instance.array.iface<@PipeLike, 1>
  %h0 = cal.instance_at %arr[%c0] : !cal.instance.array.iface<@PipeLike, 1>, index -> !cal.instance.iface<@PipeLike>

  // expected-remark@+1 {{skipping materialization for interface-typed endpoint; requires resolution to a concrete entity}}
  cal.connect %out0 : !fifo.output_port<i32> "in" -> %h0 : !cal.instance.iface<@PipeLike> "in"
  // expected-remark@+1 {{skipping materialization for interface-typed endpoint; requires resolution to a concrete entity}}
  cal.connect %h0 : !cal.instance.iface<@PipeLike> "out" -> %in0 : !fifo.input_port<i32> "out"
}

// CHECK: cal.network @TopIfaceArray()
// CHECK: cal.instantiate_array.iface @PipeLike count(1)
// CHECK: cal.instance_at %arr[%c0]
// CHECK: cal.connect
