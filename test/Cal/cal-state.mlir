// RUN: cal-opt %s | cal-opt | FileCheck %s
%ref0 = cal.create_state_var<i32> : !cal.state_ref<i32>
// CHECK: %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
%ref1 = cal.create_state_var<i17> : !cal.state_ref<i17>
// CHECK: %1 = cal.create_state_var<i17> : !cal.state_ref<i17>

%val1 = cal.get(%ref0: !cal.state_ref<i32>) : i32
// CHECK: %2 = cal.get(%0 : !cal.state_ref<i32>) : i32
%val2 = cal.get(%ref1: !cal.state_ref<i17>) : i17
// CHECK: %3 = cal.get(%1 : !cal.state_ref<i17>) : i17


%c0 = arith.constant 0 : i32
%c1 = arith.constant 1 : i17
cal.set(%ref0: !cal.state_ref<i32>, %c0: i32)
// CHECK: cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
cal.set(%ref1: !cal.state_ref<i17>, %c1: i17)
// CHECK: cal.set(%1 : !cal.state_ref<i17>, %c1_i17 : i17)