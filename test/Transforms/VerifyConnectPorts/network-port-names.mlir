// RUN: cal-opt --composite-fixed-point-pass="pipeline=cal-structural-elaboration" %s | FileCheck %s --allow-empty

// A network declaring explicit port names; no connects needed here.
cal.network @N(%p0: i32)
  in_names ["in0"]
  out_names ["out0"]
  ports_in(%netIn: !fifo.output_port<i32>)
  ports_out(%netOut: !fifo.input_port<i32>) {
  %c3 = arith.constant 3 : i32
  // No structural ops; just verify parse/print
}

// CHECK-NOT: error: