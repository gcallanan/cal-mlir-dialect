// RUN: cal-opt --lower-cal-state-to-memref="which-alloc=GPU" %s | FileCheck %s
    
%c0_f64 = arith.constant 0.0 : f64
%c1_f64 = arith.constant 1.0 : f64
%c2_f64 = arith.constant 2.0 : f64
%c3_f64 = arith.constant 3.0 : f64

%accumulator = cal.create_state_var<tensor<2x2xf64>> : !cal.state_ref<tensor<2x2xf64>>
%accum_val = cal.get(%accumulator: !cal.state_ref<tensor<2x2xf64>>) : tensor<2x2xf64>
%fill = linalg.fill ins(%c0_f64 : f64) outs(%accum_val : tensor<2x2xf64>) -> tensor<2x2xf64>
cal.set(%accumulator: !cal.state_ref<tensor<2x2xf64>>, %fill: tensor<2x2xf64>)

// CHECK: %memref = gpu.alloc () : memref<2x2xf64>
// CHECK: %0 = bufferization.to_tensor %memref restrict : memref<2x2xf64> to tensor<2x2xf64>
// CHECK: %1 = linalg.fill ins(%cst : f64) outs(%0 : tensor<2x2xf64>) -> tensor<2x2xf64>
// CHECK: %2 = bufferization.to_memref %1 : tensor<2x2xf64> to memref<2x2xf64>
// CHECK: gpu.memcpy  %memref, %2 : memref<2x2xf64>, memref<2x2xf64>

%tensor0 = tensor.from_elements %c0_f64, %c1_f64, %c2_f64, %c3_f64 : tensor<2x2xf64>
%state_tensor_1 = cal.get(%accumulator: !cal.state_ref<tensor<2x2xf64>>) : tensor<2x2xf64>
%tensor_sum = linalg.add ins(%tensor0, %state_tensor_1 : tensor<2x2xf64>, tensor<2x2xf64>) 
                    outs(%state_tensor_1 : tensor<2x2xf64>) -> tensor<2x2xf64>
cal.set(%accumulator: !cal.state_ref<tensor<2x2xf64>>, %tensor_sum: tensor<2x2xf64>)

// CHECK: %from_elements = tensor.from_elements %cst, %cst_0, %cst_1, %cst_2 : tensor<2x2xf64>
// CHECK: %3 = bufferization.to_tensor %memref restrict : memref<2x2xf64> to tensor<2x2xf64>
// CHECK: %4 = linalg.add ins(%from_elements, %3 : tensor<2x2xf64>, tensor<2x2xf64>) outs(%3 : tensor<2x2xf64>) -> tensor<2x2xf64>
// CHECK: %5 = bufferization.to_memref %4 : tensor<2x2xf64> to memref<2x2xf64>
// CHECK: gpu.memcpy  %memref, %5 : memref<2x2xf64>, memref<2x2xf64>
