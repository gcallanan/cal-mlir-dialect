// RUN: cal-opt --flatten-cal-networks %s | FileCheck %s

// Minimal structural Game of Life-style grid using ND instance arrays and SCF.
// This test focuses on elaboration: materializing cal.create_instance for each
// grid element and creating FIFOs for neighbor connections. The actor logic is
// trivial; we validate structure, not behavior.

// A simple cell actor with one input and one output port; it always reports
// that it fired to exercise the scheduler in later pipelines.
cal.actor @Cell()
  ports_in(%in: !fifo.output_port<i32>)
  ports_out(%out: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// Build a 2x2 grid of Cell instances via cal.instance.array.init/set, and wire
// a few neighbor connections using ND indices. This serves as a compact GoL-style
// structural pattern while keeping the IR small.
cal.network @GoL2x2() {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index

  // Network-side FIFOs to complete connectivity for all cell ports.
  %inA, %outA = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %inB, %outB = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %inC, %outC = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %inD, %outD = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>

  // Create a 2x2 instance array and place the 4 cells with stable names.
  %h00 = cal.instantiate @Cell instance("c00") : !cal.instance<@Cell>
  %h01 = cal.instantiate @Cell instance("c01") : !cal.instance<@Cell>
  %h10 = cal.instantiate @Cell instance("c10") : !cal.instance<@Cell>
  %h11 = cal.instantiate @Cell instance("c11") : !cal.instance<@Cell>

  %grid0 = cal.instance.array.init : !cal.instance.array<@Cell, [2, 2]>
  %grid1 = cal.instance.array.set %grid0[%c0, %c0], %h00 : !cal.instance.array<@Cell, [2, 2]>, !cal.instance<@Cell> -> !cal.instance.array<@Cell, [2, 2]>
  %grid2 = cal.instance.array.set %grid1[%c0, %c1], %h01 : !cal.instance.array<@Cell, [2, 2]>, !cal.instance<@Cell> -> !cal.instance.array<@Cell, [2, 2]>
  %grid3 = cal.instance.array.set %grid2[%c1, %c0], %h10 : !cal.instance.array<@Cell, [2, 2]>, !cal.instance<@Cell> -> !cal.instance.array<@Cell, [2, 2]>
  %grid4 = cal.instance.array.set %grid3[%c1, %c1], %h11 : !cal.instance.array<@Cell, [2, 2]>, !cal.instance<@Cell> -> !cal.instance.array<@Cell, [2, 2]>

  // A few neighbor connections (east and south edges) to exercise ND connect.
  // c00 -> c01
  cal.connect %grid4[%c0, %c0] : !cal.instance.array<@Cell, [2, 2]> "out" -> %grid4[%c0, %c1] : !cal.instance.array<@Cell, [2, 2]> "in"
  // c01 -> c11
  cal.connect %grid4[%c0, %c1] : !cal.instance.array<@Cell, [2, 2]> "out" -> %grid4[%c1, %c1] : !cal.instance.array<@Cell, [2, 2]> "in"

  // Complete connectivity with network ports for remaining unmatched ports.
  // Feed c00 input from a network output port.
  cal.connect %outA : !fifo.output_port<i32> "out" -> %grid4[%c0, %c0] : !cal.instance.array<@Cell, [2, 2]> "in"
  // Route c11 output to a network input port.
  cal.connect %grid4[%c1, %c1] : !cal.instance.array<@Cell, [2, 2]> "out" -> %inD : !fifo.input_port<i32> "in"
  // Feed c10 input and route its output to network to satisfy port coverage.
  cal.connect %outB : !fifo.output_port<i32> "out" -> %grid4[%c1, %c0] : !cal.instance.array<@Cell, [2, 2]> "in"
  cal.connect %grid4[%c1, %c0] : !cal.instance.array<@Cell, [2, 2]> "out" -> %inC : !fifo.input_port<i32> "in"
}

// Expect four concrete instances with the given names.
// CHECK-DAG: cal.create_instance @Cell "c00"
// CHECK-DAG: cal.create_instance @Cell "c01"
// CHECK-DAG: cal.create_instance @Cell "c10"
// CHECK-DAG: cal.create_instance @Cell "c11"

// Note: Additional fifo.create ops appear for the explicit network-side FIFOs above.
