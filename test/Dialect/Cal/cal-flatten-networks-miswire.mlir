// RUN: not cal-opt --flatten-cal-networks %s 2>&1 | FileCheck %s

// Negative test: mis-wire port directions when instantiating a network.
// Inner expects: ports_in(!fifo.output_port<i32>) ports_out(!fifo.input_port<i32>)
// We (incorrectly) pass an input_port to ports_in and an output_port to ports_out.
// Expect a type mismatch diagnostic referencing differing prior uses.
// CHECK: error: use of value '%in0' expects different type than prior uses

cal.actor @Leaf()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>) {
}

cal.network @Inner()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>) {
  cal.create_instance @Leaf ()
      ports_in(%in0 : !fifo.output_port<i32>)
      ports_out(%out0 : !fifo.input_port<i32>)
}

// Top network with incorrect wiring order
cal.network @Top(){
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  // INTENTIONALLY WRONG: ports_in gets an input_port; ports_out gets an output_port
  cal.create_instance @Inner ()
      ports_in(%in0 : !fifo.output_port<i32>) // wrong type
      ports_out(%out0 : !fifo.input_port<i32>) // wrong type
}