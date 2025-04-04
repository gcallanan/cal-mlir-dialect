// Check the expected syntax of the fifo.peek, fifo.space and fifo.size commands
// RUN: cal-opt -split-input-file %s -verify-diagnostics

%in0,%out0 = fifo.create<i32>(5) : !fifo.input_port<i32>, !fifo.output_port<i32>
// expected-error @+1 {{custom op 'fifo.size' invalid kind of type specified}}
%0 = fifo.size(%out0: !fifo.output_port<i32>) : i33

// -----

%in1,%out1 = fifo.create<i32>(5) : !fifo.input_port<i32>, !fifo.output_port<i32>
// expected-error @+1 {{custom op 'fifo.space' invalid kind of type specified}}
%1 = fifo.space(%in1: !fifo.input_port<i32>) : i33

// -----

%in2,%out2 = fifo.create<i32>(5) : !fifo.input_port<i32>, !fifo.output_port<i32>
// expected-error @+1 {{custom op 'fifo.size' invalid kind of type specified}}
%2 = fifo.size(%in2: !fifo.input_port<i32>) : i32
// -----

%in3,%out3 = fifo.create<i32>(5) : !fifo.input_port<i32>, !fifo.output_port<i32>
// expected-error @+1 {{custom op 'fifo.space' invalid kind of type specified}}
%3 = fifo.space(%out3: !fifo.output_port<i32>) : i32

// -----

%index4 = arith.constant 0 : index
%in4,%out4 = fifo.create<i32>(5) : !fifo.input_port<i32>, !fifo.output_port<i32>
// expected-error @+1 {{'fifo.peek' op expected outputPort to be of type OutputPortType (!fifo.output_port<...>), but got '!fifo.input_port<i32>'}}
%4 = fifo.peek(%in4: !fifo.input_port<i32>, %index4: index) : i32

// -----

%c32 = arith.constant 32 : i32
%in5,%out5 = fifo.create<i32>(5) : !fifo.input_port<i32>, !fifo.output_port<i32>
// expected-error @+1 {{custom op 'fifo.peek' invalid kind of type specified}}
%5 = fifo.peek(%out5: !fifo.output_port<i32>, %c32: i32) : i32