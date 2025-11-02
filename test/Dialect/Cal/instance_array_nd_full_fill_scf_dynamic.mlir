// RUN: cal-opt --verify-instance-array-fills %s 2>&1 | FileCheck %s

module {
  cal.actor @A() {
    cal.execution_body {
      %false = arith.constant false
      cal.action_done %false : i1
    }
  }

  cal.network @fill_with_scf() {
    %arr0 = cal.instance.array.init : !cal.instance.array.nd<@A, [2, 2]>

    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index

    %arr1 = scf.for %i = %c0 to %c2 step %c1 iter_args(%ai = %arr0)
             -> !cal.instance.array.nd<@A, [2, 2]> {
      %arr2 = scf.for %j = %c0 to %c2 step %c1 iter_args(%aj = %ai)
               -> !cal.instance.array.nd<@A, [2, 2]> {
        %h = cal.instantiate @A : <@A>
        %aj2 = cal.instance.array.set %aj[%i, %j], %h
          : !cal.instance.array.nd<@A, [2, 2]>, !cal.instance<@A>
            -> !cal.instance.array.nd<@A, [2, 2]>
        scf.yield %aj2 : !cal.instance.array.nd<@A, [2, 2]>
      }
      scf.yield %arr2 : !cal.instance.array.nd<@A, [2, 2]>
    }
  }
}

// CHECK-NOT: remark: instance array appears only partially filled
// CHECK-NOT: error: index
