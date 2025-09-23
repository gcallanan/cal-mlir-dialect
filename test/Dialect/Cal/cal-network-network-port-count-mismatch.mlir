// RUN: not cal-opt %s 2>&1 | FileCheck %s
// Negative test: operand count mismatch for network instantiation.

cal.network @NW()
    ports_in(%nIn0: !fifo.output_port<i32>, %nIn1: !fifo.output_port<i32>)
    ports_out(%nOut0: !fifo.input_port<i32>) {
}

cal.network @Top(){
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  // Missing one input port and the single required output port (expects 3 operands total)
  cal.create_instance @NW ()
      ports_in(%out0 : !fifo.output_port<i32>)
  // CHECK: operand count mismatch: expected 3 operands (network params+ports), but got 1
}
