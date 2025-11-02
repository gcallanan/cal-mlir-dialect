// RUN: cal-opt -canonicalize --flatten-cal-networks %s | FileCheck %s

// Define a minimal interface and declare that Prod/Cons implement it.
cal.interface @IF

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

cal.implements @IF for @Prod
cal.implements @IF for @Cons

cal.network @IfaceNDConnect() {
  %i0 = arith.constant 0 : index
  %i1 = arith.constant 1 : index

  // Concrete handles
  %p00 = cal.instantiate @Prod instance("p00") : !cal.instance<@Prod>
  %p11 = cal.instantiate @Prod instance("p11") : !cal.instance<@Prod>
  %c00 = cal.instantiate @Cons instance("c00") : !cal.instance<@Cons>
  %c11 = cal.instantiate @Cons instance("c11") : !cal.instance<@Cons>

  // Cast to interface-typed handles
  %ip00 = cal.instance.cast %p00 : !cal.instance<@Prod> -> !cal.instance.iface<@IF>
  %ip11 = cal.instance.cast %p11 : !cal.instance<@Prod> -> !cal.instance.iface<@IF>
  %ic00 = cal.instance.cast %c00 : !cal.instance<@Cons> -> !cal.instance.iface<@IF>
  %ic11 = cal.instance.cast %c11 : !cal.instance<@Cons> -> !cal.instance.iface<@IF>

  // Build ND arrays of interface-typed handles
  %parr0 = cal.instance.array.init : !cal.instance.array.iface<@IF, [2, 2]>
  %parr1 = cal.instance.array.set %parr0[%i0, %i0], %ip00 : !cal.instance.array.iface<@IF, [2, 2]>, !cal.instance.iface<@IF> -> !cal.instance.array.iface<@IF, [2, 2]>
  %parr2 = cal.instance.array.set %parr1[%i1, %i1], %ip11 : !cal.instance.array.iface<@IF, [2, 2]>, !cal.instance.iface<@IF> -> !cal.instance.array.iface<@IF, [2, 2]>

  %carr0 = cal.instance.array.init : !cal.instance.array.iface<@IF, [2, 2]>
  %carr1 = cal.instance.array.set %carr0[%i0, %i0], %ic00 : !cal.instance.array.iface<@IF, [2, 2]>, !cal.instance.iface<@IF> -> !cal.instance.array.iface<@IF, [2, 2]>
  %carr2 = cal.instance.array.set %carr1[%i1, %i1], %ic11 : !cal.instance.array.iface<@IF, [2, 2]>, !cal.instance.iface<@IF> -> !cal.instance.array.iface<@IF, [2, 2]>

  // Connect matching elements using ND indices and interface arrays
  cal.connect %parr2[%i0,%i0] : !cal.instance.array.iface<@IF, [2, 2]> "out" -> %carr2[%i0,%i0] : !cal.instance.array.iface<@IF, [2, 2]> "in"
  cal.connect %parr2[%i1,%i1] : !cal.instance.array.iface<@IF, [2, 2]> "out" -> %carr2[%i1,%i1] : !cal.instance.array.iface<@IF, [2, 2]> "in"
}

// CHECK: cal.network @IfaceNDConnect()
// CHECK-DAG: cal.create_instance @Prod
// CHECK-DAG: cal.create_instance @Prod
// CHECK-DAG: cal.create_instance @Cons
// CHECK-DAG: cal.create_instance @Cons
