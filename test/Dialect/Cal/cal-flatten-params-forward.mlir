// RUN: cal-opt --flatten-cal-networks %s | FileCheck %s

// Parameter forwarding flatten test.
// Networks: Top -> Mid(%p: i32) -> Inner(%p: i32) -> Leaf(%p: i32)
// Expect after flatten: Top network contains a constant and a direct
// create_instance @Leaf(%c42) with no intermediate network instances.
//
// CHECK-LABEL: cal.network @Top()
// CHECK: %c42 = arith.constant 42 : i32
// CHECK: cal.create_instance @Leaf (%c42 : i32)
// CHECK-NOT: cal.create_instance @Mid
// CHECK-NOT: cal.create_instance @Inner

cal.actor @Leaf(%p: i32)
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>) {
}

cal.network @Inner(%p: i32)
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>) {
  cal.create_instance @Leaf (%p : i32)
      ports_in(%in0 : !fifo.output_port<i32>)
      ports_out(%out0 : !fifo.input_port<i32>)
}

cal.network @Mid(%p: i32)
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>) {
  cal.create_instance @Inner (%p : i32)
      ports_in(%in0 : !fifo.output_port<i32>)
      ports_out(%out0 : !fifo.input_port<i32>)
}

cal.network @Top(){
  %c42 = arith.constant 42 : i32
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  cal.create_instance @Mid (%c42 : i32)
      ports_in(%out0 : !fifo.output_port<i32>)
      ports_out(%in0 : !fifo.input_port<i32>)
}
