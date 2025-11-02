// RUN: not cal-opt --verify-instance-array-fills %s 2>&1 | FileCheck %s

module {
  cal.actor @A() {
    cal.execution_body {
      %false = arith.constant false
      cal.action_done %false : i1
    }
  }

  cal.network @oob() {
    %a0 = cal.instantiate @A : <@A>
    %arr = cal.instance.array.init : !cal.instance.array.nd<@A, [2, 2]>
    %c2 = arith.constant 2 : index
    %c0 = arith.constant 0 : index
    // Out-of-bounds on dim 0 (extent 2), index 2
    %arr1 = cal.instance.array.set %arr[%c2, %c0], %a0 : !cal.instance.array.nd<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array.nd<@A, [2, 2]>
  }
}

// CHECK: error: index 2 out of bounds for dimension 0 of extent 2
