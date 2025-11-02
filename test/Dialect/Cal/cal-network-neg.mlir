// RUN: cal-opt -verify-diagnostics %s
// XFAIL: *

// expected-error @+1 {{'cal.create_instance' op expects parent op 'cal.network'}}
cal.create_instance @NoSuchSymbol ()

// (Missing one port operand)
// (Missing one port operand)
cal.network @NetA(%x: i32)
		ports_in(%in: !fifo.output_port<i32>)
		ports_out(%out: !fifo.input_port<i32>) {
}
// Attempt instantiation with wrong operand count
func.func @illegal_use(%a: i32, %b: !fifo.output_port<i32>) {
  // expected-error @+1 {{'cal.create_instance' op expects parent op 'cal.network'}}
	cal.create_instance @NetA (%a: i32)
			ports_in(%b : !fifo.output_port<i32>)
	return
}

// expected-error @+2 {{actor definitions are not permitted inside a cal.network}}
cal.network @BadNested() {
	cal.actor @inner() { }
}