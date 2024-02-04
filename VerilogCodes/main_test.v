`timescale 1ns / 1ps

module main_test;

	// Inputs
	reg clk_1;
	reg clk_8;
	reg reset;
	reg start;

	// Instantiate the Unit Under Test (UUT)
	main uut (
		.clk_1(clk_1), 
		.clk_8(clk_8), 
		.reset(reset), 
		.start(start)
	);

	always #1 clk_1 = ~clk_1;
	always #10 clk_8 = ~clk_8;

	initial begin
		clk_1 = 1;
		clk_8 = 1;
		reset = 0;
		start = 1;
	end	

endmodule

