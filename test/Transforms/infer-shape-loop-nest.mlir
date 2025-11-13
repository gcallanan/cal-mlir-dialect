// RUN: cal-opt %s -infer-cal-instance-array-shape | FileCheck %s

// Dynamic 2D instance array built by nested loops. Shape inference should
// produce a static array type !cal.instance.array<@A, [2, 2]>.

cal.actor @A() {
  cal.execution_body {
    %true = arith.constant 1 : i1
    cal.action_done %true : i1
  }
}

// CHECK-LABEL: func.func @build_nested()
cal.network @build_nested() {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c2 = arith.constant 2 : index
  %dyn = cal.instance.array.init : !cal.instance.array<@A, [?, ?]>
  %outer = scf.for %i = %c0 to %c2 step %c1 iter_args(%arg0 = %dyn) -> (!cal.instance.array<@A, [?, ?]>) {
    %inner = scf.for %j = %c0 to %c2 step %c1 iter_args(%arg1 = %arg0) -> (!cal.instance.array<@A, [?, ?]>) {
      %inst = cal.instantiate @A : !cal.instance<@A>
      %arr = cal.instance.array.set %arg1[%i, %j], %inst : !cal.instance.array<@A, [?, ?]>, !cal.instance<@A> -> !cal.instance.array<@A, [?, ?]>
      scf.yield %arr : !cal.instance.array<@A, [?, ?]>
    }
    scf.yield %inner : !cal.instance.array<@A, [?, ?]>
  }
}

// CHECK: cal.network @build_nested()
// CHECK: !cal.instance.array<@A, [2, 2]>
