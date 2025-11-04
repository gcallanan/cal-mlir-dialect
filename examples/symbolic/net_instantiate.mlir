// Minimal network-instantiation smoke test for flatten-cal-networks

cal.actor @id()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>)
{
  cal.action {
    %t = fifo.pop(%in0: !fifo.output_port<i32>) : i32
    fifo.push(%out0: !fifo.input_port<i32>, %t: i32)
  }
}

// Child network with a single in/out port uses the @id actor internally via symbolic connects
cal.network @child()
    ports_in(%in: !fifo.output_port<i32>)
    ports_out(%out: !fifo.input_port<i32>)
{
  %h = cal.instantiate @id : !cal.instance<@id>
  cal.connect %in : !fifo.output_port<i32> "in" -> %h : !cal.instance<@id> "in"
  cal.connect %h : !cal.instance<@id> "out" -> %out : !fifo.input_port<i32> "in"
}

// Top network that instantiates a network via cal.instantiate and wires through a FIFO
cal.network @top() {
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  %c = cal.instantiate @child instance("c0") : !cal.instance<@child>
  // Wire: out0 -> child.in, child.out -> in1
  cal.connect %out0 : !fifo.output_port<i32> "out" -> %c : !cal.instance<@child> "in"
  cal.connect %c : !cal.instance<@child> "out" -> %in1 : !fifo.input_port<i32> "in"
}
