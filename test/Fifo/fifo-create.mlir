// RUN: cal-opt %s | cal-opt | FileCheck %s
%in0,%out0 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
// CHECK: %inputPort, %outputPort = fifo.create<i32> (1) : !fifo.input_port<i32>, !fifo.output_port<i32>
%in1,%out1 = fifo.create<i64>(78) : !fifo.input_port<i64>, !fifo.output_port<i64>
// CHECK: %inputPort_0, %outputPort_1 = fifo.create<i64> (78) : !fifo.input_port<i64>, !fifo.output_port<i64>