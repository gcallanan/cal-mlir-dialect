// Here we check that the command produces an expected error.
// RUN: cal-opt -split-input-file %s -verify-diagnostics

// expected-error @+1 {{'fifo.create' op CreateOp buffer size is 0 but must be greater than 0}}
%in1, %out0 = fifo.create<i32>(0) : !fifo.input_port<i32>, !fifo.output_port<i32>

// -----

// expected-error @+1 {{'fifo.create' op CreateOp buffer size is -5 but must be greater than 0}
%in1, %out0 = fifo.create<i32>(-5) : !fifo.input_port<i32>, !fifo.output_port<i32>

// -----

// expected-error @+1 {{operation defines 2 results but was provided 1 to bind}}
%out0 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>

// -----

// expected-error @+1 {{operation defines 2 results but was provided 1 to bind}}
%in1 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>

// -----

// expected-error @+1 {{'fifo.create' op expected inputPort to be of type InputPortType (!fifo.input_port<'i32'>), but got 'i32'}}
%in0, %out0 = fifo.create<i32>(1) : i32, !fifo.output_port<i32>

// -----

// expected-error @+1 {{'fifo.create' op expected inputPort element type to be 'i32', but got 'i64'}}
%in0, %out0 = fifo.create<i32>(1) : !fifo.input_port<i64>, !fifo.output_port<i32>

// -----

// expected-error @+1 {{'fifo.create' op expected outputPort to be of type OutputPortType (!fifo.output_port<'i32'>), but got 'i32'}}
%in0, %out0 = fifo.create<i32>(1) : !fifo.input_port<i32>, i32

// -----

// expected-error @+1 {{'fifo.create' op expected outputPort element type to be 'i32', but got 'i64'}}
%in0, %out0 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i64>
