// RUN: cal-opt --lower-cal-to-llvm %s | mlir-runner --entry-point-result=i32 | FileCheck %s

//CHECK: src: Sending Tensor
//CHECK: [1] [1] 
//CHECK: [1] [1] 

//CHECK: src: Sending Tensor
//CHECK: [2] [2] 
//CHECK: [2] [2] 

//CHECK: src: Sending Tensor
//CHECK: [3] [3] 
//CHECK: [3] [3] 

//CHECK: accumulator: Peeked Tensor at index 2
//CHECK: [3] [3] 
//CHECK: [3] [3] 

//CHECK: accumulator: Peeked Tensor at index 1
//CHECK: [3] [3] 
//CHECK: [3] [3] 

//CHECK: accumulator: Peeked Tensor at index 0
//CHECK: [3] [3] 
//CHECK: [3] [3] 


cal.actor @src(%max_tokens_to_send: i32)
    ports_out(%out0: !fifo.input_port<tensor<2x2xi32>>)
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
    %c0_index = arith.constant 0 : index
    %c1_index = arith.constant 1 : index
    %c2_index = arith.constant 2 : index

    cal.action
    {
        %peeked_tensor2 = fifo.peek(%in0: !fifo.output_port<tensor<2x2xi32>>, %c2_index: index) : tensor<2x2xi32>
        fifo.print("accumulator: Peeked Tensor at index 2\0A\00")
        scf.for %i = %c0_index to %c2_index step %c1_index {
            scf.for %j = %c0_index to %c2_index step %c1_index {
                %elem = tensor.extract %peeked_tensor2[%i, %j] : tensor<2x2xi32>
                fifo.print("[%d] \00", %elem) : (i32)
            }
            fifo.print("\0A\00")
        }
        fifo.print("\0A\00")

        %peeked_tensor1 = fifo.peek(%in0: !fifo.output_port<tensor<2x2xi32>>, %c2_index: index) : tensor<2x2xi32>
        fifo.print("accumulator: Peeked Tensor at index 1\0A\00")
        scf.for %i = %c0_index to %c2_index step %c1_index {
            scf.for %j = %c0_index to %c2_index step %c1_index {
                %elem = tensor.extract %peeked_tensor1[%i, %j] : tensor<2x2xi32>
                fifo.print("[%d] \00", %elem) : (i32)
            }
            fifo.print("\0A\00")
        }
        fifo.print("\0A\00")

        %peeked_tensor0 = fifo.peek(%in0: !fifo.output_port<tensor<2x2xi32>>, %c2_index: index) : tensor<2x2xi32>
        fifo.print("accumulator: Peeked Tensor at index 0\0A\00")
        scf.for %i = %c0_index to %c2_index step %c1_index {
            scf.for %j = %c0_index to %c2_index step %c1_index {
                %elem = tensor.extract %peeked_tensor0[%i, %j] : tensor<2x2xi32>
                fifo.print("[%d] \00", %elem) : (i32)
            }
            fifo.print("\0A\00")
        }
        fifo.print("\0A\00")


        %token_tensor0 = fifo.pop(%in0: !fifo.output_port<tensor<2x2xi32>>) : tensor<2x2xi32>
        %token_tensor1 = fifo.pop(%in0: !fifo.output_port<tensor<2x2xi32>>) : tensor<2x2xi32>
        %token_tensor2 = fifo.pop(%in0: !fifo.output_port<tensor<2x2xi32>>) : tensor<2x2xi32>
    }
}

cal.network @Top(){
    %num_tokens = arith.constant 3 : i32
    %in0, %out0 = fifo.create<tensor<2x2xi32>>(3) : !fifo.input_port<tensor<2x2xi32>>, !fifo.output_port<tensor<2x2xi32>>
    
    cal.create_instance @src "src" (%num_tokens : i32)
            ports_out(%in0 : !fifo.input_port<tensor<2x2xi32>>)

    cal.create_instance @accumulator "accumulator" ()
            ports_in(%out0 : !fifo.output_port<tensor<2x2xi32>>)
}