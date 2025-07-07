// RUN: cal-opt --lower-cal-state-to-memref --one-shot-bufferize --canonicalize %s | FileCheck %s
    
%c0_f64 = arith.constant 0.0 : f64
%c1_f64 = arith.constant 1.0 : f64
%c2_f64 = arith.constant 2.0 : f64
%c3_f64 = arith.constant 3.0 : f64

%accumulator = cal.create_state_var<memref<2x2xf64>> : !cal.state_ref<memref<2x2xf64>>
%accum_val = cal.get(%accumulator: !cal.state_ref<memref<2x2xf64>>) : memref<2x2xf64>
%fill = memref.alloc() {alignment = 64 : i64} : memref<2x2xf64>
%zero = arith.constant 0 : index
%one = arith.constant 1 : index

// Store 0.0 to each element of %accum_val
memref.store %c0_f64, %accum_val[%zero, %zero] : memref<2x2xf64>
memref.store %c1_f64, %accum_val[%zero, %one] : memref<2x2xf64>
memref.store %c2_f64, %accum_val[%one, %zero] : memref<2x2xf64>
memref.store %c3_f64, %accum_val[%one, %one] : memref<2x2xf64>
cal.set(%accumulator: !cal.state_ref<memref<2x2xf64>>, %accum_val: memref<2x2xf64>)

// CHECK: %alloc = memref.alloc() : memref<2x2xf64>
// CHECK: memref.store %cst, %alloc[%c0, %c0] : memref<2x2xf64>
// CHECK: memref.store %cst_0, %alloc[%c0, %c1] : memref<2x2xf64>
// CHECK: memref.store %cst_1, %alloc[%c1, %c0] : memref<2x2xf64>
// CHECK: memref.store %cst_2, %alloc[%c1, %c1] : memref<2x2xf64>

%state_tensor_1 = memref.alloc() {alignment = 64 : i64} : memref<2x2xf64>
memref.store %c0_f64, %state_tensor_1[%zero, %zero] : memref<2x2xf64>
memref.store %c1_f64, %state_tensor_1[%zero, %one] : memref<2x2xf64>
memref.store %c2_f64, %state_tensor_1[%one, %zero] : memref<2x2xf64>
memref.store %c3_f64, %state_tensor_1[%one, %one] : memref<2x2xf64>
cal.set(%accumulator: !cal.state_ref<memref<2x2xf64>>, %state_tensor_1: memref<2x2xf64>)

//CHECK: %alloc_3 = memref.alloc() {alignment = 64 : i64} : memref<2x2xf64>
//CHECK: memref.store %cst, %alloc_3[%c0, %c0] : memref<2x2xf64>
//CHECK: memref.store %cst_0, %alloc_3[%c0, %c1] : memref<2x2xf64>
//CHECK: memref.store %cst_1, %alloc_3[%c1, %c0] : memref<2x2xf64>
//CHECK: memref.store %cst_2, %alloc_3[%c1, %c1] : memref<2x2xf64>
//CHECK: memref.copy %alloc_3, %alloc : memref<2x2xf64> to memref<2x2xf64>
