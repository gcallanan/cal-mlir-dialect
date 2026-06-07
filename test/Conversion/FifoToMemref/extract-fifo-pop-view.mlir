// RUN: cal-opt --extract-fifo-pop-view --lower-fifo-to-memref %s | FileCheck %s
// RUN: cal-opt --extract-fifo-pop-view --lower-fifo-to-memref="fifo-index-mode=spsc-lockfree" %s | FileCheck %s --check-prefix=SPSC

// Simple case: fill loop only, no write-back.
// After the passes: no alloca, no fill loop, subview + counter advance present.

// CHECK-LABEL: cal.actor @simple_fill
// CHECK-NOT: memref.alloca
// CHECK-NOT: fifo.pop
// CHECK: memref.subview
// CHECK: arith.addi
// CHECK: arith.remsi

// Note: in lock-free mode the slot is computed as readCount % capacity
// (remsi), then the subview is taken at that slot, then the monotonic
// counter is advanced by N with addi only (no wrapping remsi afterwards).
// (This note deliberately never writes the four-letter check prefix used
// below immediately followed by a colon -- FileCheck scans every line of
// this file for "<prefix>:" and would parse such text as a check directive.)
// SPSC-LABEL: cal.actor @simple_fill
// SPSC-NOT: memref.alloca
// SPSC-NOT: fifo.pop
// SPSC: arith.remsi
// SPSC: memref.subview
// SPSC: arith.addi
// SPSC-NOT: arith.remsi
cal.actor @simple_fill ()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out ()
{
  cal.action "fill" priority=0 {
    %alloca = memref.alloca() : memref<4xi32>
    %c0 = arith.constant 0 : index
    %c4 = arith.constant 4 : index
    %c1 = arith.constant 1 : index
    scf.for %i = %c0 to %c4 step %c1 {
      %val = fifo.pop(%in0 : !fifo.output_port<i32>) : i32
      memref.store %val, %alloca[%i] : memref<4xi32>
    }
  }
}

// Write-back case: fill loop followed by a compute loop that reads and writes
// back through the same buffer. The view is writable so both loops work.

// CHECK-LABEL: cal.actor @fill_and_process
// CHECK-NOT: memref.alloca
// CHECK-NOT: fifo.pop
// CHECK: memref.subview
// CHECK: arith.addi
// CHECK: arith.remsi
// CHECK: scf.for

// SPSC-LABEL: cal.actor @fill_and_process
// SPSC-NOT: memref.alloca
// SPSC-NOT: fifo.pop
// SPSC: arith.remsi
// SPSC: memref.subview
// SPSC: arith.addi
// SPSC-NOT: arith.remsi
// SPSC: scf.for
cal.actor @fill_and_process ()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out ()
{
  cal.action "receive_and_scale" priority=0 {
    %alloca = memref.alloca() : memref<4xi32>
    %c0 = arith.constant 0 : index
    %c4 = arith.constant 4 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : i32
    scf.for %i = %c0 to %c4 step %c1 {
      %val = fifo.pop(%in0 : !fifo.output_port<i32>) : i32
      memref.store %val, %alloca[%i] : memref<4xi32>
    }
    scf.for %i = %c0 to %c4 step %c1 {
      %v = memref.load %alloca[%i] : memref<4xi32>
      %scaled = arith.muli %v, %c2 : i32
      memref.store %scaled, %alloca[%i] : memref<4xi32>
    }
  }
}
