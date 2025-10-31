// RUN: cal-opt -canonicalize --flatten-cal-networks -split-input-file %s -verify-diagnostics

// cal.interface with named ports
cal.interface @PipeLike { inPortNames = ["in"], inPortTypes = [!fifo.output_port<i32>], outPortNames = ["out"], outPortTypes = [!fifo.input_port<i32>] }

// Actor conforms to @PipeLike
cal.actor @A()
  in_names ["in"] out_names ["out"]
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.implements @PipeLike for @A

// Duplicate destination: two network sources to the same element interface input
cal.network @IfaceArrDupDst() {
  %c0 = arith.constant 0 : index

  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  %arr = cal.instantiate_array @A count (2) : !cal.instance.array<@A, 2>
  %a0 = cal.instance_at %arr[%c0] : !cal.instance.array<@A, 2>, index -> !cal.instance<@A>
  %ia0 = cal.instance.cast %a0 : !cal.instance<@A> -> !cal.instance.iface<@PipeLike>

  // First connection OK
  cal.connect %out0 : !fifo.output_port<i32> "in" -> %ia0 : !cal.instance.iface<@PipeLike> "in"
  // Second connection to same destination port should error
  // expected-error @+1 {{destination port already connected}}
  cal.connect %out1 : !fifo.output_port<i32> "in" -> %ia0 : !cal.instance.iface<@PipeLike> "in"
}

// -----

// cal.interface with named ports
cal.interface @PipeLike { inPortNames = ["in"], inPortTypes = [!fifo.output_port<i32>], outPortNames = ["out"], outPortTypes = [!fifo.input_port<i32>] }

// Actor conforms to @PipeLike
cal.actor @A()
  in_names ["in"] out_names ["out"]
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

cal.implements @PipeLike for @A

// Duplicate source: same element interface output to two network sinks
cal.network @IfaceArrDupSrc() {
  %c1 = arith.constant 1 : index

  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  %arr = cal.instantiate_array @A count (2) : !cal.instance.array<@A, 2>
  %a1 = cal.instance_at %arr[%c1] : !cal.instance.array<@A, 2>, index -> !cal.instance<@A>
  %ia1 = cal.instance.cast %a1 : !cal.instance<@A> -> !cal.instance.iface<@PipeLike>

  // First connection OK
  cal.connect %ia1 : !cal.instance.iface<@PipeLike> "out" -> %in0 : !fifo.input_port<i32> "out"
  // Second connection from same source port should error
  // expected-error @+1 {{source port already connected}}
  cal.connect %ia1 : !cal.instance.iface<@PipeLike> "out" -> %in1 : !fifo.input_port<i32> "out"
}
