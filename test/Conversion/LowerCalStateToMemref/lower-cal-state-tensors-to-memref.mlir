// RUN: cal-opt --lower-cal-state-to-memref --one-shot-bufferize %s | FileCheck %s
    
%c0_f64 = arith.constant 0.0 : f64
%c1_f64 = arith.constant 1.0 : f64
%c2_f64 = arith.constant 2.0 : f64
%c3_f64 = arith.constant 3.0 : f64

%accumulator = cal.create_state_var<tensor<2x2xf64>> : !cal.state_ref<tensor<2x2xf64>>
%accum_val = cal.get(%accumulator: !cal.state_ref<tensor<2x2xf64>>) : tensor<2x2xf64>
%fill = linalg.fill ins(%c0_f64 : f64) outs(%accum_val : tensor<2x2xf64>) -> tensor<2x2xf64>
cal.set(%accumulator: !cal.state_ref<tensor<2x2xf64>>, %fill: tensor<2x2xf64>)

//CHECK: %alloc = memref.alloc() : memref<2x2xf64>
//CHECK: %alloc_3 = memref.alloc() {alignment = 64 : i64} : memref<2x2xf64>
//CHECK: linalg.fill ins(%cst : f64) outs(%alloc_3 : memref<2x2xf64>)
//CHECK: memref.copy %alloc_3, %alloc : memref<2x2xf64> to memref<2x2xf64>


%tensor0 = tensor.from_elements %c0_f64, %c1_f64, %c2_f64, %c3_f64 : tensor<2x2xf64>
%state_tensor_1 = cal.get(%accumulator: !cal.state_ref<tensor<2x2xf64>>) : tensor<2x2xf64>
%tensor_sum = linalg.add ins(%tensor0, %state_tensor_1 : tensor<2x2xf64>, tensor<2x2xf64>) 
                    outs(%state_tensor_1 : tensor<2x2xf64>) -> tensor<2x2xf64>
cal.set(%accumulator: !cal.state_ref<tensor<2x2xf64>>, %tensor_sum: tensor<2x2xf64>)

//CHECK: %alloc_4 = memref.alloc() {alignment = 64 : i64} : memref<2x2xf64>
//CHECK: memref.store %cst, %alloc_4[%c0, %c0] : memref<2x2xf64>
//CHECK: memref.store %cst_0, %alloc_4[%c0, %c1] : memref<2x2xf64>
//CHECK: memref.store %cst_1, %alloc_4[%c1, %c0] : memref<2x2xf64>
//CHECK: memref.store %cst_2, %alloc_4[%c1, %c1] : memref<2x2xf64>
//CHECK: linalg.add ins(%alloc_4, %alloc : memref<2x2xf64>, memref<2x2xf64>) outs(%alloc_5 : memref<2x2xf64>)
//CHECK memref.copy %alloc_5, %alloc : memref<2x2xf64> to memref<2x2xf64>