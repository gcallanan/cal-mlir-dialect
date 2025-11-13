// RUN: cal-opt %s -network-elements-elab --split-input-file | FileCheck %s

// 2-D array unrolling via nested loops. Actor with ports to allow connections.
cal.actor @A()
    ports_in(%in: !fifo.output_port<i32>)
    ports_out(%out: !fifo.input_port<i32>)
{}

cal.network @Build2D() {
  %N = arith.constant 2 : index
  %M = arith.constant 2 : index
  %init = cal.instance.array.init(%N, %M : index, index) : !cal.instance.array<@A, [?,?]>
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %arr2d = scf.for %i = %c0 to %N step %c1 iter_args(%a = %init) -> !cal.instance.array<@A, [?,?]> {
    %row = scf.for %j = %c0 to %M step %c1 iter_args(%r = %a) -> !cal.instance.array<@A, [?,?]> {
      %h = cal.instantiate @A : !cal.instance<@A>
      %r2 = cal.instance.array.set %r[%i, %j], %h : !cal.instance.array<@A, [?,?]>, !cal.instance<@A> -> !cal.instance.array<@A, [?,?]>
      scf.yield %r2 : !cal.instance.array<@A, [?,?]>
    }
    scf.yield %row : !cal.instance.array<@A, [?,?]>
  }
  // Extract four elements and connect them in a small pattern
  %a00 = cal.instance_at %arr2d[%c0, %c0] : !cal.instance.array<@A, [?,?]> -> !cal.instance<@A>
  %a01 = cal.instance_at %arr2d[%c0, %c1] : !cal.instance.array<@A, [?,?]> -> !cal.instance<@A>
  %a10 = cal.instance_at %arr2d[%c1, %c0] : !cal.instance.array<@A, [?,?]> -> !cal.instance<@A>
  %a11 = cal.instance_at %arr2d[%c1, %c1] : !cal.instance.array<@A, [?,?]> -> !cal.instance<@A>
  cal.connect %a00 : !cal.instance<@A> "out" -> %a01 : !cal.instance<@A> "in"
  cal.connect %a00 : !cal.instance<@A> "out" -> %a10 : !cal.instance<@A> "in"
  cal.connect %a01 : !cal.instance<@A> "out" -> %a11 : !cal.instance<@A> "in"
}

// CHECK: cal.network @Build2D()
// CHECK-NOT: scf.for
// CHECK-COUNT-4: cal.instantiate @A
// CHECK-COUNT-4: cal.instance_at
// CHECK-COUNT-3: cal.connect
