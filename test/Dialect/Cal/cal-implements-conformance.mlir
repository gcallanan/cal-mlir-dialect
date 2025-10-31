// RUN: cal-opt -split-input-file %s -verify-diagnostics

// Positive: actor matches interface arity and types
cal.interface @PipeSpec {
  inPortTypes = [!fifo.output_port<i32>],
  outPortTypes = [!fifo.input_port<i32>]
}

cal.actor @Aok()
  ports_in(%in0: !fifo.output_port<i32>)
  ports_out(%out0: !fifo.input_port<i32>)
{
}

cal.implements @PipeSpec for @Aok

// -----

// Negative: arity mismatch
cal.interface @TwoInOneOut {
  inPortTypes = [!fifo.output_port<i32>, !fifo.output_port<i32>],
  outPortTypes = [!fifo.input_port<i32>]
}

cal.actor @A_arity()
  ports_in(%in0: !fifo.output_port<i32>)
  ports_out(%out0: !fifo.input_port<i32>)
{
}

// expected-error @+1 {{entity 'A_arity' does not conform to interface 'TwoInOneOut': input port count mismatch}}
cal.implements @TwoInOneOut for @A_arity

// -----

// Negative: type mismatch
cal.interface @PipeI32 {
  inPortTypes = [!fifo.output_port<i32>],
  outPortTypes = [!fifo.input_port<i32>]
}

cal.actor @A_type()
  ports_in(%in0: !fifo.output_port<f32>)
  ports_out(%out0: !fifo.input_port<i32>)
{
}

// expected-error @+1 {{type mismatch}}
cal.implements @PipeI32 for @A_type

// -----

// Positive: names match positionally
cal.interface @NamedIF {
  inPortNames = ["in"],
  inPortTypes = [!fifo.output_port<i16>],
  outPortNames = ["out0", "out1"],
  outPortTypes = [!fifo.input_port<i16>, !fifo.input_port<i16>]
}

cal.actor @cal.fanout__i16__k2()
  in_names ["in"]
  out_names ["out0", "out1"]
  ports_in(%in: !fifo.output_port<i16>)
  ports_out(%out0: !fifo.input_port<i16>, %out1: !fifo.input_port<i16>)
{
}

cal.implements @NamedIF for @cal.fanout__i16__k2

// -----

// Negative: names mismatch
cal.interface @NamedIF2 {
  inPortNames = ["in"],
  inPortTypes = [!fifo.output_port<i16>],
  outPortNames = ["left", "right"],
  outPortTypes = [!fifo.input_port<i16>, !fifo.input_port<i16>]
}

cal.actor @FanoutWrongNames()
  in_names ["in"]
  out_names ["out0", "out1"]
  ports_in(%in: !fifo.output_port<i16>)
  ports_out(%o0: !fifo.input_port<i16>, %o1: !fifo.input_port<i16>)
{
}

// expected-error @+1 {{output port[0] name mismatch: expected 'left', got 'out0'}}
cal.implements @NamedIF2 for @FanoutWrongNames
