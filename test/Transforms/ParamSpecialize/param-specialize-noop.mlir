// RUN: cal-opt --pass-pipeline="builtin.module(cal-param-specialize)" %s | FileCheck %s

// Non-constant parameter should not trigger specialization.
// We model non-const via a network parameter %k.

cal.actor @B(%p0: i32) {
  cal.execution_body {
    %sum = arith.addi %p0, %p0 : i32
    fifo.print("sum=%d\0A\00", %sum) : (i32)
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @TopNoop(%k: i32) {
  %h = cal.instantiate @B(%k : i32) : !cal.instance<@B>
}

// CHECK-NOT: cal.actor @B$spec_
// CHECK: cal.network @TopNoop(%k: i32)
// CHECK: %h = cal.instantiate @B(%k : i32) : !cal.instance<@B>
