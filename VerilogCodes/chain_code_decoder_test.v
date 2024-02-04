`timescale 1ns / 1ps

module chain_code_decoder_test;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] code;
	reg start;
	reg [8:0] perimeter;
	reg [11:0] area;
	reg [5:0] startX;
	reg [5:0] startY;

	// Outputs
	wire done;
	wire error;

	// Instantiate the Unit Under Test (UUT)
	chain_code_decoder uut (
		.clk(clk), 
		.reset(reset), 
		.code(code), 
		.start(start), 
		.perimeter(perimeter), 
		.area(area), 
		.startX(startX), 
		.startY(startY), 
		.done(done), 
		.error(error)
	);

	always #1 clk = ~clk;
	
	initial begin
		clk = 0;
		reset = 0;
		start = 1;
		perimeter = 113;
		area = 461;
		startX = 13;
		startY = 38;
	end
      
endmodule
