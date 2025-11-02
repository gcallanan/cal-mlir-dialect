// RUN: cal-opt -canonicalize --flatten-cal-networks %s | FileCheck %s

// Simple actor with one input and one output port
cal.actor @A()
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// Network connects network FIFO ports directly to elements of a 1D instance array
cal.network @NetNDPorts() {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index

  // Two inbound and two outbound fifos (per element)
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in2, %out2 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in3, %out3 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  // Instantiate array of actors (1D ND array)
  %arr = cal.instantiate_array @A count(2) : !cal.instance.array<@A, [2]>

  // Index elements and wire network ports directly
  %a0 = cal.instance_at %arr[%c0] : !cal.instance.array<@A, [2]> -> !cal.instance<@A>
  cal.connect %out0 : !fifo.output_port<i32> "in" -> %a0 : !cal.instance<@A> "in"
  cal.connect %a0 : !cal.instance<@A> "out" -> %in1 : !fifo.input_port<i32> "out"

  %a1 = cal.instance_at %arr[%c1] : !cal.instance.array<@A, [2]> -> !cal.instance<@A>
  cal.connect %out2 : !fifo.output_port<i32> "in" -> %a1 : !cal.instance<@A> "in"
  cal.connect %a1 : !cal.instance<@A> "out" -> %in3 : !fifo.input_port<i32> "out"
}

// CHECK: cal.network @NetNDPorts()
// CHECK: cal.create_instance @A
// CHECK: cal.create_instance @A
