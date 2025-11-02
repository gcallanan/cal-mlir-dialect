// RUN: cal-opt --verify-instance-array-fills %s 2>&1 | FileCheck %s

module {
  cal.actor @A() {
    cal.execution_body {
      %false = arith.constant false
      cal.action_done %false : i1
    }
  }

  cal.network @full_fill() {
  %arr = cal.instance.array.init : !cal.instance.array<@A, [2, 2]>

    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index

    // Create four instances A00,A10,A01,A11
    %A00 = cal.instantiate @A : <@A>
    %A10 = cal.instantiate @A : <@A>
    %A01 = cal.instantiate @A : <@A>
    %A11 = cal.instantiate @A : <@A>

    // Simulate nested scf.for fill with constants (lit-friendly)
  %arr1 = cal.instance.array.set %arr[%c0, %c0], %A00 : !cal.instance.array<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array<@A, [2, 2]>
  %arr2 = cal.instance.array.set %arr1[%c1, %c0], %A10 : !cal.instance.array<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array<@A, [2, 2]>
  %arr3 = cal.instance.array.set %arr2[%c0, %c1], %A01 : !cal.instance.array<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array<@A, [2, 2]>
  %arr4 = cal.instance.array.set %arr3[%c1, %c1], %A11 : !cal.instance.array<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array<@A, [2, 2]>
  }
}

// CHECK-NOT: remark: instance array appears only partially filled
