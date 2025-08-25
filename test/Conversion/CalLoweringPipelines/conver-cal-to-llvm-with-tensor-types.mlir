// RUN: cal-opt --lower-cal-to-llvm-with-static-schedule %s | mlir-runner --entry-point-result=void | FileCheck %s

//CHECK: src: Sending Tensor
//CHECK: [1] [1] 
//CHECK: [1] [1] 
//CHECK: accumulator: Received Tensor
//CHECK: [5] [5] 
//CHECK: [5] [5] 
//CHECK: src: Sending Tensor
//CHECK: [2] [2] 
//CHECK: [2] [2] 
//CHECK: accumulator: Received Tensor
//CHECK: [7] [7] 
//CHECK: [7] [7] 
//CHECK: src: Sending Tensor
//CHECK: [3] [3] 
//CHECK: [3] [3] 
//CHECK: accumulator: Received Tensor
//CHECK: [10] [10] 
//CHECK: [10] [10] 
//CHECK: src: Sending Tensor
//CHECK: [4] [4] 
//CHECK: [4] [4] 
//CHECK: accumulator: Received Tensor
//CHECK: [14] [14] 
//CHECK: [14] [14] 
//CHECK: src: Sending Tensor
//CHECK: [5] [5] 
//CHECK: [5] [5] 
//CHECK: accumulator: Received Tensor
//CHECK: [19] [19] 
//CHECK: [19] [19] 


cal.actor @src(%max_tokens_to_send: i32)
    ports_out(%out0: !fifo.input_port<tensor<2x2xi32>>)
{
    %num_tokens_sent_state = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %c0: i32)

    cal.action "tx"
    {
        cal.predicate {
            %num_tokens_sent = cal.get(%num_tokens_sent_state: !cal.state_ref<i32>) : i32
            %cmp_sent = arith.cmpi slt, %num_tokens_sent, %max_tokens_to_send : i32
            cal.predicate_result %cmp_sent : i1
        }

        // -- get and update the current state variable
        %one_i32 = arith.constant 1 : i32
        %tokens_sent = cal.get(%num_tokens_sent_state: !cal.state_ref<i32>) : i32
        %tokens_sent_plus_one = arith.addi %tokens_sent, %one_i32 : i32
        cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %tokens_sent_plus_one: i32)

        // -- create a tensor to send out
        %matrix = tensor.empty() : tensor<2x2xi32>
        %tensor_to_send = linalg.fill ins(%tokens_sent_plus_one : i32) outs(%matrix : tensor<2x2xi32>) -> tensor<2x2xi32>
        
        
        // Print tensor_to_send using scf.for loops and fifo.print
        %c0_index = arith.constant 0 : index
        %c1_index = arith.constant 1 : index
        %c2_index = arith.constant 2 : index
        fifo.print("src: Sending Tensor\0A\00")
        scf.for %i = %c0_index to %c2_index step %c1_index {
          scf.for %j = %c0_index to %c2_index step %c1_index {
            %elem = tensor.extract %tensor_to_send[%i, %j] : tensor<2x2xi32>
            fifo.print("[%d] \00", %elem) : (i32)
          }
          fifo.print("\0A\00")
        }
        fifo.print("\0A\00")
        
        fifo.push(%out0: !fifo.input_port<tensor<2x2xi32>>, %tensor_to_send: tensor<2x2xi32>)


    }
}

cal.actor @accumulator()
    ports_in(%in0: !fifo.output_port<tensor<2x2xi32>>)
{
    %c_init = arith.constant 4 : i32
    %accumulator = cal.create_state_var<tensor<2x2xi32>> : !cal.state_ref<tensor<2x2xi32>>
    %accum_val = cal.get(%accumulator: !cal.state_ref<tensor<2x2xi32>>) : tensor<2x2xi32>
    %fill = linalg.fill ins(%c_init : i32) outs(%accum_val : tensor<2x2xi32>) -> tensor<2x2xi32>
    cal.set(%accumulator: !cal.state_ref<tensor<2x2xi32>>, %fill: tensor<2x2xi32>)

    cal.action "rx"
    {
        %token_tensor = fifo.pop(%in0: !fifo.output_port<tensor<2x2xi32>>) : tensor<2x2xi32>
        
        %state_tensor_1 = cal.get(%accumulator: !cal.state_ref<tensor<2x2xi32>>) : tensor<2x2xi32>
        %tensor_sum = linalg.add ins(%token_tensor, %state_tensor_1 : tensor<2x2xi32>, tensor<2x2xi32>) 
                            outs(%state_tensor_1 : tensor<2x2xi32>) -> tensor<2x2xi32>

        %c0_index = arith.constant 0 : index
        %c1_index = arith.constant 1 : index
        %c2_index = arith.constant 2 : index
        fifo.print("accumulator: Received Tensor\0A\00")
        scf.for %i = %c0_index to %c2_index step %c1_index {
            scf.for %j = %c0_index to %c2_index step %c1_index {
                %elem = tensor.extract %tensor_sum[%i, %j] : tensor<2x2xi32>
                fifo.print("[%d] \00", %elem) : (i32)
            }
            fifo.print("\0A\00")
        }
        fifo.print("\0A\00")

        cal.set(%accumulator: !cal.state_ref<tensor<2x2xi32>>, %tensor_sum: tensor<2x2xi32>)
    }
}

cal.network{
    %num_tokens = arith.constant 5 : i32
    %in0, %out0 = fifo.create<tensor<2x2xi32>>(3) : !fifo.input_port<tensor<2x2xi32>>, !fifo.output_port<tensor<2x2xi32>>
    
    cal.create_instance @src "src" (%num_tokens : i32)
            ports_out(%in0 : !fifo.input_port<tensor<2x2xi32>>)

    cal.create_instance @accumulator "accumulator" ()
            ports_in(%out0 : !fifo.output_port<tensor<2x2xi32>>)
}