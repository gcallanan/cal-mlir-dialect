// RUN: cal-opt -canonicalize --flatten-cal-networks -split-input-file %s -verify-diagnostics

cal.actor @A()
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// Duplicate destination: two different network sources to the same array element input
cal.network @ArrayDupDst() {
  %c0 = arith.constant 0 : index

  %in0, %out0 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>

  %arr = cal.instantiate_array @A count (2) : <@A, [2]>

  // First connection OK
  // expected-remark @+1 {{first connection to this port was here}}
  cal.connect %out0 : !fifo.output_port<i32> "out" -> %arr[%c0] : !cal.instance.array<@A, [2]> "in"
  // Second connection to same destination port should error
  // expected-error @+1 {{destination port already connected}}
  cal.connect %out1 : !fifo.output_port<i32> "out" -> %arr[%c0] : !cal.instance.array<@A, [2]> "in"
}

// -----

cal.actor @A()
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// Duplicate source: same array element output connected to two different network sinks
cal.network @ArrayDupSrc() {
  %c1 = arith.constant 1 : index

  %in0, %out0 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>

  %arr = cal.instantiate_array @A count (2) : <@A, [2]>

  // First connection OK
  // expected-remark @+1 {{first connection to this port was here}}
  cal.connect %arr[%c1] : !cal.instance.array<@A, [2]> "out" -> %in0 : !fifo.input_port<i32> "in"
  // Second connection from same source port should error
  // expected-error @+1 {{source port already connected}}
  cal.connect %arr[%c1] : !cal.instance.array<@A, [2]> "out" -> %in1 : !fifo.input_port<i32> "in"
}
