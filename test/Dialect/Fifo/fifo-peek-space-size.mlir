// Check the expected syntax of the fifo.push and fifo.pull commands.

// RUN: cal-opt %s | cal-opt | FileCheck %s
%index0 = arith.constant 0 : index
%index1 = arith.constant 1 : index
%c32 = arith.constant 32 : i32
%in0,%out0 = fifo.create<i32>(5) : !fifo.input_port<i32>, !fifo.output_port<i32>

%0 = fifo.size(%out0: !fifo.output_port<i32>) : index
%1 = fifo.space(%in0: !fifo.input_port<i32>) : index
%2 = fifo.peek(%out0: !fifo.output_port<i32>, %index0: index) : i32
%3 = fifo.peek(%out0: !fifo.output_port<i32>, %index1: index) : i32
// CHECK: %0 = fifo.size(%outputPort : !fifo.output_port<i32>) : index
// CHECK: %1 = fifo.space(%inputPort : !fifo.input_port<i32>) : index
// CHECK: %2 = fifo.peek(%outputPort : !fifo.output_port<i32>, %c0 : index) : i32
// CHECK: %3 = fifo.peek(%outputPort : !fifo.output_port<i32>, %c1 : index) : i32
