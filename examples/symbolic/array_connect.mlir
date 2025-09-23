// Symbolic instance array and connect sugar demo
// This uses the new high-level ops and types:
//  - !cal.instance<@Actor>
//  - !cal.instance.array<@Actor, N>
//  - cal.instantiate, cal.instantiate_array, cal.instance_at, cal.connect
// It should parse/print once custom parser/printer for these ops are implemented.

cal.actor @src(%max: i32)
    ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %one = arith.constant 1 : i32
    %have = fifo.space(%o: !fifo.input_port<i32>) : index
    %z = arith.constant 0 : index
    %ok = arith.cmpi sgt, %have, %z : index
    scf.if %ok {
      fifo.push(%o: !fifo.input_port<i32>, %one: i32)
      scf.yield
    } else {
      scf.yield
    }
    cal.action_done %ok : i1
  }
}

cal.actor @sink()
    ports_in(%i: !fifo.output_port<i32>) {
  cal.execution_body {
    %avail = fifo.size(%i: !fifo.output_port<i32>) : index
    %z = arith.constant 0 : index
    %ok = arith.cmpi sgt, %avail, %z : index
    scf.if %ok {
      %t = fifo.pop(%i: !fifo.output_port<i32>) : i32
      fifo.print("t=%d\0A\00", %t) : (i32)
      scf.yield
    } else {
      scf.yield
    }
    cal.action_done %ok : i1
  }
}

cal.actor @wire()
    ports_in(%in: !fifo.output_port<i32>)
    ports_out(%out: !fifo.input_port<i32>) {
  cal.execution_body {
    %n = fifo.size(%in: !fifo.output_port<i32>) : index
    %z = arith.constant 0 : index
    %ok = arith.cmpi sgt, %n, %z : index
    scf.if %ok {
      %t = fifo.pop(%in: !fifo.output_port<i32>) : i32
      fifo.push(%out: !fifo.input_port<i32>, %t: i32)
      scf.yield
    } else {
      scf.yield
    }
    cal.action_done %ok : i1
  }
}

cal.network @sym_net() {
  %cap = arith.constant 3 : i32

  // Material channels for the eventual elaboration target
  %in0, %out0 = fifo.create<i32>(4) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(4) : !fifo.input_port<i32>, !fifo.output_port<i32>

  // High-level symbolic handles (not yet elaborated)
  %srcs = cal.instantiate_array @src count(2) ( %cap : i32 ) : !cal.instance.array<@src, 2>
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %s0 = cal.instance_at %srcs[%c0] : !cal.instance.array<@src, 2>, index -> !cal.instance<@src>
  %s1 = cal.instance_at %srcs[%c1] : !cal.instance.array<@src, 2>, index -> !cal.instance<@src>

  %sink = cal.instantiate @sink : !cal.instance<@sink>
  %wire = cal.instantiate @wire : !cal.instance<@wire>

  // Symbolic connections; an elaboration pass will convert these into
  // fifo.create + cal.create_instance with the concrete SSA ports connected.
  cal.connect %s0 : !cal.instance<@src> "out" -> %wire : !cal.instance<@wire> "in"
  cal.connect %wire : !cal.instance<@wire> "out" -> %sink : !cal.instance<@sink> "in"
  cal.connect %s1 : !cal.instance<@src> "out" -> %sink : !cal.instance<@sink> "in"
}
