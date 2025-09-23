// RUN: not cal-opt %s 2>&1 | FileCheck %s
// Negative test: pass wrong port type (input instead of output) to ports_in of an actor.

cal.actor @A()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>) {
}

cal.network @NegPortMismatch(){
    %inA, %outA = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
    // ports_in expects an !fifo.output_port<i32> but we pass %inA which is !fifo.input_port<i32>
    cal.create_instance @A ()
            ports_in(%inA : !fifo.input_port<i32>)
            ports_out(%inA : !fifo.input_port<i32>)
}
// CHECK: expected fifo.output_port
