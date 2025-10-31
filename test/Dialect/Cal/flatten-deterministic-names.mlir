// RUN: cal-opt --flatten-cal-networks %s | FileCheck %s

// Simple actor with 1 in/1 out
cal.actor @A()
  in_names ["in"] out_names ["out"]
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// Network with two instances of @A; one named, one unnamed. Connect them
// so a fifo is materialized deterministically and both instances are created
// with stable names.
cal.network @N() {
  // network boundary ports
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  // Instantiate two actors: first unnamed, second has user name "user"
  %h0 = cal.instantiate @A : !cal.instance<@A>
  %h1 = cal.instantiate @A instance("user") : !cal.instance<@A>

  // Wire: out0 -> h0(in), h0(out) -> h1(in), h1(out) -> in1
  cal.connect %out0 : !fifo.output_port<i32> "out" -> %h0 : !cal.instance<@A> "in"
  cal.connect %h0 : !cal.instance<@A> "out" -> %h1 : !cal.instance<@A> "in"
  cal.connect %h1 : !cal.instance<@A> "out" -> %in1 : !fifo.input_port<i32> "in"
}

// CHECK-LABEL: cal.network @N()
// CHECK-DAG: cal.create_instance @A "user"
// CHECK-DAG: cal.create_instance @A "N.A.0"
// CHECK-DAG: fifo.create<i32> (1) {cal.name = "N.N.A.0.out0->user.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
