// RUN: cal-opt -canonicalize --flatten-cal-networks %s | FileCheck %s

// Two simple actors: a producer with one output, a consumer with one input.
cal.actor @Prod()
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %one = arith.constant 1 : i32
    %cap = fifo.space(%o: !fifo.input_port<i32>) : index
    %z = arith.constant 0 : index
    %ok = arith.cmpi sgt, %cap, %z : index
    scf.if %ok {
      fifo.push(%o: !fifo.input_port<i32>, %one: i32)
      scf.yield
    } else {
      scf.yield
    }
    cal.action_done %ok : i1
  }
}

cal.actor @Cons()
    ports_in(%i: !fifo.output_port<i32>) {
  cal.execution_body {
    %n = fifo.size(%i: !fifo.output_port<i32>) : index
    %z = arith.constant 0 : index
    %ok = arith.cmpi sgt, %n, %z : index
    scf.if %ok {
      %t = fifo.pop(%i: !fifo.output_port<i32>) : i32
      fifo.print("Cons got %d\0A\00", %t) : (i32)
      scf.yield
    } else {
      scf.yield
    }
    cal.action_done %ok : i1
  }
}

// Symbolic network uses instantiate_array and connect sugar.
cal.network @N() {
  %prods = cal.instantiate_array @Prod count(2) : !cal.instance.array<@Prod, 2>
  %cons  = cal.instantiate_array @Cons count(2) : !cal.instance.array<@Cons, 2>

  %i0 = arith.constant 0 : index
  %i1 = arith.constant 1 : index

  cal.connect %prods[%i0] : !cal.instance.array<@Prod, 2> "out" -> %cons[%i0] : !cal.instance.array<@Cons, 2> "in"
  cal.connect %prods[%i1] : !cal.instance.array<@Prod, 2> "out" -> %cons[%i1] : !cal.instance.array<@Cons, 2> "in"
}

// CHECK-LABEL: cal.network @N()
// After elaboration, symbolic ops are gone:
// CHECK-NOT: cal.instantiate
// CHECK-NOT: cal.instantiate_array
// CHECK-NOT: cal.instance_at
// CHECK-NOT: cal.connect

// Two FIFO channels should be created (depth may default to 1):
// CHECK-DAG: %[[IN0:.*]], %[[OUT0:.*]] = fifo.create<i32>
// CHECK-DAG: %[[IN1:.*]], %[[OUT1:.*]] = fifo.create<i32>

// Two concrete instances should exist, with ports wired to the created FIFOs.
// Four concrete instance port lines, order-insensitive:
// CHECK-DAG: ports_out (%[[IN0]] : !fifo.input_port<i32>)
// CHECK-DAG: ports_out (%[[IN1]] : !fifo.input_port<i32>)
// CHECK-DAG: ports_in (%[[OUT0]] : !fifo.output_port<i32>)
// CHECK-DAG: ports_in (%[[OUT1]] : !fifo.output_port<i32>)
