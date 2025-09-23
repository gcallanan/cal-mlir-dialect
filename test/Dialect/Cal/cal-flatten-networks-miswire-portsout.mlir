// RUN: not cal-opt --flatten-cal-networks %s 2>&1 | FileCheck %s

// Negative test: mis-wire port directions for ports_out.
// Inner expects ports_out(!fifo.input_port<i32>) but we pass an output_port value.
// Expect type mismatch diagnostic referencing prior uses of the SSA value.
// CHECK: error: use of value '%out0' expects different type than prior uses

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

cal.network @Top(){
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  // INTENTIONALLY WRONG: ports_out gets an output_port instead of input_port
  cal.create_instance @Inner ()
      ports_in(%out0 : !fifo.output_port<i32>)
      ports_out(%out0 : !fifo.input_port<i32>) // wrong type reuse
}
