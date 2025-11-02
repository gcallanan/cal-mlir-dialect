// ND instance array construction and connection using cal.instance.array.init/set
// You can elaborate with:
//   cal-opt -canonicalize --flatten-cal-networks examples/symbolic/nd_array.mlir

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

cal.network @NDArrayNet() {
  %i0 = arith.constant 0 : index
  %i1 = arith.constant 1 : index

  // Create two scalar producer handles
  %p00 = cal.instantiate @Prod instance("p00") : !cal.instance<@Prod>
  %p11 = cal.instantiate @Prod instance("p11") : !cal.instance<@Prod>

  // Build a 2x2 producer array and set two elements
  %parr = cal.instance.array.init : !cal.instance.array.nd<@Prod, [2, 2]>
  %parr1 = cal.instance.array.set %parr[%i0, %i0], %p00 : !cal.instance.array.nd<@Prod, [2, 2]>, !cal.instance<@Prod> -> !cal.instance.array.nd<@Prod, [2, 2]>
  %parr2 = cal.instance.array.set %parr1[%i1, %i1], %p11 : !cal.instance.array.nd<@Prod, [2, 2]>, !cal.instance<@Prod> -> !cal.instance.array.nd<@Prod, [2, 2]>

  // Create two scalar consumer handles and a 2x2 consumer array populated similarly
  %c00 = cal.instantiate @Cons instance("c00") : !cal.instance<@Cons>
  %c11 = cal.instantiate @Cons instance("c11") : !cal.instance<@Cons>
  %carr = cal.instance.array.init : !cal.instance.array.nd<@Cons, [2, 2]>
  %carr1 = cal.instance.array.set %carr[%i0, %i0], %c00 : !cal.instance.array.nd<@Cons, [2, 2]>, !cal.instance<@Cons> -> !cal.instance.array.nd<@Cons, [2, 2]>
  %carr2 = cal.instance.array.set %carr1[%i1, %i1], %c11 : !cal.instance.array.nd<@Cons, [2, 2]>, !cal.instance<@Cons> -> !cal.instance.array.nd<@Cons, [2, 2]>

  // ND connects with constant indices; canonicalize lowers to instance_at + connect
  cal.connect %parr2[%i0, %i0] : !cal.instance.array.nd<@Prod, [2, 2]> "out" -> %carr2[%i0, %i0] : !cal.instance.array.nd<@Cons, [2, 2]> "in"
  cal.connect %parr2[%i1, %i1] : !cal.instance.array.nd<@Prod, [2, 2]> "out" -> %carr2[%i1, %i1] : !cal.instance.array.nd<@Cons, [2, 2]> "in"
}
