// RUN: cal-opt --verify-instance-array-fills %s 2>&1 | FileCheck %s

module {
  cal.actor @A() {
    cal.execution_body {
      %false = arith.constant false
      cal.action_done %false : i1
    }
  }

  cal.network @if_conv() {
  %arr = cal.instance.array.init : !cal.instance.array<@A, [2, 2]>
    %a0 = cal.instantiate @A : <@A>
    %a1 = cal.instantiate @A : <@A>

    %cond = arith.constant 0 : i1
    scf.if %cond {
      %c0 = arith.constant 0 : index
  %arr1 = cal.instance.array.set %arr[%c0, %c0], %a0 : !cal.instance.array<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array<@A, [2, 2]>
      scf.yield
    } else {
      %c1 = arith.constant 1 : index
  %arr2 = cal.instance.array.set %arr[%c1, %c1], %a1 : !cal.instance.array<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array<@A, [2, 2]>
      scf.yield
    }
  }
}

// CHECK-NOT: remark: instance array appears only partially filled
