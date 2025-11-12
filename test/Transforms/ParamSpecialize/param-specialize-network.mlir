// RUN: cal-opt --pass-pipeline="builtin.module(cal-param-specialize)" %s | FileCheck %s

// Network-level specialization: constant parameters to a network should clone
// the network symbol; cal.instantiate of actors inside should remain untouched.

cal.actor @Leaf(%p0: i32) {
  cal.execution_body {
    fifo.print("sum=%d\0A\00", %p0) : (i32)
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @N(%p0: i32, %p1: i32) {
  %h0 = cal.instantiate @Leaf(%p0 : i32) : !cal.instance<@Leaf>
  %h1 = cal.instantiate @Leaf(%p1 : i32) : !cal.instance<@Leaf>
}

cal.network @Root() {
  %c1 = arith.constant 1 : i32
  %c2 = arith.constant 2 : i32
  %hn = cal.instantiate @N(%c1, %c2 : i32, i32) : !cal.instance<@N>
}

// CHECK: cal.network @N$spec_[[NHASH:[0-9]+]](%p0: i32, %p1: i32)
// CHECK:   %c1 = arith.constant 1 : i32
// CHECK:   %c2 = arith.constant 2 : i32
// CHECK: cal.network @Root()
// CHECK:   %hn = cal.instantiate @N$spec_[[NHASH]]
