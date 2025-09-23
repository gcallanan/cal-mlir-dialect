// RUN: cal-opt --flatten-cal-networks %s | FileCheck %s

// Multi-level flatten test: Top -> Mid -> Inner -> Leaf
// After flattening Top should directly contain only one create_instance @Leaf
// and no create_instance @Mid or @Inner.
//
// CHECK-LABEL: cal.network @Top()
// CHECK: cal.create_instance @Leaf()
// CHECK-NOT: cal.create_instance @Mid
// CHECK-NOT: cal.create_instance @Inner

cal.actor @Leaf()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>) {
}

cal.network @Inner()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>) {
  cal.create_instance @Leaf ()
      ports_in(%in0 : !fifo.output_port<i32>)
      ports_out(%out0 : !fifo.input_port<i32>)
}

cal.network @Mid()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>) {
  cal.create_instance @Inner ()
      ports_in(%in0 : !fifo.output_port<i32>)
      ports_out(%out0 : !fifo.input_port<i32>)
}

cal.network @Top(){
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  cal.create_instance @Mid ()
      ports_in(%out0 : !fifo.output_port<i32>)
      ports_out(%in0 : !fifo.input_port<i32>)
}
