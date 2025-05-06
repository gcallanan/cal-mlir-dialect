// RUN: cal-opt %s | FileCheck %s

%input1 = arith.constant 10 : i64
%input2 = arith.constant 20 : i64
%input3 = arith.constant 30 : i64

cal.actor @my_actor
{
}

%in0,%out0 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
%in1,%out1 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
%in2,%out2 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>

cal.actor @my_actor2
        ports_out(%in0, %in1, %in2 : !fifo.input_port<i32>, !fifo.input_port<i32>, !fifo.input_port<i32>)
{
}

cal.actor @my_actor3
        ports_in(%out0, %out1, %out2 : !fifo.output_port<i32>, !fifo.output_port<i32>, !fifo.output_port<i32>)
{
}

cal.actor @my_actor4
        ports_out(%in0, %in1, %in2 : !fifo.input_port<i32>, !fifo.input_port<i32>, !fifo.input_port<i32>)
        ports_in(%out0, %out1, %out2 : !fifo.output_port<i32>, !fifo.output_port<i32>, !fifo.output_port<i32>)
{
}

// CHECK: cal.actor @my_actor2 ports_out(%inputPort, %inputPort_0, %inputPort_2 : !fifo.input_port<i32>, !fifo.input_port<i32>, !fifo.input_port<i32>)
// CHECK: cal.actor @my_actor3 ports_in(%outputPort, %outputPort_1, %outputPort_3 : !fifo.output_port<i32>, !fifo.output_port<i32>, !fifo.output_port<i32>)
// CHECK: cal.actor @my_actor4 ports_out(%inputPort, %inputPort_0, %inputPort_2 : !fifo.input_port<i32>, !fifo.input_port<i32>, !fifo.input_port<i32>) ports_in(%outputPort, %outputPort_1, %outputPort_3 : !fifo.output_port<i32>, !fifo.output_port<i32>, !fifo.output_port<i32>)


cal.actor @my_actor5
    ports_out(%in0, %in1, %in2 : !fifo.input_port<i32>, !fifo.input_port<i32>, !fifo.input_port<i32>)
    ports_in(%out0, %out1, %out2 : !fifo.output_port<i32>, !fifo.output_port<i32>, !fifo.output_port<i32>)
    {        
        initial_region{
            //^bb0(%arg0: !fifo.input_port<i32>, %arg1: !fifo.input_port<i32>, %arg2: !fifo.input_port<i32>, 
            //     %arg3: !fifo.output_port<i32>, %arg4: !fifo.output_port<i32>, %arg5: !fifo.output_port<i32>):
                %c1 = arith.constant 10 : i32
            //    fifo.push(%arg0: !fifo.input_port<i32>, %c1: i32)
        }
        
    }