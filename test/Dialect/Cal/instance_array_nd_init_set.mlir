// RUN: cal-opt %s | FileCheck %s

cal.actor @A() {
  cal.execution_body {
    %f = arith.constant false
    cal.action_done %f : i1
  }
}

cal.network @arr2d() {
  // Create a 2x2 array of @A handles using the ND array type.
  %h0 = cal.instantiate @A : !cal.instance<@A>
  %h1 = cal.instantiate @A : !cal.instance<@A>
  %h2 = cal.instantiate @A : !cal.instance<@A>
  %h3 = cal.instantiate @A : !cal.instance<@A>

  %arr0 = cal.instance.array.init : !cal.instance.array.nd<@A, [2, 2]>
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index

  %arr1 = cal.instance.array.set %arr0[%c0, %c0], %h0 : !cal.instance.array.nd<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array.nd<@A, [2, 2]>
  %arr2 = cal.instance.array.set %arr1[%c1, %c0], %h1 : !cal.instance.array.nd<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array.nd<@A, [2, 2]>
  %arr3 = cal.instance.array.set %arr2[%c0, %c1], %h2 : !cal.instance.array.nd<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array.nd<@A, [2, 2]>
  %arr4 = cal.instance.array.set %arr3[%c1, %c1], %h3 : !cal.instance.array.nd<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array.nd<@A, [2, 2]>

  // CHECK: cal.instance.array.init : !cal.instance.array.nd<@A, [2, 2]>
  // CHECK: cal.instance.array.set %{{.*}}[%{{.*}}, %{{.*}}], %{{.*}} : !cal.instance.array.nd<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array.nd<@A, [2, 2]>
}
