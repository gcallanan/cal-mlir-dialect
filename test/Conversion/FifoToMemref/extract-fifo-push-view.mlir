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

// Relay case: the drain loop's source is not a local buffer at all but a
// `fifo.pop_bulk_view` result on a *different* port -- the shape that arises
// when an actor immediately forwards a bulk-acquired input region into
// another FIFO. The pop view (here written directly in the input, standing
// in for one the pop-extraction pass would have produced -- see the pipeline
// ordering note above) is not ours to redirect or erase, since it belongs to
// the other port; it is left exactly as the input has it (lowered to its own
// subview, like the freshly acquired push view). The loop is rewritten in
// place into a tight view-to-view copy and wrapped in a push view/commit --
// after lowering: two subviews (one per port) feeding a copy loop, with both
// ports' counters updated and no scalar fifo.push/fifo.pop remaining.

// CHECK-LABEL: cal.actor @relay
// CHECK-NOT: fifo.push
// CHECK-NOT: fifo.pop
// CHECK: memref.subview
// CHECK: memref.subview
// CHECK: scf.for
// CHECK: memref.load
// CHECK: memref.store
// CHECK: arith.addi
// CHECK: arith.remsi
// CHECK: arith.addi
// CHECK: arith.remsi

// SPSC-LABEL: cal.actor @relay
// SPSC-NOT: fifo.push
// SPSC-NOT: fifo.pop
// SPSC: arith.remsi
// SPSC: memref.subview
// SPSC: arith.remsi
// SPSC: memref.subview
// SPSC: scf.for
// SPSC: memref.load
// SPSC: memref.store
// SPSC: arith.addi
// SPSC: arith.addi
// SPSC-NOT: arith.remsi
cal.actor @relay ()
    ports_in(%in0: !fifo.output_port<i8>)
    ports_out (%out0: !fifo.input_port<i8>)
{
  cal.action "relay" priority=0 {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c64 = arith.constant 64 : index
    %view = fifo.pop_bulk_view(%in0 : !fifo.output_port<i8>, %c64) : memref<64xi8, strided<[1], offset: ?>>
    scf.for %i = %c0 to %c64 step %c1 {
      %v = memref.load %view[%i] : memref<64xi8, strided<[1], offset: ?>>
      fifo.push(%out0 : !fifo.input_port<i8>, %v : i8)
      scf.yield
    }
    fifo.pop_bulk_release(%in0 : !fifo.output_port<i8>, %c64)
  }
}

// Heap-allocation case: the drained buffer is a `memref.alloc`, not an
// alloca. Erasing it would orphan its paired `memref.dealloc` (which cannot
// run against a strided FIFO subview), so this must NOT take the
// redirect-and-erase path: the alloc/dealloc pair survives verbatim and the
// loop is rewritten in place into a view-backed copy.

// CHECK-LABEL: cal.actor @heap_drain
// CHECK: memref.alloc(
// CHECK-NOT: fifo.push
// CHECK: memref.subview
// CHECK: scf.for
// CHECK: memref.load %alloc
// CHECK: memref.store
// CHECK: arith.addi
// CHECK: arith.remsi
// CHECK: memref.dealloc

// SPSC-LABEL: cal.actor @heap_drain
// SPSC: memref.alloc(
// SPSC-NOT: fifo.push
// SPSC: arith.remsi
// SPSC: memref.subview
// SPSC: scf.for
// SPSC: memref.load %alloc
// SPSC: memref.store
// SPSC: arith.addi
// SPSC-NOT: arith.remsi
// SPSC: memref.dealloc
cal.actor @heap_drain ()
    ports_in ()
    ports_out (%out0: !fifo.input_port<i32>)
{
  cal.action "fill_and_send" priority=0 {
    %alloc = memref.alloc() : memref<4xi32>
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c4 = arith.constant 4 : index
    %v0 = arith.constant 11 : i32
    memref.store %v0, %alloc[%c0] : memref<4xi32>
    scf.for %i = %c0 to %c4 step %c1 {
      %v = memref.load %alloc[%i] : memref<4xi32>
      fifo.push(%out0 : !fifo.input_port<i32>, %v : i32)
      scf.yield
    }
    memref.dealloc %alloc : memref<4xi32>
  }
}
