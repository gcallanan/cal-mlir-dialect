// RUN: cal-opt --extract-fifo-push-view --lower-fifo-to-memref %s | FileCheck %s
// RUN: cal-opt --extract-fifo-push-view --lower-fifo-to-memref="fifo-index-mode=spsc-lockfree" %s | FileCheck %s --check-prefix=SPSC

// Simple case: alloca filled by plain stores (arbitrary computation, no
// loop), then drained by a loop-of-pushes with a directly-typed index bound.
// After the passes: no alloca, no push, no drain loop, subview + counter
// commit present.
//
// Legacy mode computes the write slot as a direct index_cast of the write
// counter (no remsi up front) and wraps on commit (addi then remsi). SPSC
// lock-free computes the slot with remsi up front and commits with a
// monotonic addi only (no wrapping).

// CHECK-LABEL: cal.actor @simple_drain
// CHECK-NOT: memref.alloca
// CHECK-NOT: fifo.push
// CHECK-NOT: scf.for
// CHECK: memref.subview
// CHECK: arith.addi
// CHECK: arith.remsi

// SPSC-LABEL: cal.actor @simple_drain
// SPSC-NOT: memref.alloca
// SPSC-NOT: fifo.push
// SPSC-NOT: scf.for
// SPSC: arith.remsi
// SPSC: memref.subview
// SPSC: arith.addi
// SPSC-NOT: arith.remsi
cal.actor @simple_drain ()
    ports_in ()
    ports_out (%out0: !fifo.input_port<i32>)
{
  cal.action "fill_and_send" priority=0 {
    %alloca = memref.alloca() : memref<2xi32>
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index
    %v0 = arith.constant 11 : i32
    %v1 = arith.constant 22 : i32
    memref.store %v0, %alloca[%c0] : memref<2xi32>
    memref.store %v1, %alloca[%c1] : memref<2xi32>
    scf.for %i = %c0 to %c2 step %c1 {
      %v = memref.load %alloca[%i] : memref<2xi32>
      fifo.push(%out0 : !fifo.input_port<i32>, %v : i32)
      scf.yield
    }
  }
}

// Compute case: alloca filled by an scf.for that computes values from
// scratch (representing "many lines of computation", not just relayed pops),
// drained by a loop whose bound is expressed as an i32 constant cast to
// index -- the shape some frontends generate. One scf.for survives (the fill
// loop, now writing straight through the view); the drain loop is gone.

// CHECK-LABEL: cal.actor @compute_and_send
// CHECK-NOT: memref.alloca
// CHECK-NOT: fifo.push
// CHECK: memref.subview
// CHECK: scf.for
// CHECK: memref.store
// CHECK: arith.addi
// CHECK: arith.remsi

// SPSC-LABEL: cal.actor @compute_and_send
// SPSC-NOT: memref.alloca
// SPSC-NOT: fifo.push
// SPSC: arith.remsi
// SPSC: memref.subview
// SPSC: scf.for
// SPSC: memref.store
// SPSC: arith.addi
// SPSC-NOT: arith.remsi
cal.actor @compute_and_send ()
    ports_in ()
    ports_out (%out0: !fifo.input_port<i32>)
{
  cal.action "compute_and_send" priority=0 {
    %alloca = memref.alloca() : memref<8xi32>
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c8 = arith.constant 8 : index
    %base = arith.constant 100 : i32
    scf.for %i = %c0 to %c8 step %c1 {
      %iv_i32 = arith.index_cast %i : index to i32
      %val = arith.muli %base, %iv_i32 : i32
      memref.store %val, %alloca[%i] : memref<8xi32>
      scf.yield
    }
    %count_i32 = arith.constant 8 : i32
    %count = arith.index_cast %count_i32 : i32 to index
    scf.for %j = %c0 to %count step %c1 {
      %v = memref.load %alloca[%j] : memref<8xi32>
      fifo.push(%out0 : !fifo.input_port<i32>, %v : i32)
      scf.yield
    }
  }
}
