// RUN: cal-opt %s | FileCheck %s
// Basic printing/parsing tests for the new symbolic cal.network op.

// 1. Empty network with no params or ports
cal.network @Empty() {
	%c0 = arith.constant 0 : i32
}
// CHECK-LABEL: cal.network @Empty()
// CHECK: {
// CHECK: }

// 2. Network with parameters only
cal.network @WithParams(%a: i32, %b: f32) {
	// Body left intentionally empty
}
// CHECK-LABEL: cal.network @WithParams(%{{.*}}: i32, %{{.*}}: f32)
// CHECK: {
// CHECK: }

// 3. Network with input ports only
cal.network @WithInPorts(%n: i32)
		ports_in(%inA: !fifo.output_port<i32>, %inB: !fifo.output_port<f32>) {
}
// CHECK-LABEL: cal.network @WithInPorts(%{{.*}}: i32)
// CHECK: ports_in (
// CHECK: !fifo.output_port<i32>
// CHECK: !fifo.output_port<f32>
// CHECK: {
// CHECK: }

// 4. Network with output ports only
cal.network @WithOutPorts()
		ports_out(%outX: !fifo.input_port<i64>) {
}
// CHECK-LABEL: cal.network @WithOutPorts()
// CHECK: ports_out (
// CHECK: !fifo.input_port<i64>
// CHECK: {
// CHECK: }

// 5. Network with both input and output ports and params
cal.network @Full(%p0: i32)
		ports_in(%src: !fifo.output_port<i32>)
		ports_out(%snk: !fifo.input_port<i32>) {
	// Simple fifo pass-through infra to ensure operands stable
	%in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
	// (Future hierarchical tests will instantiate actors/networks.)
}
// CHECK-LABEL: cal.network @Full(%{{.*}}: i32)
// CHECK: ports_in (
// CHECK: !fifo.output_port<i32>
// CHECK: ports_out (
// CHECK: !fifo.input_port<i32>
// CHECK: %inputPort, %outputPort = fifo.create<i32> (2) : !fifo.input_port<i32>, !fifo.output_port<i32>

// 6. Hierarchical: Network referencing another network (positive case)
cal.network @Child(%limit: i32)
		ports_in(%cIn: !fifo.output_port<i32>)
		ports_out(%cOut: !fifo.input_port<i32>) {
	// just a fifo to show structure
	%inA, %outA = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
}

// Parent instantiates Child: ensure operand ordering (params, inPorts, outPorts)
cal.network @Parent(%limit: i32)
		ports_in(%pIn: !fifo.output_port<i32>)
		ports_out(%pOut: !fifo.input_port<i32>) {
	// Create fifo endpoints to pass to child
	%cin, %cout = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
	// Instance: pass (%limit, %pIn, %pOut)
	cal.create_instance @Child "child0" (%limit: i32)
			ports_in(%pIn : !fifo.output_port<i32>)
			ports_out(%pOut : !fifo.input_port<i32>)
}
// CHECK-LABEL: cal.network @Parent(%{{.*}}: i32)
// CHECK: cal.create_instance @Child "child0" (%{{.*}} : i32)
// CHECK:     ports_in (%{{.*}} : !fifo.output_port<i32>)
// CHECK:     ports_out (%{{.*}} : !fifo.input_port<i32>)
