// RUN: cal-opt --flatten-cal-networks %s | FileCheck %s

// This test verifies that the flatten pass inlines a nested network (Inner)
// into the top-level network (Top) when the nested network only forwards its
// ports (no internal fifo allocation). After flattening we expect:
//  - Only the Top-level fifo.create remains (Inner had none itself)
//  - The create_instance @Inner is removed
//  - A direct create_instance @Leaf appears wired to the Top fifo ports
//
// CHECK-LABEL: cal.network @Top()
// CHECK: fifo.create<i32>
// CHECK: cal.create_instance @Leaf()
// CHECK-NOT: cal.create_instance @Inner

// Define leaf actor
cal.actor @Leaf()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>) {
}

// Inner network forwards ports directly to Leaf instance
cal.network @Inner()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>) {
  cal.create_instance @Leaf ()
      ports_in(%in0 : !fifo.output_port<i32>)
      ports_out(%out0 : !fifo.input_port<i32>)
}

// Top network instantiates Inner and adds its own fifo
cal.network @Top(){
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
    // NOTE: This wiring may look inverted at first glance. Convention:
    //   ports_in  -> values of type !fifo.output_port<T> (the network/actor will POP from these)
    //   ports_out -> values of type !fifo.input_port<T>  (the network/actor will PUSH to these)
    // fifo.create returns (%inputPort, %outputPort) = (!fifo.input_port<T>, !fifo.output_port<T>)
    // So to satisfy Inner's signature (ports_in: output_port, ports_out: input_port) we pass:
    //   ports_in(%out0)  where %out0 : !fifo.output_port<i32>
    //   ports_out(%in0)  where %in0 : !fifo.input_port<i32>
    cal.create_instance @Inner ()
            ports_in(%out0 : !fifo.output_port<i32>)
            ports_out(%in0 : !fifo.input_port<i32>)
}
