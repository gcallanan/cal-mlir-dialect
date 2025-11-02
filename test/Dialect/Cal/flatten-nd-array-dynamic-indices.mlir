// RUN: not cal-opt -canonicalize --flatten-cal-networks %s 2>&1 | FileCheck %s

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

cal.network @NDInitSetConnect_DynamicIndices() {
  %i0 = arith.constant 0 : index
  %i1 = arith.constant 1 : index

  // Scalar handles
  %p00 = cal.instantiate @Prod instance("p00") : !cal.instance<@Prod>
  %p11 = cal.instantiate @Prod instance("p11") : !cal.instance<@Prod>
  %c00 = cal.instantiate @Cons instance("c00") : !cal.instance<@Cons>
  %c11 = cal.instantiate @Cons instance("c11") : !cal.instance<@Cons>

  // 2D arrays with static shape [2,2]
  %parr0 = cal.instance.array.init : !cal.instance.array<@Prod, [2, 2]>
  %parr1 = cal.instance.array.set %parr0[%i0, %i0], %p00 : !cal.instance.array<@Prod, [2, 2]>, !cal.instance<@Prod> -> !cal.instance.array<@Prod, [2, 2]>
  %parr2 = cal.instance.array.set %parr1[%i1, %i1], %p11 : !cal.instance.array<@Prod, [2, 2]>, !cal.instance<@Prod> -> !cal.instance.array<@Prod, [2, 2]>

  %carr0 = cal.instance.array.init : !cal.instance.array<@Cons, [2, 2]>
  %carr1 = cal.instance.array.set %carr0[%i0, %i0], %c00 : !cal.instance.array<@Cons, [2, 2]>, !cal.instance<@Cons> -> !cal.instance.array<@Cons, [2, 2]>
  %carr2 = cal.instance.array.set %carr1[%i1, %i1], %c11 : !cal.instance.array<@Cons, [2, 2]>, !cal.instance<@Cons> -> !cal.instance.array<@Cons, [2, 2]>

  // Build a non-constant index via a data-dependent scf.if
  %in0, %out0 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %space = fifo.space(%in0 : !fifo.input_port<i32>) : index
  %zero = arith.constant 0 : index
  %cond = arith.cmpi sgt, %space, %zero : index
  %di = scf.if %cond -> (index) {
    scf.yield %i0 : index
  } else {
    scf.yield %i1 : index
  }

  // Connect using a dynamic index; elaboration should conservatively keep cal.connect
  cal.connect %parr2[%di,%i0] : !cal.instance.array<@Prod, [2, 2]> "out" -> %carr2[%di,%i0] : !cal.instance.array<@Cons, [2, 2]> "in"
}

// CHECK: dynamic ND index not supported during elaboration
