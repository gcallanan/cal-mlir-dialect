// RUN: cal-opt -split-input-file %s -verify-diagnostics

// Set up an actor with one i32 parameter and one output port
cal.actor @A(%p0: i32)
  ports_out(%o: !fifo.input_port<i32>)
{
}

// Positive: valid array instantiation with matching param type and count=2
cal.network @OK() {
  %c1 = arith.constant 1 : i32
  %arr = cal.instantiate_array @A count (2) (%c1 : i32) : !cal.instance.array<@A, 2>
}

// -----

// Negative: count must be > 0
cal.actor @A(%p0: i32)
  ports_out(%o: !fifo.input_port<i32>)
{
}

cal.network @BadCount() {
  %c1 = arith.constant 1 : i32
  // expected-error @+1 {{array count must be > 0}}
  %arr0 = cal.instantiate_array @A count (0) (%c1 : i32) : !cal.instance.array<@A, 0>
}

// -----

// Negative: actor symbol not found
cal.actor @A(%p0: i32)
  ports_out(%o: !fifo.input_port<i32>)
{
}

cal.network @BadSymbol() {
  %c1 = arith.constant 1 : i32
  // expected-error @+1 {{actor symbol 'B' not found}}
  %arrB = cal.instantiate_array @B count (2) (%c1 : i32) : !cal.instance.array<@B, 2>
}

// -----

// Negative: parameter count mismatch (expected 1, got 0)
cal.actor @A(%p0: i32)
  ports_out(%o: !fifo.input_port<i32>)
{
}

cal.network @BadArity() {
  // expected-error @+1 {{parameter count mismatch}}
  %arr = cal.instantiate_array @A count (2) : !cal.instance.array<@A, 2>
}

// -----

// Negative: parameter type mismatch
cal.actor @A(%p0: i32)
  ports_out(%o: !fifo.input_port<i32>)
{
}

cal.network @BadType() {
  %f = arith.constant 1.0 : f32
  // expected-error @+1 {{parameter type mismatch at index 0: expected 'i32', got 'f32'}}
  %arr = cal.instantiate_array @A count (2) (%f : f32) : !cal.instance.array<@A, 2>
}
