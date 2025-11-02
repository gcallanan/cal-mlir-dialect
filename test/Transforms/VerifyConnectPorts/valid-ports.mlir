// RUN: cal-opt --composite-fixed-point-pass="pipeline=cal-structural-elaboration" %s | FileCheck %s --allow-empty

// A simple actor with one in/out port each using canonical names and declared names.
cal.actor @A()
  in_names ["in0"] out_names ["out0"]
  ports_in(%in0: !fifo.output_port<i32>)
  ports_out(%out0: !fifo.input_port<i32>)
{
}

// A network that instantiates a handle and connects out0->in0 on the same entity handle.
cal.network @N() {
  %h = cal.instantiate @A : !cal.instance<@A>
  cal.connect %h : !cal.instance<@A> "out0" -> %h : !cal.instance<@A> "in0"
}

// CHECK-NOT: error: