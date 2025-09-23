// RUN: not cal-opt %s 2>&1 | FileCheck %s
// Negative test: network instantiation with wrong port direction types.

// Define a network with one input (expects fifo.output_port) and one output (expects fifo.input_port)
cal.network @NW()
    ports_in(%inA: !fifo.output_port<i32>)
    ports_out(%outA: !fifo.input_port<i32>) {
}

cal.network @Top(){
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  // Intentionally swap: provide input port where output required for ports_in, and output where input required for ports_out
  cal.create_instance @NW ()
      ports_in(%in0 : !fifo.input_port<i32>)
      ports_out(%out0 : !fifo.output_port<i32>)
  // CHECK: expected fifo.output_port<...> for ports_in argument
}
