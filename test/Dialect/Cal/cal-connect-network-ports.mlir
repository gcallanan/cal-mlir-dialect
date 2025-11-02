// RUN: cal-opt -pass-pipeline='builtin.module(flatten-cal-networks)' %s | FileCheck %s

// Actor that forwards one token from in to out
cal.actor @Wire()
  ports_in(%in: !fifo.output_port<i32>)
  ports_out(%out: !fifo.input_port<i32>)
{
  cal.execution_body {
    %sz = fifo.size(%in: !fifo.output_port<i32>) : index
    %c0 = arith.constant 0 : index
    %ready = arith.cmpi sgt, %sz, %c0 : index
    scf.if %ready {
      %t = fifo.pop(%in: !fifo.output_port<i32>) : i32
      fifo.push(%out: !fifo.input_port<i32>, %t: i32)
    }
    cal.action_done %ready : i1
  }
}

// Network with external ports, connecting them to the Wire actor via cal.connect using network endpoints.
cal.network @Top()
  ports_in(%net_in: !fifo.output_port<i32>)
  ports_out(%net_out: !fifo.input_port<i32>) {
  %w = cal.instantiate @Wire : !cal.instance<@Wire>

  // Connect network input to actor in-port
  cal.connect %net_in : !fifo.output_port<i32> "in" -> %w : !cal.instance<@Wire> "in"
  // Connect actor out-port to network output
  cal.connect %w : !cal.instance<@Wire> "out" -> %net_out : !fifo.input_port<i32> "out"
}

// After elaboration, the connect ops should be erased and create_instance should
// receive the network ports directly, with NO fifo.create materialized for these edges.
// CHECK: cal.create_instance @Wire
// CHECK: ports_in (
// CHECK-SAME: !fifo.output_port<i32>
// CHECK: ports_out (
// CHECK-SAME: !fifo.input_port<i32>
// CHECK-NOT: fifo.create
