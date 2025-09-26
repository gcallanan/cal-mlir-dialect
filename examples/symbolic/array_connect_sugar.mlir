// Symbolic instance array connect with array[index] sugar on both ends
// This exercises the custom parser and the strict Option A canonicalization
// that lowers to explicit cal.instance_at + handle-only cal.connect.

cal.actor @A(%p: i32)
    ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %c1 = arith.constant 1 : i32
    %cap = fifo.space(%o: !fifo.input_port<i32>) : index
    %z = arith.constant 0 : index
    %ok = arith.cmpi sgt, %cap, %z : index
    scf.if %ok {
      fifo.push(%o: !fifo.input_port<i32>, %c1: i32)
      scf.yield
    } else {
      scf.yield
    }
    cal.action_done %ok : i1
  }
}

cal.actor @B()
    ports_in(%i: !fifo.output_port<i32>) {
  cal.execution_body {
    %n = fifo.size(%i: !fifo.output_port<i32>) : index
    %z = arith.constant 0 : index
    %ok = arith.cmpi sgt, %n, %z : index
    scf.if %ok {
      %t = fifo.pop(%i: !fifo.output_port<i32>) : i32
      fifo.print("B got %d\0A\00", %t) : (i32)
      scf.yield
    } else {
      scf.yield
    }
    cal.action_done %ok : i1
  }
}

cal.network @net() {
  %n = arith.constant 2 : i32
  %arr = cal.instantiate_array @A count(3) (%n : i32) : !cal.instance.array<@A, 3>
  %bArr = cal.instantiate_array @B count(3) : !cal.instance.array<@B, 3>

  %i0 = arith.constant 0 : index
  %i1 = arith.constant 1 : index

  // sugar on both src and dst sides
  cal.connect %arr[%i0] : !cal.instance.array<@A, 3> "out" -> %bArr[%i1] : !cal.instance.array<@B, 3> "in"
}
