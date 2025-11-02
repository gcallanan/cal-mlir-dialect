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

cal.network @NDInitSetConnect() {
  %i0 = arith.constant 0 : index
  %i1 = arith.constant 1 : index

  // Scalar handles
  %p00 = cal.instantiate @Prod instance("p00") : !cal.instance<@Prod>
  %p11 = cal.instantiate @Prod instance("p11") : !cal.instance<@Prod>
  %c00 = cal.instantiate @Cons instance("c00") : !cal.instance<@Cons>
  %c11 = cal.instantiate @Cons instance("c11") : !cal.instance<@Cons>

  // Build arrays with ND-style two-index sets (2x2 shape)
  %parr0 = cal.instance.array.init : !cal.instance.array<@Prod, [2, 2]>
  %parr1 = cal.instance.array.set %parr0[%i0, %i0], %p00 : !cal.instance.array<@Prod, [2, 2]>, !cal.instance<@Prod> -> !cal.instance.array<@Prod, [2, 2]>
  %parr2 = cal.instance.array.set %parr1[%i1, %i1], %p11 : !cal.instance.array<@Prod, [2, 2]>, !cal.instance<@Prod> -> !cal.instance.array<@Prod, [2, 2]>

  %carr0 = cal.instance.array.init : !cal.instance.array<@Cons, [2, 2]>
  %carr1 = cal.instance.array.set %carr0[%i0, %i0], %c00 : !cal.instance.array<@Cons, [2, 2]>, !cal.instance<@Cons> -> !cal.instance.array<@Cons, [2, 2]>
  %carr2 = cal.instance.array.set %carr1[%i1, %i1], %c11 : !cal.instance.array<@Cons, [2, 2]>, !cal.instance<@Cons> -> !cal.instance.array<@Cons, [2, 2]>

  // Connect matching elements using ND indices (canonicalize inserts instance_at)
  cal.connect %parr2[%i0,%i0] : !cal.instance.array<@Prod, [2, 2]> "out" -> %carr2[%i0,%i0] : !cal.instance.array<@Cons, [2, 2]> "in"
  cal.connect %parr2[%i1,%i1] : !cal.instance.array<@Prod, [2, 2]> "out" -> %carr2[%i1,%i1] : !cal.instance.array<@Cons, [2, 2]> "in"
}

// After elaboration, we expect materialized instances for the two populated positions
// CHECK: cal.create_instance @Prod
// CHECK: cal.create_instance @Prod
// CHECK: cal.create_instance @Cons
// CHECK: cal.create_instance @Cons
