// This code demonstrates the use of MLIR CAL and FIFO dialects with tensor types
// to implement a dataflow network that processes 2x2 tensors. The network includes:
//
// - 1 Source actor (src) that generates 2x2 tensors filled with incrementing values
// - 1 Accumulator actor that maintains a running sum of all received tensors
//
// The network structure:
// +------+
// | src  |
// +--+---+
//    |
//    v
// +--------+
// |accumula|
// |  tor   |
// +--------+
//
// Key features demonstrated:
// - Working with tensor types in FIFO operations (fifo.push/fifo.pop with tensors)
// - Using linalg operations for tensor arithmetic (linalg.fill, linalg.add)
// - Tensor state management with CAL state variables
// - Pretty-printing tensors using nested scf.for loops
//
// You can run this code with:
// cal-opt --lower-cal-to-llvm tensors.mlir | cal-translate --mlir-to-llvmir | lli
//
// Where:
//  cal-opt --lower-cal-to-llvm tensors.mlir - This command lowers the CAL dialect to the LLVM IR dialect.
//  cal-translate --mlir-to-llvmir - This command translates the MLIR to LLVM IR.
//  lli - This command executes the LLVM IR code using the LLVM interpreter.
//
// Alternatively "bash run.sh" from the terminal will execute these commands for you

// Source actor that generates and sends 2x2 tensors
// Parameters:
//   - max_tokens_to_send: Maximum number of tensors to generate
// Outputs:
//   - out0: FIFO output port for sending 2x2 integer tensors
cal.actor @src(%max_tokens_to_send: i32)
    ports_out(%out0: !fifo.input_port<tensor<2x2xi32>>)
{
    // Initialize state to track number of tensors sent
    %num_tokens_sent_state = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %c0: i32)

    cal.action "send"
    {
        // Predicate: only send tensors if we haven't reached the maximum
        cal.predicate {
            %num_tokens_sent = cal.get(%num_tokens_sent_state: !cal.state_ref<i32>) : i32
            %cmp_sent = arith.cmpi slt, %num_tokens_sent, %max_tokens_to_send : i32
            cal.predicate_result %cmp_sent : i1
        }

        // Update the state variable to track progress
        %one_i32 = arith.constant 1 : i32
        %tokens_sent = cal.get(%num_tokens_sent_state: !cal.state_ref<i32>) : i32
        %tokens_sent_plus_one = arith.addi %tokens_sent, %one_i32 : i32
        cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %tokens_sent_plus_one: i32)

        // Create a 2x2 tensor filled with the current count value
        %matrix = tensor.empty() : tensor<2x2xi32>
        %tensor_to_send = linalg.fill ins(%tokens_sent_plus_one : i32) outs(%matrix : tensor<2x2xi32>) -> tensor<2x2xi32>
        
        
        // Print the tensor contents for debugging (pretty-print as a matrix)
        fifo.print("src: Sending Tensor\0A\00")
        fifo.print_tensor(%tensor_to_send) : tensor<2x2xi32>
        fifo.print("\0A\00")
        
        // Send the tensor through the FIFO
        fifo.push(%out0: !fifo.input_port<tensor<2x2xi32>>, %tensor_to_send: tensor<2x2xi32>)
    }
}

// Accumulator actor that receives tensors and maintains a running sum
// Inputs:
//   - in0: FIFO input port for receiving 2x2 integer tensors
// State:
//   - accumulator: 2x2 tensor state variable to store running sum
cal.actor @accumulator()
    ports_in(%in0: !fifo.output_port<tensor<2x2xi32>>)
{
    // Initialize accumulator state with default values (4 in each cell)
    %c_init = arith.constant 0 : i32
    %accumulator = cal.create_state_var<tensor<2x2xi32>> : !cal.state_ref<tensor<2x2xi32>>
    %accum_val = cal.get(%accumulator: !cal.state_ref<tensor<2x2xi32>>) : tensor<2x2xi32>
    %fill = linalg.fill ins(%c_init : i32) outs(%accum_val : tensor<2x2xi32>) -> tensor<2x2xi32>
    cal.set(%accumulator: !cal.state_ref<tensor<2x2xi32>>, %fill: tensor<2x2xi32>)

    cal.action "rx_and_accumulate"
    {
        // Receive a tensor from the FIFO
        %token_tensor = fifo.pop(%in0: !fifo.output_port<tensor<2x2xi32>>) : tensor<2x2xi32>
        
        // Get current accumulator value and add the received tensor
        %state_tensor_1 = cal.get(%accumulator: !cal.state_ref<tensor<2x2xi32>>) : tensor<2x2xi32>
        %tensor_sum = linalg.add ins(%token_tensor, %state_tensor_1 : tensor<2x2xi32>, tensor<2x2xi32>) 
                            outs(%state_tensor_1 : tensor<2x2xi32>) -> tensor<2x2xi32>

        // Print the result tensor for debugging (pretty-print as a matrix)
        fifo.print("accumulator: Accumulated Result\0A\00")
        fifo.print_tensor(%tensor_sum) : tensor<2x2xi32>
        fifo.print("\0A\00")

        // Update the accumulator state with the new sum
        cal.set(%accumulator: !cal.state_ref<tensor<2x2xi32>>, %tensor_sum: tensor<2x2xi32>)
    }
}

// Network definition that connects the actors together
cal.network{
    // Number of tensors to generate and process
    %num_tokens = arith.constant 5 : i32

    // Create FIFO channel with buffer size 3 for tensor communication
    %in0, %out0 = fifo.create<tensor<2x2xi32>>(3) : !fifo.input_port<tensor<2x2xi32>>, !fifo.output_port<tensor<2x2xi32>>
    
    // Instantiate source actor with max_tokens_to_send parameter
    cal.create_instance @src "src" (%num_tokens : i32)
            ports_out(%in0 : !fifo.input_port<tensor<2x2xi32>>)

    // Instantiate accumulator actor to receive and process tensors
    cal.create_instance @accumulator "accumulator" ()
            ports_in(%out0 : !fifo.output_port<tensor<2x2xi32>>)
}