// Check that the declared input and output port types for the FIFO dialect are
// correctly parsed and printed.
// RUN: cal-opt %s | cal-opt | FileCheck %s
func.func @fifo_types(%arg0: !fifo.input_port<i32>, %arg1: !fifo.output_port<ui17>) {
   return
}

// CHECK: func.func @fifo_types(%arg0: !fifo.input_port<i32>, %arg1: !fifo.output_port<ui17>) {
