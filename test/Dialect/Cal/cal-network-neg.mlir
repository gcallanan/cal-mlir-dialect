// RUN: not cal-opt %s 2>&1 | FileCheck %s --check-prefix=NEG

// NEG: does not reference a valid cal.actor or cal.network
cal.create_instance @NoSuchSymbol ()

// NEG: expected 3 operands (network params+ports), but got 2
// (Missing one port operand)
cal.network @NetA(%x: i32)
		ports_in(%in: !fifo.output_port<i32>)
		ports_out(%out: !fifo.input_port<i32>) {
}
// Attempt instantiation with wrong operand count
func.func @illegal_use(%a: i32, %b: !fifo.output_port<i32>) {
	cal.create_instance @NetA (%a: i32)
			ports_in(%b : !fifo.output_port<i32>)
	return
}

// NEG: actor definitions are not permitted inside a cal.network
cal.network @BadNested() {
	cal.actor @inner() { }
}