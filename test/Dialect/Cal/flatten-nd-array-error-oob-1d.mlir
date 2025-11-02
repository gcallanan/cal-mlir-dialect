// RUN: not cal-opt -canonicalize --flatten-cal-networks %s 2>&1 | FileCheck %s

cal.actor @A()
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @ErrOOB1D() {
  %c2 = arith.constant 2 : index
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %arr = cal.instantiate_array @A count(2) : !cal.instance.array<@A, [2]>
  // OOB: valid indices are 0,1
  cal.connect %out0 : !fifo.output_port<i32> "in" -> %arr[%c2] : !cal.instance.array<@A, [2]> "in"
}

// CHECK: error: 'cal.instance_at' op index out of bounds for instance array
