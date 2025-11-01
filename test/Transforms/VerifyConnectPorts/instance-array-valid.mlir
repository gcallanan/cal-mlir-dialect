// RUN: cal-opt --composite-fixed-point-pass="pipeline=cal-structural-elaboration" %s | FileCheck %s --allow-empty

// Concrete actor with canonical ports and declared names
cal.actor @A()
  in_names ["in0"] out_names ["out0"]
  ports_in(%in0: !fifo.output_port<i32>)
  ports_out(%out0: !fifo.input_port<i32>)
{
}

cal.network @N() {
  %arr = cal.instantiate_array @A count(2) : !cal.instance.array<@A, 2>
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %h0 = cal.instance_at %arr[%c0] : !cal.instance.array<@A, 2>, index -> !cal.instance<@A>
  %h1 = cal.instance_at %arr[%c1] : !cal.instance.array<@A, 2>, index -> !cal.instance<@A>

  // Valid ports on concrete actor handles
  cal.connect %h0 : !cal.instance<@A> "out0" -> %h1 : !cal.instance<@A> "in0"
}

// CHECK-NOT: error: