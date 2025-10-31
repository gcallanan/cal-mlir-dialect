// RUN: cal-opt -split-input-file %s -verify-diagnostics

// Positive: interface with named typed ports
// attributes only (no region) — using attr-dict form
cal.interface @PipeLike { 
  inPortTypes = [
    !fifo.output_port<i32>,
    !fifo.output_port<f32>
  ],
  outPortTypes = [
    !fifo.input_port<i32>
  ],
  inPortNames = ["in0", "in1"],
  outPortNames = ["out0"]
}

// -----

// Negative: duplicate names
// expected-error @+1 {{input port names must be unique; duplicate 'in0'}}
cal.interface @BadNames {
  inPortTypes = [!fifo.output_port<i32>],
  inPortNames = ["in0", "in0"]
}

// -----

// Negative: wrong type kind in list
// expected-error @+1 {{output port type at index 0 must be a fifo.input_port<...>}}
cal.interface @BadTypes {
  outPortTypes = [!fifo.output_port<i32>]
}
