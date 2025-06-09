// This code demonstrates the use of MLIR CAL and FIFO dialects to implement a 
// basic dataflow network with the following components:
//
// - 2 Source actors (src1 and src2) that generate data
// - 1 Merge actor that combines data streams
// - 1 Sink actor that consumes the merged data
//
// The network structure:
// +------+     +------+     
// | src1 |     | src2 |     
// +--+---+     +---+--+     
//    |             |        
//    v             v        
//   +---------------+       
//   |    merge      |       
//   +-------+-------+       
//           |               
//           v               
//        +------+           
//        | sink |           
//        +------+  
//
// You can run this code with:
// cal-opt --lower-cal-to-llvm merge.mlir | cal-translate --mlir-to-llvmir | lli
//
// Where:
//  cal-opt --lower-cal-to-llvm merge.mlir - This command lowers the CAL dialect to the LLVM IR dialect.
//  cal-translate --mlir-to-llvmir - This command translates the MLIR to LLVM IR.
//  lli - This command executes the LLVM IR code using the LLVM interpreter.
//
// Alternativly "bash run.sh" from the terminal will execute these commands for you

cal.actor @src(%max_tokens_to_send: i32, %actor_index: i32)
    ports_out(%out0: !fifo.input_port<i32>)
{
    %num_tokens_sent_state = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %c0: i32)

    cal.action
    {
        cal.predicate {
            %num_tokens_sent = cal.get(%num_tokens_sent_state: !cal.state_ref<i32>) : i32
            %cmp_sent = arith.cmpi slt, %num_tokens_sent, %max_tokens_to_send : i32
            cal.predicate_result %cmp_sent : i1
        }
        // -- get the current state variable
        %one_i32 = arith.constant 1 : i32
        %tokens_sent = cal.get(%num_tokens_sent_state: !cal.state_ref<i32>) : i32
        %tokens_sent_plus_one = arith.addi %tokens_sent, %one_i32 : i32
        cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %tokens_sent_plus_one: i32)

        // -- calculate the value to send out
        %one_hundred = arith.constant 100 : i32
        %actor_index_by_100 = arith.muli %actor_index, %one_hundred : i32
        %value_to_send = arith.addi %tokens_sent, %actor_index_by_100 : i32

        // -- send the token
        fifo.push(%out0: !fifo.input_port<i32>, %value_to_send: i32)
        fifo.print("Src %d, pushed token: %d\0A\00", %actor_index ,%value_to_send) : (i32, i32)

    }
}

cal.actor @sink()
    ports_in(%in0: !fifo.output_port<i32>)
{
    cal.action
    {
        %token = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        fifo.print("Popped Token: %d\0A\00", %token) : (i32)
    }
}

cal.actor @merge()
    ports_in(%in0: !fifo.output_port<i32>, %in1: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>)
{
    cal.action {
        %token = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        fifo.push(%out0: !fifo.input_port<i32>, %token: i32)
    }

    cal.action{
        %token = fifo.pop(%in1: !fifo.output_port<i32>) : i32
        fifo.push(%out0: !fifo.input_port<i32>, %token: i32)
    }
}


cal.network {
    %0 = arith.constant 10 : i32
    %1 = arith.constant 10 : i32
    %one = arith.constant 1 : i32
    %two = arith.constant 2 : i32

    %in0, %out0 = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %in1, %out1 = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %in2, %out2 = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>

    cal.create_instance @src "srcA" (%0, %one : i32, i32)
            ports_out(%in0 : !fifo.input_port<i32>)

    cal.create_instance @src "srcB" (%1, %two: i32, i32)
            ports_out(%in1 : !fifo.input_port<i32>)

    cal.create_instance @merge "merge" ()
            ports_in(%out0, %out1: !fifo.output_port<i32>, !fifo.output_port<i32>)
            ports_out(%in2: !fifo.input_port<i32>)

    cal.create_instance @sink "sink" ()
            ports_in(%out2 : !fifo.output_port<i32>)
}
