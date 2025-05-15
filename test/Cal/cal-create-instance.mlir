// RUN: cal-opt %s | FileCheck %s

cal.actor @simple()
{
    
}

cal.actor @one_input()
    ports_in(%in0: !fifo.output_port<i32>)
{
    
}

cal.actor @one_output()
    ports_out(%out0: !fifo.input_port<i32>)
{
    
}

cal.actor @inputs_and_output(%c1 : i32)
    ports_in(%in0: !fifo.output_port<i32>, %in1: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>)
{
    
}

cal.network{
    %1 = arith.constant 10 : i32
    %in0, %out0 = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %in1, %out1 = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>

    cal.create_instance @simple "actor1" ()
    // CHECK: cal.create_instance @simple "actor1" ()

    cal.create_instance @simple "actor2" ()
    // CHECK: cal.create_instance @simple "actor2" ()

    cal.create_instance @simple () // Test without a name
    // CHECK: cal.create_instance @simple()

    cal.create_instance @one_input () ports_in(%out0: !fifo.output_port<i32>)
    // CHECK: cal.create_instance @one_input()
    // CHECK:     ports_in (%outputPort : !fifo.output_port<i32>)
    
    cal.create_instance @one_output () ports_out(%in0: !fifo.input_port<i32>)
    // CHECK: cal.create_instance @one_output()
    // CHECK:     ports_out (%inputPort : !fifo.input_port<i32>)

    cal.create_instance @inputs_and_output (%1: i32) 
        ports_in(%out0, %out1: !fifo.output_port<i32>, !fifo.output_port<i32>)
        ports_out(%in0: !fifo.input_port<i32>)
    // CHECK: cal.create_instance @inputs_and_output(%c10_i32 : i32)
    // CHECK:     ports_in (%outputPort, %outputPort_1 : !fifo.output_port<i32>, !fifo.output_port<i32>)
    // CHECK:     ports_out (%inputPort : !fifo.input_port<i32>)
}