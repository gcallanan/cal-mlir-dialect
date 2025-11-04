// Dynamic array-of-networks with parameters; fully elaborated via flattening

cal.actor @scale(%k: i32)
    ports_in (%in: !fifo.output_port<i32>)
    ports_out (%out: !fifo.input_port<i32>)
{
  cal.action {
    %t = fifo.pop(%in : !fifo.output_port<i32>) : i32
    %s = arith.addi %t, %k : i32
    fifo.push(%out : !fifo.input_port<i32>, %s : i32)
  }
}

// Child network takes a parameter and threads it to @scale
cal.network @child(%k: i32)
    ports_in (%in: !fifo.output_port<i32>)
    ports_out (%out: !fifo.input_port<i32>)
{
  %h = cal.instantiate @scale(%k : i32) instance("scale0") : !cal.instance<@scale>
  cal.connect %in   : !fifo.output_port<i32> "in" -> %h : !cal.instance<@scale> "in"
  cal.connect %h    : !cal.instance<@scale> "out"  -> %out : !fifo.input_port<i32> "in"
}

// Top builds a dynamic-typed array of the child network and wires both elements.
cal.network @top() {
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %in1, %out1 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  %k = arith.constant 10 : i32
  // Use dynamic array type form ("[?]") but constant count for elaboration.
  %arr = cal.instantiate_array @child count(2) basename("c") (%k : i32) : !cal.instance.array<@child, [?]>

  %i0 = arith.constant 0 : index
  %i1 = arith.constant 1 : index
  cal.connect %out0 : !fifo.output_port<i32> "out" -> %arr[%i0] : !cal.instance.array<@child, [?]> "in"
  cal.connect %arr[%i0] : !cal.instance.array<@child, [?]> "out" -> %in1 : !fifo.input_port<i32> "in"
  cal.connect %out1 : !fifo.output_port<i32> "out" -> %arr[%i1] : !cal.instance.array<@child, [?]> "in"
  cal.connect %arr[%i1] : !cal.instance.array<@child, [?]> "out" -> %in0 : !fifo.input_port<i32> "in"
}
