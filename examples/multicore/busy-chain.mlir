// Pipeline network with six actors connected in series:
// src -> forward0 -> ... -> forward3 -> sink
//
// The source generates M tokens, and the sink prints every N tokens.
//
// The forward actors are just busy actors that perform intensive computation to
// simulate load.

cal.actor @src(%max_tokens: i32)
    ports_out(%out0: !fifo.input_port<i32>)
{
    %tokens_sent_state = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%tokens_sent_state: !cal.state_ref<i32>, %c0: i32)

    cal.action {
        cal.predicate {
            %tokens_sent = cal.get(%tokens_sent_state: !cal.state_ref<i32>) : i32
            %can_send = arith.cmpi slt, %tokens_sent, %max_tokens : i32
            cal.predicate_result %can_send : i1
        }

        %c1 = arith.constant 1 : i32
        %tokens_sent = cal.get(%tokens_sent_state: !cal.state_ref<i32>) : i32
        %next_count = arith.addi %tokens_sent, %c1 : i32
        cal.set(%tokens_sent_state: !cal.state_ref<i32>, %next_count: i32)

        fifo.push(%out0: !fifo.input_port<i32>, %tokens_sent: i32)
    }
}

cal.actor @forward()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>)
{
    cal.action {
        // Pop token from input
        %token = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        
        // Perform intensive computation to simulate processing load
        %c1 = arith.constant 1 : index
        %c1000 = arith.constant 1000 : index
        %c0 = arith.constant 0 : index
        
        // Initialize accumulator with input token
        %c0_i32 = arith.constant 0 : i32
        %init_result = arith.addi %token, %c0_i32 : i32
        
        // Perform 1000 iterations of computation
        %final_result = scf.for %i = %c0 to %c1000 step %c1 iter_args(%acc = %init_result) -> (i32) {
            // Complex arithmetic operations
            %c1_i32 = arith.constant 1 : i32
            %c1000_i32 = arith.constant 1000 : i32
            
            // Convert index to i32 for computation
            %i_i32 = arith.index_cast %i : index to i32
            
            %mul1 = arith.muli %acc, %c1_i32 : i32
            %add1 = arith.addi %mul1, %i_i32 : i32
            %rem1 = arith.remsi %add1, %c1000_i32 : i32
            
            %mul2 = arith.muli %rem1, %c1_i32 : i32
            %add2 = arith.addi %mul2, %token : i32
            %rem2 = arith.remsi %add2, %c1000_i32 : i32
            
            scf.yield %rem2 : i32
        }

        %final_result_with_token = arith.addi %final_result, %token : i32
        
        // Output the processed token (original value preserved through computation)
        fifo.push(%out0: !fifo.input_port<i32>, %final_result_with_token: i32)
    }
}

cal.actor @sink(%print_threshold: i32)
    ports_in(%in0: !fifo.output_port<i32>)
{
    %tokens_received_state = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%tokens_received_state: !cal.state_ref<i32>, %c0: i32)

    cal.action {
        %token = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        
        %c1 = arith.constant 1 : i32
        %tokens_received = cal.get(%tokens_received_state: !cal.state_ref<i32>) : i32
        %next_count = arith.addi %tokens_received, %c1 : i32
        cal.set(%tokens_received_state: !cal.state_ref<i32>, %next_count: i32)

        // Print every N tokens (where N is the threshold parameter)
        %c0_i32 = arith.constant 0 : i32
        %rem = arith.remsi %next_count, %print_threshold : i32
        %should_print = arith.cmpi eq, %rem, %c0_i32 : i32
        
        scf.if %should_print {
            fifo.print("Sink received token #%d: %d\0A\00", %next_count, %token) : (i32, i32)
        }
    }
}

cal.network @Top() {
    %maxTokens = arith.constant 200000 : i32
    %printThreshold = arith.constant 10000 : i32

    // Create FIFO channels connecting the actors
    %in0, %out0 = fifo.create<i32>(10) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %in1, %out1 = fifo.create<i32>(10) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %in2, %out2 = fifo.create<i32>(10) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %in3, %out3 = fifo.create<i32>(10) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %in4, %out4 = fifo.create<i32>(10) : !fifo.input_port<i32>, !fifo.output_port<i32>

    fifo.print("Starting Pipeline Network\0A\00")

    // Instantiate the actors in order: src -> forward1 -> forward2 -> forward3 -> forward4 -> sink
    cal.create_instance @src "source" device_affinity="CPU0" (%maxTokens : i32)
        ports_out(%in0 : !fifo.input_port<i32>)

    cal.create_instance @forward "forwarder1" device_affinity="CPU1" ()
        ports_in(%out0 : !fifo.output_port<i32>)
        ports_out(%in1 : !fifo.input_port<i32>)

    cal.create_instance @forward "forwarder2" device_affinity="CPU2"()
        ports_in(%out1 : !fifo.output_port<i32>)
        ports_out(%in2 : !fifo.input_port<i32>)

    cal.create_instance @forward "forwarder3" device_affinity="CPU3"()
        ports_in(%out2 : !fifo.output_port<i32>)
        ports_out(%in3 : !fifo.input_port<i32>)

    cal.create_instance @forward "forwarder4" device_affinity="CPU4"()
        ports_in(%out3 : !fifo.output_port<i32>)
        ports_out(%in4 : !fifo.input_port<i32>)

    cal.create_instance @sink "sink" device_affinity="CPU0" (%printThreshold : i32)
        ports_in(%out4 : !fifo.output_port<i32>)

    fifo.print("Pipeline Network Setup Complete\0A\00")
}