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

func.func @cal_types(%arg0: !cal.state_ref<i32>) {
    // CHECK: func.func @cal_types(%arg0: memref<1xi32>)
    return
}

func.call @cal_types(%ref0) : (!cal.state_ref<i32>) -> ()
// CHECK: func.call @cal_types(%alloc) : (memref<1xi32>) -> ()

cal.actor @simple(%ref : !cal.state_ref<i32>)
{
}
// CHECK: cal.actor @simple(%arg0: memref<1xi32>)

cal.network {
    %ref1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.create_instance @simple "actor1" (%ref1 : !cal.state_ref<i32>)
    // CHECK: cal.create_instance @simple "actor1" (%alloc_1 : memref<1xi32>)
}
