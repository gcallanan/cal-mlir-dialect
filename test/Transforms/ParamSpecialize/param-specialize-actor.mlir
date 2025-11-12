// RUN: cal-opt --pass-pipeline="builtin.module(cal-param-specialize)" %s | FileCheck %s

// This test checks that cal.instantiate of an actor with a constant parameter
// produces a specialized clone and retargets the instantiate to the clone, and
// that the constant is inlined inside the actor body.

cal.actor @A(%p0: i32) {
  cal.execution_body {
    %sum = arith.addi %p0, %p0 : i32
    // Use the value so it isn't DCE'd in this pass-only run.
    fifo.print("sum=%d\0A\00", %sum) : (i32)
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @Top() {
  %c42 = arith.constant 42 : i32
  %h = cal.instantiate @A(%c42 : i32) : !cal.instance<@A>
}

// CHECK: cal.actor @A$spec_[[HASH:[0-9]+]](%p0: i32)
// CHECK:   %cst = arith.constant 42 : i32
// CHECK:   arith.addi %cst, %cst : i32
// CHECK: cal.network @Top()
// CHECK:   %h = cal.instantiate @A$spec_[[HASH]]
