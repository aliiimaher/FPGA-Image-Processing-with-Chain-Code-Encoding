`timescale 1ns / 1ps

module chain_code_encoder_test;

	// Inputs
	reg reset;
	reg clk;
	reg start;

	// Outputs
	wire [7:0] code;
	wire done;
	wire error;
	wire [8:0] perimeter;
	wire [11:0] area;
	wire [5:0] startX;
	wire [5:0] startY;

	// Instantiate the Unit Under Test (UUT)
	chain_code_encoder uut (
		.reset(reset), 
		.clk(clk), 
		.start(start), 
		.code(code), 
		.done(done), 
		.error(error), 
		.perimeter(perimeter), 
		.area(area), 
		.startX(startX), 
		.startY(startY)
	);
	
	always #1 clk = ~clk;

	initial begin
		reset = 0;
		clk = 0;
		start = 1;
	end
	  
endmodule

