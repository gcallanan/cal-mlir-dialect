// A very rudimentary testbench for the generate top MLIR module. The timing on the signals is not well though out so the DUT may not always pick up the signal, you may want to modify the input signals yourself.
`timescale 1ns / 10ps

module top_tb;

// Registers for input signals
reg        clock = 1, reset = 0;

// Wires for output signals

// Connect testbench to top module
top dut(
	clock, reset
);

// Create clock signal
always #5 clock=~clock;

// Block toggling signals for testing
initial begin
	reset = 1;
	# 60
	reset = 0;

	// Toggle signals a few times to see behaviour over time
	# 50
	# 10

	# 50
	# 10

	# 50
	# 10

	# 50
	# 10

	# 50
	# 10

end

endmodule
