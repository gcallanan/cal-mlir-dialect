// RUN: cal-opt -split-input-file %s -verify-diagnostics

// Positive: network matches interface arity and types
cal.interface @PipeNetSpec {
  inPortTypes = [!fifo.output_port<i32>],
  outPortTypes = [!fifo.input_port<i32>]
}

cal.network @NetOk()
  ports_in(%in0: !fifo.output_port<i32>)
  ports_out(%out0: !fifo.input_port<i32>) {
  // network body can be empty structurally
}

cal.implements @PipeNetSpec for @NetOk

// -----

// Negative: arity/type mismatch on input
cal.interface @TwoInOneOutN {
  inPortTypes = [!fifo.output_port<i32>, !fifo.output_port<i32>],
  outPortTypes = [!fifo.input_port<i32>]
}

cal.network @NetArity()
  ports_in(%in0: !fifo.output_port<i32>)
  ports_out(%out0: !fifo.input_port<i32>) {
}

// expected-error @+1 {{entity 'NetArity' does not conform to interface 'TwoInOneOutN': input port count mismatch}}
cal.implements @TwoInOneOutN for @NetArity

// -----

// Negative: names mismatch (when both interface and entity have names)
cal.interface @NamedIFNet {
  inPortNames = ["in"],
  inPortTypes = [!fifo.output_port<i16>],
  outPortNames = ["left", "right"],
  outPortTypes = [!fifo.input_port<i16>, !fifo.input_port<i16>]
}

cal.network @FanoutWrongNamesNet()
  in_names ["in"]
  out_names ["out0", "out1"]
  ports_in(%in: !fifo.output_port<i16>)
  ports_out(%o0: !fifo.input_port<i16>, %o1: !fifo.input_port<i16>) {
}

// expected-error @+1 {{output port[0] name mismatch: expected 'left', got 'out0'}}
cal.implements @NamedIFNet for @FanoutWrongNamesNet
