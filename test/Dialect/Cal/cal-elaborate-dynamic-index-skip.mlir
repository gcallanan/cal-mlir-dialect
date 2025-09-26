// RUN: cal-opt -pass-pipeline='builtin.module(canonicalize,flatten-cal-networks{allow-dynamic-indices})' %s 2>&1 | FileCheck %s

cal.actor @Prod()
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %one = arith.constant 1 : i32
    %cap = fifo.space(%o: !fifo.input_port<i32>) : index
    %z = arith.constant 0 : index
    %cmp = arith.cmpi sgt, %cap, %z : index
    scf.if %cmp { fifo.push(%o: !fifo.input_port<i32>, %one: i32) }
    cal.action_done %cmp : i1
  }
}

cal.actor @Cons()
    ports_in(%i: !fifo.output_port<i32>) {
  cal.execution_body {
    %n = fifo.size(%i: !fifo.output_port<i32>) : index
    %z = arith.constant 0 : index
    %cmp = arith.cmpi sgt, %n, %z : index
    scf.if %cmp { %t = fifo.pop(%i: !fifo.output_port<i32>) : i32
                 fifo.print("Cons got %d\0A\00", %t) : (i32) }
    cal.action_done %cmp : i1
  }
}

cal.network @Dyn(%idx: index) {
  %prods = cal.instantiate_array @Prod count(2) : !cal.instance.array<@Prod, 2>
  %cons  = cal.instantiate_array @Cons count(2) : !cal.instance.array<@Cons, 2>

  cal.connect %prods[%idx] : !cal.instance.array<@Prod, 2> "out" -> %cons[%idx] : !cal.instance.array<@Cons, 2> "in"
}

// CHECK: skipping dynamic index during elaboration
// The network should be preserved with symbolic operations intact when dynamic indices are present
// CHECK: cal.actor @Prod
// CHECK: cal.actor @Cons
// CHECK: cal.network @Dyn
// CHECK-SAME: %arg0: index
// CHECK: cal.instantiate_array @Prod count(2) : !cal.instance.array<@Prod, 2>
// CHECK: cal.instantiate_array @Cons count(2) : !cal.instance.array<@Cons, 2>
// CHECK: cal.connect {{.*}} : !cal.instance.array<@Prod, 2> "out" -> {{.*}} : !cal.instance.array<@Cons, 2> "in"
