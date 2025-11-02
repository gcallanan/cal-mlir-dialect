// RUN: not cal-opt -canonicalize --flatten-cal-networks %s 2>&1 | FileCheck %s

cal.actor @A()
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @ErrMissingND() {
  %i0 = arith.constant 0 : index
  %i1 = arith.constant 1 : index
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  // Build 2D ND array but set only [0,0]
  %arr0 = cal.instance.array.init : !cal.instance.array<@A, [2, 2]>
  %h00 = cal.instantiate @A instance("a00") : !cal.instance<@A>
  %arr1 = cal.instance.array.set %arr0[%i0, %i0], %h00 : !cal.instance.array<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array<@A, [2, 2]>

  // Attempt to connect to an element that wasn't set ([1,1])
  cal.connect %out0 : !fifo.output_port<i32> "in" -> %arr1[%i1, %i1] : !cal.instance.array<@A, [2, 2]> "in"
}

// CHECK: error: 'cal.connect' op unable to resolve destination to instance plan or network port
