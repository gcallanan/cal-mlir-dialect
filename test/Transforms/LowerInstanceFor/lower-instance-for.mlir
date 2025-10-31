// RUN: cal-opt -lower-instance-for %s | FileCheck %s

cal.network @N() {
  %c0 = arith.constant 0 : index
  %c4 = arith.constant 4 : index
  %c1 = arith.constant 1 : index

  %t = cal.instance_for(%c0, %c4, %c1) {
    %v = arith.constant 42 : i32
    cal.instance_yield %v : i32
  } : tuple<i32, i32, i32, i32>
}

// CHECK-LABEL: cal.network @N()
// CHECK: fifo.make_tuple(
// CHECK-SAME: -> tuple<i32, i32, i32, i32>
// CHECK-NOT: cal.instance_for

// -----

cal.network @ZeroTrip() {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index

  %t = cal.instance_for(%c0, %c0, %c1) {
    %v = arith.constant 7 : i32
    cal.instance_yield %v : i32
  } : tuple<>
}

// CHECK-LABEL: cal.network @ZeroTrip()
// CHECK: fifo.make_tuple()
// CHECK-SAME: -> tuple<>
// CHECK-NOT: cal.instance_for
