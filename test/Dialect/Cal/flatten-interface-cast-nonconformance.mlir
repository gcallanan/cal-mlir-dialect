// RUN: cal-opt --flatten-cal-networks -split-input-file %s -verify-diagnostics

//===----------------------------------------------------------------------===//
// Case 1: Source-side cast to an interface not implemented by the actor
// Expect an error when elaborating connect from interface-typed source handle.
//===----------------------------------------------------------------------===//
cal.interface @PipeLike { inPortNames = ["in"], inPortTypes = [!fifo.output_port<i32>],
                          outPortNames = ["out"], outPortTypes = [!fifo.input_port<i32>] }

// Actor @A does NOT declare implements @PipeLike
cal.actor @A()
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @SrcCastBad() {
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  %h = cal.instantiate @A : !cal.instance<@A>
  %ih = cal.instance.cast %h : !cal.instance<@A> -> !cal.instance.iface<@PipeLike>

  // expected-error@+1 {{invalid instance.cast on source: entity 'A' does not implement interface 'PipeLike'}}
  cal.connect %ih : !cal.instance.iface<@PipeLike> "out" -> %in0 : !fifo.input_port<i32> "out"
}

//===----------------------------------------------------------------------===//
// Case 2: Destination-side cast to an interface not implemented by the actor
// Expect an error when elaborating connect to interface-typed destination handle.
//===----------------------------------------------------------------------===//
// ---
cal.interface @PipeLike { inPortNames = ["in"], inPortTypes = [!fifo.output_port<i32>],
                          outPortNames = ["out"], outPortTypes = [!fifo.input_port<i32>] }

cal.actor @A()
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.network @DstCastBad() {
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  %h = cal.instantiate @A : !cal.instance<@A>
  %ih = cal.instance.cast %h : !cal.instance<@A> -> !cal.instance.iface<@PipeLike>

  // expected-error@+1 {{invalid instance.cast on destination: entity 'A' does not implement interface 'PipeLike'}}
  cal.connect %out0 : !fifo.output_port<i32> "in" -> %ih : !cal.instance.iface<@PipeLike> "in"
}
