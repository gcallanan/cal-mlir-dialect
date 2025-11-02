// RUN: cal-opt -canonicalize --flatten-cal-networks %s | FileCheck %s

cal.actor @Prod()
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.actor @Cons()
  ports_in(%i: !fifo.output_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @ND3DInitSetConnect() {
  %i0 = arith.constant 0 : index
  %i1 = arith.constant 1 : index

  // Scalar handles
  %p000 = cal.instantiate @Prod instance("p000") : !cal.instance<@Prod>
  %p111 = cal.instantiate @Prod instance("p111") : !cal.instance<@Prod>
  %c000 = cal.instantiate @Cons instance("c000") : !cal.instance<@Cons>
  %c111 = cal.instantiate @Cons instance("c111") : !cal.instance<@Cons>

  // 3D arrays with shape [2,2,2]
  %parr0 = cal.instance.array.init : !cal.instance.array<@Prod, [2, 2, 2]>
  %parr1 = cal.instance.array.set %parr0[%i0, %i0, %i0], %p000 : !cal.instance.array<@Prod, [2, 2, 2]>, !cal.instance<@Prod> -> !cal.instance.array<@Prod, [2, 2, 2]>
  %parr2 = cal.instance.array.set %parr1[%i1, %i1, %i1], %p111 : !cal.instance.array<@Prod, [2, 2, 2]>, !cal.instance<@Prod> -> !cal.instance.array<@Prod, [2, 2, 2]>

  %carr0 = cal.instance.array.init : !cal.instance.array<@Cons, [2, 2, 2]>
  %carr1 = cal.instance.array.set %carr0[%i0, %i0, %i0], %c000 : !cal.instance.array<@Cons, [2, 2, 2]>, !cal.instance<@Cons> -> !cal.instance.array<@Cons, [2, 2, 2]>
  %carr2 = cal.instance.array.set %carr1[%i1, %i1, %i1], %c111 : !cal.instance.array<@Cons, [2, 2, 2]>, !cal.instance<@Cons> -> !cal.instance.array<@Cons, [2, 2, 2]>

  // Connect matching elements using 3D indices
  cal.connect %parr2[%i0,%i0,%i0] : !cal.instance.array<@Prod, [2, 2, 2]> "out" -> %carr2[%i0,%i0,%i0] : !cal.instance.array<@Cons, [2, 2, 2]> "in"
  cal.connect %parr2[%i1,%i1,%i1] : !cal.instance.array<@Prod, [2, 2, 2]> "out" -> %carr2[%i1,%i1,%i1] : !cal.instance.array<@Cons, [2, 2, 2]> "in"
}

// CHECK-DAG: cal.create_instance @Prod
// CHECK-DAG: cal.create_instance @Prod
// CHECK-DAG: cal.create_instance @Cons
// CHECK-DAG: cal.create_instance @Cons
