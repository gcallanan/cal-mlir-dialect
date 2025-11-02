// RUN: cal-opt --verify-instance-array-fills %s 2>&1 | FileCheck %s

module {
  cal.actor @A() {
    cal.execution_body {
      %false = arith.constant false
      cal.action_done %false : i1
    }
  }

  cal.network @one_d_fill() {
    %c0 = arith.constant 0 : index

    %h = cal.instantiate @A : !cal.instance<@A>
    %arr0 = cal.instance.array.init : !cal.instance.array<@A, 1>
    %arr1 = cal.instance.array.set %arr0[%c0], %h : !cal.instance.array<@A, 1>, !cal.instance<@A> -> !cal.instance.array<@A, 1>

    // Access element to ensure type/usage is correct
    %e0 = cal.instance_at %arr1[%c0] : !cal.instance.array<@A, 1>, index -> !cal.instance<@A>
  }
}

// CHECK-NOT: remark: instance array appears only partially filled
