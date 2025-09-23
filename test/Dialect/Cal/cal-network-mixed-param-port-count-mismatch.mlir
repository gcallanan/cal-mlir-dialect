// RUN: not cal-opt %s 2>&1 | FileCheck %s
// Negative test: parameter + port count mismatch.
// Actor expects: (%p0: i32) + ports_in(%in0) + ports_out(%out0) -> total 3 operands.
// Provide only param + input port (missing output port) => count mismatch.

cal.actor @WithParam(%p0: i32)
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>) {
}

cal.network @TopMixed(){
  %c0 = arith.constant 0 : i32
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  // Missing required output port operand
  cal.create_instance @WithParam (%c0 : i32)
      ports_in(%out0 : !fifo.output_port<i32>)
  // CHECK: operand count mismatch: expected 3 operands (actor params+ports), but got 2
}
