// Check that the declared state_ref type for the CAL dialect is
// correctly parsed and printed.
// RUN: cal-opt %s | cal-opt | FileCheck %s
func.func @cal_types(%arg0: !cal.state_ref<i32>, %arg1: !cal.state_ref<ui17>) {
   return
}

// CHECK: func.func @cal_types(%arg0: !cal.state_ref<i32>, %arg1: !cal.state_ref<ui17>) {
