cal.actor @simple()
{
    %num_tokens_sent_state = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0_index = arith.constant 0 : index
    %c1_index = arith.constant 1 : index
    %c2_index = arith.constant 2 : index
    %c0 = arith.constant 0 : i32
    %c0_f64 = arith.constant 0.0 : f64
    %c1_f64 = arith.constant 1.0 : f64
    %c2_f64 = arith.constant 2.0 : f64
    %c3_f64 = arith.constant 3.0 : f64
    %max_tokens_to_send = arith.constant 1 : i32
    cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %c0: i32)

    cal.action
    {
        cal.predicate {
            %num_tokens_sent = cal.get(%num_tokens_sent_state: !cal.state_ref<i32>) : i32
            %cmp_sent = arith.cmpi slt, %num_tokens_sent, %max_tokens_to_send : i32
            cal.predicate_result %cmp_sent : i1
        }

      
        fifo.print("Input Tensor\0A\00")
        %tensor0 = tensor.from_elements %c0_f64, %c1_f64, %c2_f64, %c3_f64 : tensor<2x2xf64>
        scf.for %i = %c0_index to %c2_index step %c1_index {
          scf.for %j = %c0_index to %c2_index step %c1_index {
            %elem = tensor.extract %tensor0[%i, %j] : tensor<2x2xf64>
            fifo.print("[%f] \00", %elem) : (f64)
          }
          fifo.print("\0A\00")
        }
        fifo.print("\0A\00")


        %output = tensor.empty() : tensor<2x2xf64>
        %tensor_mul = linalg.matmul ins(%tensor0, %tensor0 : tensor<2x2xf64>, tensor<2x2xf64>) 
                        outs(%output : tensor<2x2xf64>) -> tensor<2x2xf64>

        // %tensor_mul = arith.mulf %tensor, %tensor : tensor<2x2xf64>
        fifo.print("Tensor * Tensor: \0A\00")
        scf.for %i = %c0_index to %c2_index step %c1_index {
          scf.for %j = %c0_index to %c2_index step %c1_index {
            %elem = tensor.extract %tensor_mul[%i, %j] : tensor<2x2xf64>
            fifo.print("[%f] \00", %elem) : (f64)
          }
          fifo.print("\0A\00")
        }

        %one_i32 = arith.constant 1 : i32
        %tokens_sent = cal.get(%num_tokens_sent_state: !cal.state_ref<i32>) : i32
        %tokens_sent_plus_one = arith.addi %tokens_sent, %one_i32 : i32
        cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %tokens_sent_plus_one: i32)
    }
}



cal.network{
    cal.create_instance @simple "actor1" ()
}