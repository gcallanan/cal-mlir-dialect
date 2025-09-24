// RUN: cal-opt %s | FileCheck %s

cal.actor @A() {
  cal.action {
  }
}

cal.network @N() {
  %arr = cal.instantiate_array @A count(2) : !cal.instance.array<@A, 2>
  %i0 = arith.constant 0 : index
  %h0 = cal.instance_at %arr[%i0] : !cal.instance.array<@A, 2>, index -> !cal.instance<@A>
  %i1 = arith.constant 1 : index
  %h1 = cal.instance_at %arr[%i1] : !cal.instance.array<@A, 2>, index -> !cal.instance<@A>
  // CHECK: cal.connect %[[A:.*]]\[[.*\]\] : !cal.instance.array<@A, 2> "out" -> %[[B:.*]]\[[.*\]\] : !cal.instance.array<@A, 2> "in"
  cal.connect %h0 : !cal.instance<@A> "out" -> %h1 : !cal.instance<@A> "in"
}
