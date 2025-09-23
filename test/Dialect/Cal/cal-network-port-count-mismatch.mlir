// RUN: not cal-opt %s 2>&1 | FileCheck %s
// Negative test: operand count mismatch for actor instantiation.

// Actor with 2 ports (1 in, 1 out)
cal.actor @C()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>) {
}

cal.network @Parent(){
  // Create resources
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  // Actor count mismatch: missing required output port (expects 2 operands total, got 1)
  cal.create_instance @C ()
      ports_in(%out0 : !fifo.output_port<i32>)
  // CHECK: operand count mismatch: expected 2 operands (actor params+ports), but got 1

}
