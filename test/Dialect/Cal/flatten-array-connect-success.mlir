// RUN: cal-opt -canonicalize --flatten-cal-networks %s | FileCheck %s

// Simple producers/consumers with matching port types
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

cal.network @ArrayConnectOK() {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index

  %prods = cal.instantiate_array @Prod count(2) : !cal.instance.array<@Prod, [2]>
  %cons  = cal.instantiate_array @Cons count(2) : !cal.instance.array<@Cons, [2]>

  // Element-wise connects with constant indices
  cal.connect %prods[%c0] : !cal.instance.array<@Prod, [2]> "out" -> %cons[%c0] : !cal.instance.array<@Cons, [2]> "in"
  cal.connect %prods[%c1] : !cal.instance.array<@Prod, [2]> "out" -> %cons[%c1] : !cal.instance.array<@Cons, [2]> "in"
}

// After elaboration, we expect materialized instance creations for both arrays
// CHECK-DAG: cal.create_instance @Prod
// CHECK-DAG: cal.create_instance @Prod
// CHECK-DAG: cal.create_instance @Cons
// CHECK-DAG: cal.create_instance @Cons
