// RUN: cal-opt -pass-pipeline='builtin.module(flatten-cal-networks{allow-partial-connectivity})' %s | FileCheck %s

cal.actor @P()
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body { %one = arith.constant 1 : i32
    %ok = arith.constant true
    scf.if %ok { fifo.push(%o: !fifo.input_port<i32>, %one: i32) }
    cal.action_done %ok : i1 }
}

cal.actor @Q()
    ports_in(%i: !fifo.output_port<i32>) {
  cal.execution_body { %ok = arith.constant false
    cal.action_done %ok : i1 }
}

cal.network @Top() {
  %p0 = cal.instantiate @P : !cal.instance<@P>
  %p1 = cal.instantiate @P : !cal.instance<@P>
  %q0 = cal.instantiate @Q : !cal.instance<@Q>
  %q1 = cal.instantiate @Q : !cal.instance<@Q>

  // Only connect one pair fully; leave the other pair unconnected.
  cal.connect %p0 : !cal.instance<@P> "out" -> %q0 : !cal.instance<@Q> "in"
}

// Only the fully connected pair should be materialized.
// First, the symbolic instances remain:
// CHECK: cal.instantiate @P
// CHECK: cal.instantiate @Q
// Then FIFO creation and materialized instances:
// CHECK: %[[IN:.*]], %[[OUT:.*]] = fifo.create<i32>
// CHECK: cal.create_instance @Q()
// CHECK-NEXT: ports_in (%[[OUT]] : !fifo.output_port<i32>)
// CHECK: cal.create_instance @P()
// CHECK-NEXT: ports_out (%[[IN]] : !fifo.input_port<i32>)
