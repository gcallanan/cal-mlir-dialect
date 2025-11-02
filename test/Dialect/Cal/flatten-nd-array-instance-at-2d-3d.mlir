// RUN: cal-opt -canonicalize --flatten-cal-networks='allow-partial-connectivity' -split-input-file %s | FileCheck %s

// Common actor with one input and one output FIFO port
cal.actor @A()
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// -----

// 2D ND instance array: use explicit cal.instance_at with constant indices
// Re-declare actor @A in this split so it's in scope
cal.actor @A()
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @Net2D() {
  %i0 = arith.constant 0 : index
  %i1 = arith.constant 1 : index

  // Network ports
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  // Concrete handles to place into the ND array
  %h00 = cal.instantiate @A instance("a00") : !cal.instance<@A>
  %h11 = cal.instantiate @A instance("a11") : !cal.instance<@A>

  // Build 2D array and set two elements
  %arr0 = cal.instance.array.init : !cal.instance.array<@A, [2, 2]>
  %arr1 = cal.instance.array.set %arr0[%i0, %i0], %h00 : !cal.instance.array<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array<@A, [2, 2]>
  %arr2 = cal.instance.array.set %arr1[%i1, %i1], %h11 : !cal.instance.array<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array<@A, [2, 2]>

  // Explicitly extract elements using cal.instance_at (no connect sugar)
  %a00 = cal.instance_at %arr2[%i0, %i0] : !cal.instance.array<@A, [2, 2]> -> !cal.instance<@A>
  %a11 = cal.instance_at %arr2[%i1, %i1] : !cal.instance.array<@A, [2, 2]> -> !cal.instance<@A>

  // Wire network ports to extracted handles
  cal.connect %out0 : !fifo.output_port<i32> "in" -> %a00 : !cal.instance<@A> "in"
  cal.connect %a00 : !cal.instance<@A> "out" -> %in1 : !fifo.input_port<i32> "out"
}

// CHECK: cal.network @Net2D()
// CHECK: cal.create_instance @A

// -----

// 3D ND instance array: explicit cal.instance_at with constant 3-tuple indices
// Re-declare actor @A in this split so it's in scope
cal.actor @A()
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @Net3D() {
  %i0 = arith.constant 0 : index
  %i1 = arith.constant 1 : index

  // Network ports
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  // Concrete handles
  %h000 = cal.instantiate @A instance("a000") : !cal.instance<@A>
  %h111 = cal.instantiate @A instance("a111") : !cal.instance<@A>

  // Build 3D array and set two elements
  %arr0 = cal.instance.array.init : !cal.instance.array<@A, [2, 2, 2]>
  %arr1 = cal.instance.array.set %arr0[%i0, %i0, %i0], %h000 : !cal.instance.array<@A, [2, 2, 2]>, !cal.instance<@A> -> !cal.instance.array<@A, [2, 2, 2]>
  %arr2 = cal.instance.array.set %arr1[%i1, %i1, %i1], %h111 : !cal.instance.array<@A, [2, 2, 2]>, !cal.instance<@A> -> !cal.instance.array<@A, [2, 2, 2]>

  // Extract using explicit instance_at
  %a000 = cal.instance_at %arr2[%i0, %i0, %i0] : !cal.instance.array<@A, [2, 2, 2]> -> !cal.instance<@A>
  %a111 = cal.instance_at %arr2[%i1, %i1, %i1] : !cal.instance.array<@A, [2, 2, 2]> -> !cal.instance<@A>

  // Wire network ports
  cal.connect %out0 : !fifo.output_port<i32> "in" -> %a000 : !cal.instance<@A> "in"
  cal.connect %a111 : !cal.instance<@A> "out" -> %in1 : !fifo.input_port<i32> "out"
}

// CHECK: cal.network @Net3D()
