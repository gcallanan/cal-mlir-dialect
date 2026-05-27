//===----------------------------------------------------------------------===//
// Async SPSC FIFO Example (Conceptual Lock-Free Version)
//
// This example demonstrates a single-producer single-consumer pattern using the
// CAL/FIFO dialect FIFO with the lowering option:
//   --lower-fifo-to-memref="fifo-index-mode=spsc-lockfree"
//
// IMPORTANT: The current lowering creates monotonically increasing counters
// (readCount, writeCount) but DOES NOT yet inject atomic acquire/release
// semantics on those counters. For true parallel execution (e.g., different
// OS threads) a follow-up pass must rewrite index loads/stores to atomic
// operations in the LLVM dialect.
//
// Structure:
//   - Create FIFO (capacity 16)
//   - Spawn producer async task: pushes 0..(N-1)
//   - Spawn consumer async task: pops N elements and prints them
//   - Await both tasks
//
// To run (illustrative pipeline):
//  cal-opt   --lower-fifo-to-memref='fifo-index-mode=spsc-lockfree' \
//             --decompose-fifo-tuples \
//             --fifo-memref-atomicize \
//             --async-to-async-runtime \
//             --async-runtime-ref-counting \
//             --async-runtime-ref-counting-opt \
//             --convert-async-to-llvm \
//             --lower-cal-to-llvm \
//             --cse --canonicalize \
//             async_execute.mlir \    
//  cal-translate --mlir-to-llvmir | lli

//===----------------------------------------------------------------------===//

module {
  func.func @main() {
    // Capacity and count
    %capacity = arith.constant 32 : i32
    %count    = arith.constant 64 : index

    // Create FIFO ports
    %in_port, %out_port = fifo.create<i32>(32) : !fifo.input_port<i32>, !fifo.output_port<i32>

    // Producer async task ---------------------------------------------------
    %producer = async.execute {
      %one_index    = arith.constant 1 : index
      %c0_index     = arith.constant 0 : index
      %zero_index   = arith.constant 0 : index
      // Producer polling loop with backpressure: only push when space > 0.
      %final_sent = scf.while (%sent_init = %c0_index) : (index) -> (index) {
        %not_done = arith.cmpi ne, %sent_init, %count : index
        scf.condition(%not_done) %sent_init : index
      } do {
      ^bb0(%sent: index):
        %space = fifo.space(%in_port : !fifo.input_port<i32>) : index
        %has_space = arith.cmpi sgt, %space, %zero_index : index
        %next = scf.if %has_space -> (index) {
          %i_val = arith.index_cast %sent : index to i32
          fifo.push(%in_port : !fifo.input_port<i32>, %i_val : i32)
          fifo.print("Producer pushed: %d\0A\00", %i_val) : (i32)
          %inc = arith.addi %sent, %one_index : index
          scf.yield %inc : index
        } else {
          // No space available, yield same counter (poll again next iteration)
          scf.yield %sent : index
        }
        scf.yield %next : index
      }
      // %final_sent == %count here.
      async.yield
    }

    // Consumer async task ---------------------------------------------------
    %consumer = async.execute {
      %one_index  = arith.constant 1 : index
      %c0_index   = arith.constant 0 : index
      %zero_index = arith.constant 0 : index

      // We only want to terminate (async.yield) after exactly %count elements
      // have been received. Implement a counting while loop:
      %final_consumed = scf.while (%consumed_init = %c0_index) : (index) -> (index) {
        %not_done = arith.cmpi ne, %consumed_init, %count : index
        scf.condition(%not_done) %consumed_init : index
      } do {
      ^bb0(%consumed_loop: index):
        // Poll once per outer iteration.
        %size = fifo.size(%out_port : !fifo.output_port<i32>) : index
        %has_data = arith.cmpi sgt, %size, %zero_index : index
        %next = scf.if %has_data -> (index) {
          %val = fifo.pop(%out_port : !fifo.output_port<i32>) : i32
          fifo.print("Consumer got: %d\0A\00", %val) : (i32)
          %inc = arith.addi %consumed_loop, %one_index : index
          scf.yield %inc : index
        } else {
          scf.yield %consumed_loop : index
        }
        scf.yield %next : index
      }
    

      // Only reaches here after exactly %count elements consumed.
      async.yield
    }

    // Await completion ------------------------------------------------------
    async.await %producer : !async.token
    async.await %consumer : !async.token

    return
  }
}
