// Example: ND instance array construction with scf.for
// Demonstrates 2x3 grid of @A instances using init/set + nested loops.
// Try:
//   cal-opt --verify-instance-array-fills examples/instance_for/nd_grid.mlir

module {
  cal.actor @A() {
    cal.execution_body {
      %false = arith.constant false
      cal.action_done %false : i1
    }
  }

  cal.network @grid2x3() {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index
    %c3 = arith.constant 3 : index

    %arr0 = cal.instance.array.init : !cal.instance.array.nd<@A, [2, 3]>

    %arr1 = scf.for %i = %c0 to %c2 step %c1 iter_args(%ai = %arr0)
             -> !cal.instance.array.nd<@A, [2, 3]> {
      %arr2 = scf.for %j = %c0 to %c3 step %c1 iter_args(%aj = %ai)
               -> !cal.instance.array.nd<@A, [2, 3]> {
        %h = cal.instantiate @A : <@A>
        %aj2 = cal.instance.array.set %aj[%i, %j], %h
          : !cal.instance.array.nd<@A, [2, 3]>, !cal.instance<@A>
            -> !cal.instance.array.nd<@A, [2, 3]>
        scf.yield %aj2 : !cal.instance.array.nd<@A, [2, 3]>
      }
      scf.yield %arr2 : !cal.instance.array.nd<@A, [2, 3]>
    }

  // Note: cal.instance_at currently supports 1D arrays; omit extraction for ND example.
  }
}
