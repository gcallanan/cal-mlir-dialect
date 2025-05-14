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

cal.actor @src(%max_tokens_to_send: i32)
    ports_out(%out0: !fifo.input_port<i32>)
{
    %num_tokens_sent_state = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %c0: i32)

    cal.action
    {
        // Condition 1: Ensure that we have at least one free spot in the buffer
        %num_free_slots = fifo.space(%out0: !fifo.input_port<i32>) : index
        %one = arith.constant 1 : index
        %cmp_free = arith.cmpi sge, %num_free_slots, %one : index

        // Condition 2: Ensure that we have not sent the maximum number of tokens
        %num_tokens_sent = cal.get(%num_tokens_sent_state: !cal.state_ref<i32>) : i32
        %cmp_sent = arith.cmpi slt, %num_tokens_sent, %max_tokens_to_send : i32

        // Conjoin the conditions and if both are true, perform action
        %cond = arith.andi %cmp_free, %cmp_sent : i1
        %action_performed = scf.if %cond -> (i1) {
            // Perform the action: 
            // -- increment the sent count
            %one_i32 = arith.constant 1 : i32
            %tokens_sent = cal.get(%num_tokens_sent_state: !cal.state_ref<i32>) : i32
            %tokens_sent_plus_one = arith.addi %tokens_sent, %one_i32 : i32
            cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %tokens_sent_plus_one: i32)
            // -- send the token
            fifo.push(%out0: !fifo.input_port<i32>, %tokens_sent: i32)
            
            %true = arith.constant 1 : i1
            scf.yield %true : i1 
        } else {
            %false = arith.constant 0 : i1
            scf.yield %false : i1            
        }
        cal.action_done %action_performed : i1
    }
}

cal.actor @sink()
    ports_in(%in0: !fifo.output_port<i32>)
{
    cal.action
    {
        // Condition : Ensure that we have a token to consume
        %num_tokens_available = fifo.size(%in0: !fifo.output_port<i32>) : index
        %zero = arith.constant 0 : index
        %token_available = arith.cmpi sgt, %num_tokens_available, %zero : index

        // // Conjoin the conditions and if both are true, perform action
        // %cond = arith.andi %cmp_free, %cmp_sent : i1
        scf.if %token_available {
            // Perform the action: Retrieve and print the token
            %token = fifo.pop(%in0: !fifo.output_port<i32>) : i32
            fifo.print("Popped Token: %d\0A\00", %token) : (i32)
            scf.yield 
        } else {
            %false = arith.constant 0 : i1
            scf.yield
        }
        cal.action_done %token_available : i1
    }
}

cal.actor @merge()
    ports_in(%in0: !fifo.output_port<i32>, %in1: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>)
{
    cal.action
    {
        %zero = arith.constant 0 : index
        %one = arith.constant 1 : index

        // Check conditions for all actions
        %num_tokens_available_in0 = fifo.size(%in0: !fifo.output_port<i32>) : index
        %token_available_in0 = arith.cmpi sgt, %num_tokens_available_in0, %zero : index
        %num_tokens_available_in1 = fifo.size(%in1: !fifo.output_port<i32>) : index
        %token_available_in1 = arith.cmpi sgt, %num_tokens_available_in1, %zero : index

        %num_free_slots_out0 = fifo.space(%out0: !fifo.input_port<i32>) : index
        %free_slot_out0 = arith.cmpi sge, %num_free_slots_out0, %one : index

        %action0Fire = arith.andi %token_available_in0, %free_slot_out0 : i1 // determine if action0 can fire
        %action1Fire = arith.andi %token_available_in1, %free_slot_out0 : i1 // determine if action1 can fire

        // Execute actions if possible

        %action_performed = scf.if %action0Fire -> (i1) {    
            // Execute action 0: pop from in0 and push to out0
            %token = fifo.pop(%in0: !fifo.output_port<i32>) : i32
            fifo.push(%out0: !fifo.input_port<i32>, %token: i32)
            %true = arith.constant 1 : i1
            scf.yield %true : i1 
        } else {
            %action_performed_inner = scf.if %action1Fire -> (i1) {    
                // Execute action 1: pop from in1 and push to out1
                %token = fifo.pop(%in1: !fifo.output_port<i32>) : i32
                fifo.push(%out0: !fifo.input_port<i32>, %token: i32)
                %true = arith.constant 1 : i1
                scf.yield %true : i1 
            } else {
                // No actions can fire
                %false = arith.constant 0 : i1
                scf.yield %false : i1            
            }
            scf.yield %action_performed_inner : i1            
        }

        cal.action_done %action_performed : i1
    }
}