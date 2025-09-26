// Fully-wired symbolic network using instantiate_array and connect sugar.
// Elaborates to fifo.create + cal.create_instance wiring.

cal.actor @Prod()
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %one = arith.constant 1 : i32
    %cap = fifo.space(%o: !fifo.input_port<i32>) : index
    %z = arith.constant 0 : index
    %ok = arith.cmpi sgt, %cap, %z : index
    scf.if %ok {
      fifo.push(%o: !fifo.input_port<i32>, %one: i32)
      scf.yield
    } else {
      scf.yield
    }
    cal.action_done %ok : i1
  }
}

cal.actor @Cons()
    ports_in(%i: !fifo.output_port<i32>) {
  cal.execution_body {
    %n = fifo.size(%i: !fifo.output_port<i32>) : index
    %z = arith.constant 0 : index
    %ok = arith.cmpi sgt, %n, %z : index
    scf.if %ok {
      %t = fifo.pop(%i: !fifo.output_port<i32>) : i32
      fifo.print("Cons got %d\0A\00", %t) : (i32)
      scf.yield
    } else {
      scf.yield
    }
    cal.action_done %ok : i1
  }
}

cal.network @N() {
  %prods = cal.instantiate_array @Prod count(2) : !cal.instance.array<@Prod, 2>
  %cons  = cal.instantiate_array @Cons count(2) : !cal.instance.array<@Cons, 2>

  %i0 = arith.constant 0 : index
  %i1 = arith.constant 1 : index

  // Fully connect corresponding elements 0 and 1.
  cal.connect %prods[%i0] : !cal.instance.array<@Prod, 2> "out" -> %cons[%i0] : !cal.instance.array<@Cons, 2> "in"
  cal.connect %prods[%i1] : !cal.instance.array<@Prod, 2> "out" -> %cons[%i1] : !cal.instance.array<@Cons, 2> "in"
}
