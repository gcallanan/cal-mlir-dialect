// RUN: cal-opt --flatten-cal-networks %s | FileCheck %s

// Interface matching actor and network boundary
cal.interface @PipeLike {
  inPortNames  = ["in"],  inPortTypes  = [!fifo.output_port<i32>],
  outPortNames = ["out"], outPortTypes = [!fifo.input_port<i32>]
}

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

// Inner network implements interface and forwards boundary to actor
cal.network @Inner()
  ports_in(%pi: !fifo.output_port<i32>)
  ports_out(%po: !fifo.input_port<i32>) {
  %h = cal.instantiate @A : !cal.instance<@A>
  // Use actor-declared names to connect boundary ports
  cal.connect %pi : !fifo.output_port<i32> "in" -> %h : !cal.instance<@A> "in"
  cal.connect %h : !cal.instance<@A> "out" -> %po : !fifo.input_port<i32> "out"
}
cal.implements @PipeLike for @Inner

// Top wires FIFOs to Inner; after flattening, A should be inlined and wired
cal.network @Top() {
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  cal.create_instance @Inner "i0" ()
      ports_in(%out0 : !fifo.output_port<i32>)
      ports_out(%in0 : !fifo.input_port<i32>)
}

// CHECK: cal.network @Top()
// CHECK: = fifo.create<i32>
// CHECK: cal.create_instance @A
