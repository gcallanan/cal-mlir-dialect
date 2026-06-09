// RUN: cal-opt --extract-fifo-pop-view --lower-fifo-to-memref %s | FileCheck %s
// RUN: cal-opt --extract-fifo-pop-view --lower-fifo-to-memref="fifo-index-mode=spsc-lockfree" %s | FileCheck %s --check-prefix=SPSC

// Simple case: fill loop only, no write-back.
// After the passes: no alloca, no fill loop. The view (subview) is acquired
// where the fill loop was; the release (read-counter advance) is deferred to
// the end of the action -- here that lands immediately after the subview,
// since the fill loop was the action's only other op, so view and release
// appear adjacently, in the same relative order as the old single-op lowering.

// CHECK-LABEL: cal.actor @simple_fill
// CHECK-NOT: fifo.pop
// CHECK: memref.subview
// CHECK: arith.addi
// CHECK: arith.remsi

// Note: the read-counter release is deferred to the end of the action (so a
// concurrently running producer never observes freed slots while this action
// is still reading through the view -- see the extract-fifo-pop-view pass
// description). @fill_and_process below shows the release landing after a
// later write-back loop instead of immediately after the subview.
// In lock-free mode the slot is computed as readCount % capacity (remsi) at
// acquire time, then the monotonic counter is advanced by N with addi only
// at release time (no wrapping remsi).
// (This note deliberately never writes the four-letter check prefix used
// below immediately followed by a colon -- FileCheck scans every line of
// this file for "<prefix>:" and would parse such text as a check directive.)
// SPSC-LABEL: cal.actor @simple_fill
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
// Unlike @simple_fill, the release is NOT adjacent to the subview here: it is
// deferred past the write-back loop -- the view's last use -- to the very end
// of the action, so the read counter only advances once every element has
// been both read and written back.

// CHECK-LABEL: cal.actor @fill_and_process
// CHECK-NOT: fifo.pop
// CHECK: memref.subview
// CHECK: scf.for
// CHECK: arith.addi
// CHECK: arith.remsi

// SPSC-LABEL: cal.actor @fill_and_process
// SPSC-NOT: fifo.pop
// SPSC: arith.remsi
// SPSC: memref.subview
// SPSC: scf.for
// SPSC: arith.addi
// SPSC-NOT: arith.remsi
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

// Relay case: the fill loop's destination is not a local buffer at all but a
// `fifo.push_bulk_view` result on a *different* port -- the shape that arises
// when an actor immediately forwards a popped bulk region into another FIFO
// (here written directly in the input, standing in for one the
// push-extraction pass would have produced -- in the real pipeline pop
// extraction runs first, so it never actually sees a push view; this input
// merely exercises the matcher's generality directly). The push view/commit
// are not ours to redirect or erase, since they belong to the other port;
// they are left exactly as the input has them, lowered to their own subview
// like the freshly acquired pop view. The loop is rewritten in place into a
// tight view-to-view copy and wrapped in a pop view/release -- after
// lowering: two subviews (one per port) feeding a copy loop, with both
// ports' counters updated and no scalar fifo.pop/fifo.push remaining.

// CHECK-LABEL: cal.actor @relay
// CHECK-NOT: fifo.pop
// CHECK-NOT: fifo.push
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
// SPSC-NOT: fifo.pop
// SPSC-NOT: fifo.push
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
    %view = fifo.push_bulk_view(%out0 : !fifo.input_port<i8>, %c64) : memref<64xi8, strided<[1], offset: ?>>
    scf.for %i = %c0 to %c64 step %c1 {
      %v = fifo.pop(%in0 : !fifo.output_port<i8>) : i8
      memref.store %v, %view[%i] : memref<64xi8, strided<[1], offset: ?>>
    }
    fifo.push_bulk_commit(%out0 : !fifo.input_port<i8>, %view : memref<64xi8, strided<[1], offset: ?>>, %c64)
  }
}

// Heap-allocation case: the filled buffer is a `memref.alloc`, not an
// alloca. Erasing it would orphan its paired `memref.dealloc` (which cannot
// run against a strided FIFO subview), so this must NOT take the
// redirect-and-erase path: the alloc/dealloc pair survives verbatim and the
// loop is rewritten in place into a view-backed copy.

// CHECK-LABEL: cal.actor @heap_fill
// CHECK: memref.alloc(
// CHECK-NOT: fifo.pop
// CHECK: memref.subview
// CHECK: scf.for
// CHECK: memref.load
// CHECK: memref.store %{{.*}}, %alloc
// CHECK: arith.addi
// CHECK: arith.remsi
// CHECK: memref.dealloc

// SPSC-LABEL: cal.actor @heap_fill
// SPSC: memref.alloc(
// SPSC-NOT: fifo.pop
// SPSC: arith.remsi
// SPSC: memref.subview
// SPSC: scf.for
// SPSC: memref.load
// SPSC: memref.store %{{.*}}, %alloc
// SPSC: arith.addi
// SPSC-NOT: arith.remsi
// SPSC: memref.dealloc
cal.actor @heap_fill ()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out ()
{
  cal.action "fill" priority=0 {
    %alloc = memref.alloc() : memref<4xi32>
    %c0 = arith.constant 0 : index
    %c4 = arith.constant 4 : index
    %c1 = arith.constant 1 : index
    scf.for %i = %c0 to %c4 step %c1 {
      %val = fifo.pop(%in0 : !fifo.output_port<i32>) : i32
      memref.store %val, %alloc[%i] : memref<4xi32>
    }
    memref.dealloc %alloc : memref<4xi32>
  }
}

// Wrap-around structure: a bulk-pop view that may straddle the end of the
// circular buffer requires a runtime branch. The contiguous path (then) takes
// a zero-copy subview of the backing buffer. The wrap-around path (else) copies
// the tail fragment then the head fragment into a fresh stack allocation so the
// caller always sees a flat, contiguous buffer.

// CHECK-LABEL: cal.actor @wrap_boundary
// CHECK-NOT: fifo.pop
// CHECK: arith.cmpi
// CHECK: scf.if
// CHECK: memref.subview
// CHECK: memref.alloca
// CHECK: memref.subview
// CHECK: memref.copy
// CHECK: memref.subview
// CHECK: memref.copy
// CHECK: memref.cast
// CHECK: arith.addi
// CHECK: arith.remsi

// SPSC-LABEL: cal.actor @wrap_boundary
// SPSC-NOT: fifo.pop
// SPSC: arith.remsi
// SPSC: arith.cmpi
// SPSC: scf.if
// SPSC: memref.subview
// SPSC: memref.alloca
// SPSC: memref.subview
// SPSC: memref.copy
// SPSC: memref.subview
// SPSC: memref.copy
// SPSC: memref.cast
// SPSC: arith.addi
// SPSC-NOT: arith.remsi
cal.actor @wrap_boundary ()
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
