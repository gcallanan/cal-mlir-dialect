// RUN: cal-opt --lower-cal-state-to-memref %s | FileCheck %s
%ref0 = cal.create_state_var<i32> : !cal.state_ref<i32>
// CHECK: %alloc = memref.alloc() : memref<1xi32>

%val = cal.get(%ref0 : !cal.state_ref<i32>) : i32
// CHECK: %c0 = arith.constant 0 : index
// CHECK: %0 = memref.load %alloc[%c0] : memref<1xi32>

%c32 = arith.constant 32 : i32
cal.set(%ref0 : !cal.state_ref<i32>, %c32 : i32)
// CHECK: %c0_0 = arith.constant 0 : index
// CHECK: memref.store %c32_i32, %alloc[%c0_0] : memref<1xi32>
