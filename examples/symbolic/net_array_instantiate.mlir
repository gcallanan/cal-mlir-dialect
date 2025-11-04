// Array-of-networks smoke test for flatten-cal-networks

cal.actor @id()
    ports_in (%in: !fifo.output_port<i32>)
    ports_out (%out: !fifo.input_port<i32>)
{
  cal.action {
    %t = fifo.pop(%in : !fifo.output_port<i32>) : i32
    fifo.push(%out : !fifo.input_port<i32>, %t : i32)
  }
}

cal.network @child()
    ports_in (%in: !fifo.output_port<i32>)
    ports_out (%out: !fifo.input_port<i32>)
{
  %h = cal.instantiate @id instance("id0") : !cal.instance<@id>
  cal.connect %in : !fifo.output_port<i32> "in" -> %h : !cal.instance<@id> "in"
  cal.connect %h  : !cal.instance<@id> "out" -> %out : !fifo.input_port<i32> "in"
}

cal.network @top()
{
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  %arr = cal.instantiate_array @child count(2) basename("c") : !cal.instance.array<@child, [?]>
  %i0 = arith.constant 0 : index
  %i1 = arith.constant 1 : index
  cal.connect %out0 : !fifo.output_port<i32> "out" -> %arr[%i0] : !cal.instance.array<@child, [?]> "in"
  cal.connect %arr[%i0] : !cal.instance.array<@child, [?]> "out" -> %in1 : !fifo.input_port<i32> "in"
  cal.connect %out1 : !fifo.output_port<i32> "out" -> %arr[%i1] : !cal.instance.array<@child, [?]> "in"
  cal.connect %arr[%i1] : !cal.instance.array<@child, [?]> "out" -> %in0 : !fifo.input_port<i32> "in"
}
