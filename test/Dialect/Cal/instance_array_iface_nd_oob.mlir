// RUN: not cal-opt --verify-instance-array-fills %s 2>&1 | FileCheck %s

module {
  // Define an interface and a conforming actor
  cal.interface @IF
  cal.actor @A() {
    cal.execution_body {
      %false = arith.constant false
      cal.action_done %false : i1
    }
  }
  cal.implements @IF for @A

  cal.network @iface_oob() {
    %a = cal.instantiate @A : <@A>
    %ia = cal.instance.cast %a : !cal.instance<@A> -> !cal.instance.iface<@IF>

  %arr = cal.instance.array.init : !cal.instance.array.iface<@IF, [2, 2]>

    %c2 = arith.constant 2 : index
    %c0 = arith.constant 0 : index
    // OOB on dim 0
  %arr1 = cal.instance.array.set %arr[%c2, %c0], %ia : !cal.instance.array.iface<@IF, [2, 2]>, !cal.instance.iface<@IF> -> !cal.instance.array.iface<@IF, [2, 2]>
  }
}

// CHECK: error: index 2 out of bounds for dimension 0 of extent 2
