// Check the expected syntax of the fifo.push and fifo.pull commands.

// RUN: cal-opt %s | cal-opt | FileCheck %s
%c32 = arith.constant 32 : i32
%in0,%out0 = fifo.create<i32>(5) : !fifo.input_port<i32>, !fifo.output_port<i32>

%0 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
// CHECK: %0 = fifo.pop(%outputPort : !fifo.output_port<i32>) : i32

fifo.push(%in0: !fifo.input_port<i32>, %c32: i32)
// CHECK: fifo.push(%inputPort : !fifo.input_port<i32>, %c32_i32 : i32)
