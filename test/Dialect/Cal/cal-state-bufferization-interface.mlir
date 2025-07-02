// RUN: cal-opt %s --one-shot-bufferize | FileCheck %s

%num_tokens_sent_state = cal.create_state_var<i32> : !cal.state_ref<i32>
%accumulator = cal.create_state_var<tensor<2x2xf64>> : !cal.state_ref<tensor<2x2xf64>>
// CHECK: %1 = cal.create_state_var<memref<2x2xf64>> : !cal.state_ref<memref<2x2xf64>>
%tensor = cal.get(%accumulator: !cal.state_ref<tensor<2x2xf64>>) : tensor<2x2xf64>
// CHECK: %2 = cal.get(%1 : !cal.state_ref<memref<2x2xf64>>) : memref<2x2xf64>
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
%tensor0 = tensor.from_elements %c0_f64, %c1_f64, %c2_f64, %c3_f64 : tensor<2x2xf64>

// CHECK: %alloc = memref.alloc() {alignment = 64 : i64} : memref<2x2xf64>
// CHECK: memref.store %cst, %alloc[%c0_3, %c0_3] : memref<2x2xf64>
// CHECK: memref.store %cst_0, %alloc[%c0_3, %c1_4] : memref<2x2xf64>
// CHECK: memref.store %cst_1, %alloc[%c1_4, %c0_3] : memref<2x2xf64>
// CHECK: memref.store %cst_2, %alloc[%c1_4, %c1_4] : memref<2x2xf64>

cal.set(%accumulator: !cal.state_ref<tensor<2x2xf64>>, %tensor0: tensor<2x2xf64>)
// CHECK: cal.set(%1 : !cal.state_ref<memref<2x2xf64>>, %alloc : memref<2x2xf64>)
scf.for %i = %c0_index to %c2_index step %c1_index {
    scf.for %j = %c0_index to %c2_index step %c1_index {
        // CHECK: %5 = memref.load %alloc[%arg0, %arg1] : memref<2x2xf64>
        %elem = tensor.extract %tensor0[%i, %j] : tensor<2x2xf64>
    }
}


%output = tensor.empty() : tensor<2x2xf64>
%tensor_mul = linalg.matmul ins(%tensor0, %tensor0 : tensor<2x2xf64>, tensor<2x2xf64>) 
                outs(%output : tensor<2x2xf64>) -> tensor<2x2xf64>


%one_i32 = arith.constant 1 : i32
%tokens_sent = cal.get(%num_tokens_sent_state: !cal.state_ref<i32>) : i32
%tokens_sent_plus_one = arith.addi %tokens_sent, %one_i32 : i32
cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %tokens_sent_plus_one: i32)