// REQUIRES: merge-simple-cal-actors
// RUN: cal-opt --merge-simple-cal-actors=print-edges-for-testing %s | FileCheck %s

//CHECK: Network edges:
//CHECK:   initial_conditions_0 -> merge_1
//CHECK:   merge_1 -> cat_and_broadcast_2
//CHECK:   cat_and_broadcast_2 -> f_0_5
//CHECK:   cat_and_boundary_3 -> integrate_4
//CHECK:   integrate_4 -> merge_1
//CHECK:   f_0_5 -> cat_and_boundary_3

cal.actor @f_0()
    ports_in(%in : !fifo.output_port<tensor<1x1000000xf64>>)
    ports_out(%out : !fifo.input_port<tensor<1x1000000xf64>>)
{
}

cal.actor @merge()
    ports_in(%ic: !fifo.output_port<tensor<1x1000000xf64>>, %next: !fifo.output_port<tensor<1x1000000xf64>>)
    ports_out(%out: !fifo.input_port<tensor<1x1000000xf64>>)
{
}

cal.actor @cat_and_broadcast()
    ports_in(%in0 : !fifo.output_port<tensor<1x1000000xf64>>)
    ports_out(%out0 : !fifo.input_port<tensor<1x1000000xf64>>)
{
}

cal.actor @integrate()
    ports_in(%in : !fifo.output_port<tensor<1x1000002xf64>>)
    ports_out(%out : !fifo.input_port<tensor<1x1000000xf64>>)
{
}

cal.actor @initial_conditions()
    ports_out(%out : !fifo.input_port<tensor<1x1000000xf64>>)
{
}

cal.actor @cat_and_boundary()
    ports_in(%f_0 : !fifo.output_port<tensor<1x1000000xf64>>)
    ports_out(%out : !fifo.input_port<tensor<1x1000002xf64>>)
{
}

cal.network {
    %initial_conditions_merge_i, %initial_conditions_merge_o = fifo.create<tensor<1x1000000xf64>>(1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
    %integrate_merge_i, %integrate_merge_o = fifo.create<tensor<1x1000000xf64>>(1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
    %merge_cat_and_broadcast_i, %merge_cat_and_broadcast_o = fifo.create<tensor<1x1000000xf64>>(1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
    %cat_and_boundary_integrate_i, %cat_and_boundary_integrate_o = fifo.create<tensor<1x1000002xf64>>(1) : !fifo.input_port<tensor<1x1000002xf64>>, !fifo.output_port<tensor<1x1000002xf64>>
    %f_0_cat_and_boundary_i, %f_0_cat_and_boundary_o = fifo.create<tensor<1x1000000xf64>>(1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
    %cat_and_broadcast_f_0_i, %cat_and_broadcast_f_0_o = fifo.create<tensor<1x1000000xf64>>(1) : !fifo.input_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>
    
    cal.create_instance @initial_conditions "initial_conditions_0" ()
        ports_out(%initial_conditions_merge_i : !fifo.input_port<tensor<1x1000000xf64>>)
    
    cal.create_instance @merge "merge_1" ()
        ports_in(%initial_conditions_merge_o, %integrate_merge_o : !fifo.output_port<tensor<1x1000000xf64>>, !fifo.output_port<tensor<1x1000000xf64>>)
        ports_out(%merge_cat_and_broadcast_i : !fifo.input_port<tensor<1x1000000xf64>>)
    
    cal.create_instance @cat_and_broadcast "cat_and_broadcast_2" ()
        ports_in(%merge_cat_and_broadcast_o : !fifo.output_port<tensor<1x1000000xf64>>)
        ports_out(%cat_and_broadcast_f_0_i : !fifo.input_port<tensor<1x1000000xf64>>)
    
    cal.create_instance @cat_and_boundary "cat_and_boundary_3" ()
        ports_in(%f_0_cat_and_boundary_o : !fifo.output_port<tensor<1x1000000xf64>>)
        ports_out(%cat_and_boundary_integrate_i : !fifo.input_port<tensor<1x1000002xf64>>)
    
    cal.create_instance @integrate "integrate_4" ()
        ports_in(%cat_and_boundary_integrate_o : !fifo.output_port<tensor<1x1000002xf64>>)
        ports_out(%integrate_merge_i : !fifo.input_port<tensor<1x1000000xf64>>)
    
    cal.create_instance @f_0 "f_0_5" ()
        ports_in(%cat_and_broadcast_f_0_o : !fifo.output_port<tensor<1x1000000xf64>>)
        ports_out(%f_0_cat_and_boundary_i : !fifo.input_port<tensor<1x1000000xf64>>)
}
