// Here we check for expect errors in the fifo.push and fifo.pull commands.
// RUN: cal-opt -split-input-file %s -verify-diagnostics

%in0,%out0 = fifo.create<i32>(5) : !fifo.input_port<i32>, !fifo.output_port<i32>
// expected-error @+1 {{'fifo.pull' op expected outputPort element type to be 'i33', but got 'i32'}}
%0 = fifo.pull(%out0: !fifo.output_port<i32>) : i33
// -----

%in0,%out0 = fifo.create<i32>(5) : !fifo.input_port<i32>, !fifo.output_port<i32>
// expected-error @+1 {{'fifo.pull' op expected outputPort to be of type OutputPortType (!fifo.output_port<'i32'>), but got '!fifo.input_port<i32>'}}
%0 = fifo.pull(%in0: !fifo.input_port<i32>) : i32
// -----

%in0,%out0 = fifo.create<i32>(5) : !fifo.input_port<i32>, !fifo.output_port<i32>
%c32 = arith.constant 32 : i32
// expected-error @+1 {{'fifo.push' op expected inputPort to be of type InputPortType (!fifo.input_port<'i32'>), but got '!fifo.output_port<i32>'}}
fifo.push(%out0: !fifo.output_port<i32>, %c32: i32)
// -----

%in0,%out0 = fifo.create<i32>(5) : !fifo.input_port<i32>, !fifo.output_port<i32>
%c32 = arith.constant 32 : i42
// expected-error @+1 {{'fifo.push' op expected inputPort element type to be 'i42', but got 'i32'}}
fifo.push(%in0: !fifo.input_port<i32>, %c32: i42)
// -----