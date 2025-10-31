// RUN: cal-opt -canonicalize --flatten-cal-networks %s | FileCheck %s

// cal.interface with named ports
cal.interface @PipeLike { inPortNames = ["in"], inPortTypes = [!fifo.output_port<i32>], outPortNames = ["out"], outPortTypes = [!fifo.input_port<i32>] }

// Actor conforms to @PipeLike
cal.actor @A()
  in_names ["in"] out_names ["out"]
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.implements @PipeLike for @A

cal.network @IfaceArrayOK() {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index

  // Two inbound and two outbound fifos (per element)
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in2, %out2 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in3, %out3 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  // Instantiate array of actors
  %arr = cal.instantiate_array @A count (2) : !cal.instance.array<@A, 2>

  // Element 0 via interface-typed handle and interface port names
  %a0 = cal.instance_at %arr[%c0] : !cal.instance.array<@A, 2>, index -> !cal.instance<@A>
  %ia0 = cal.instance.cast %a0 : !cal.instance<@A> -> !cal.instance.iface<@PipeLike>
  cal.connect %out0 : !fifo.output_port<i32> "in" -> %ia0 : !cal.instance.iface<@PipeLike> "in"
  cal.connect %ia0 : !cal.instance.iface<@PipeLike> "out" -> %in1 : !fifo.input_port<i32> "out"

  // Element 1 similarly
  %a1 = cal.instance_at %arr[%c1] : !cal.instance.array<@A, 2>, index -> !cal.instance<@A>
  %ia1 = cal.instance.cast %a1 : !cal.instance<@A> -> !cal.instance.iface<@PipeLike>
  cal.connect %out2 : !fifo.output_port<i32> "in" -> %ia1 : !cal.instance.iface<@PipeLike> "in"
  cal.connect %ia1 : !cal.instance.iface<@PipeLike> "out" -> %in3 : !fifo.input_port<i32> "out"
}

// CHECK: cal.network @IfaceArrayOK()
// CHECK: cal.create_instance @A
// CHECK: cal.create_instance @A
