//RUN: cal-opt --lower-cal-to-llvm %s | \
//RUN: cal-translate --mlir-to-llvmir | \
//RUN: lli | FileCheck %s

// CHECK: Accumulated Tensor
// CHECK: [0.000000] [1.000000] 
// CHECK: [2.000000] [3.000000] 

// CHECK: Accumulated Tensor
// CHECK: [0.000000] [2.000000] 
// CHECK: [4.000000] [6.000000] 

// CHECK: Accumulated Tensor
// CHECK: [0.000000] [3.000000] 
// CHECK: [6.000000] [9.000000] 

cal.actor @simple()
{
    %c0_f64 = arith.constant 0.0 : f64
    %c1_f64 = arith.constant 1.0 : f64
    %c2_f64 = arith.constant 2.0 : f64
    %c3_f64 = arith.constant 3.0 : f64

    %num_tokens_sent_state = cal.create_state_var<i32> : !cal.state_ref<i32>
    %accumulator = cal.create_state_var<tensor<2x2xf64>> : !cal.state_ref<tensor<2x2xf64>>
    %accum_val = cal.get(%accumulator: !cal.state_ref<tensor<2x2xf64>>) : tensor<2x2xf64>
    %fill = linalg.fill ins(%c0_f64 : f64) outs(%accum_val : tensor<2x2xf64>) -> tensor<2x2xf64>
    cal.set(%accumulator: !cal.state_ref<tensor<2x2xf64>>, %fill: tensor<2x2xf64>)
    
    %c0_index = arith.constant 0 : index
    %c1_index = arith.constant 1 : index
    %c2_index = arith.constant 2 : index
    %c0 = arith.constant 0 : i32
    %max_tokens_to_send = arith.constant 3 : i32
    cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %c0: i32)

    cal.action
    {
        cal.predicate {
            %num_tokens_sent = cal.get(%num_tokens_sent_state: !cal.state_ref<i32>) : i32
            %cmp_sent = arith.cmpi slt, %num_tokens_sent, %max_tokens_to_send : i32
            cal.predicate_result %cmp_sent : i1
        }
      
        // Generate a tensor
        fifo.print("Input Tensor\0A\00")
        %tensor0 = tensor.from_elements %c0_f64, %c1_f64, %c2_f64, %c3_f64 : tensor<2x2xf64>

        // Accumulate the tensor into the state
        %state_tensor_1 = cal.get(%accumulator: !cal.state_ref<tensor<2x2xf64>>) : tensor<2x2xf64>
        %tensor_sum = linalg.add ins(%tensor0, %state_tensor_1 : tensor<2x2xf64>, tensor<2x2xf64>) 
                           outs(%state_tensor_1 : tensor<2x2xf64>) -> tensor<2x2xf64>
        cal.set(%accumulator: !cal.state_ref<tensor<2x2xf64>>, %tensor_sum: tensor<2x2xf64>)

        // Print the accumulated tensor
        fifo.print("Accumulated Tensor\0A\00")
        %state_tensor_2 = cal.get(%accumulator: !cal.state_ref<tensor<2x2xf64>>) : tensor<2x2xf64>
        scf.for %i = %c0_index to %c2_index step %c1_index {
          scf.for %j = %c0_index to %c2_index step %c1_index {
            %elem = tensor.extract %state_tensor_2[%i, %j] : tensor<2x2xf64>
            fifo.print("[%f] \00", %elem) : (f64)
          }
          fifo.print("\0A\00")
        }
        fifo.print("\0A\00")

        %one_i32 = arith.constant 1 : i32
        %tokens_sent = cal.get(%num_tokens_sent_state: !cal.state_ref<i32>) : i32
        %tokens_sent_plus_one = arith.addi %tokens_sent, %one_i32 : i32
        cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %tokens_sent_plus_one: i32)
    }
}



cal.network{
    cal.create_instance @simple "actor1" ()
}