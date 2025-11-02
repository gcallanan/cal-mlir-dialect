// RUN: cal-opt --verify-instance-array-fills %s 2>&1 | FileCheck %s

module {
  cal.actor @A() {
    cal.execution_body {
      %false = arith.constant false
      cal.action_done %false : i1
    }
  }

  cal.network @partial() {
    %a0 = cal.instantiate @A : <@A>
    %a1 = cal.instantiate @A : <@A>
    %a2 = cal.instantiate @A : <@A>
  %arr0 = cal.instance.array.init : !cal.instance.array<@A, [2, 2]>
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    // Fill three of four elements
  %arr1 = cal.instance.array.set %arr0[%c0, %c0], %a0 : !cal.instance.array<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array<@A, [2, 2]>
  %arr2 = cal.instance.array.set %arr1[%c1, %c0], %a1 : !cal.instance.array<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array<@A, [2, 2]>
  %arr3 = cal.instance.array.set %arr2[%c0, %c1], %a2 : !cal.instance.array<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array<@A, [2, 2]>
  }
}

// CHECK: remark: {{.*}}instance array appears only partially filled in linear chain: assigned 3/4 constant index positions
