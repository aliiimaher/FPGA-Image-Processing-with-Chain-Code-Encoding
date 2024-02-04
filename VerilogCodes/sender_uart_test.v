`timescale 1ns / 1ps

module sender_uart_test;

	// Inputs
	reg clk;
	reg rst;
	reg [7:0] tx_data;
	reg ready;

	// Outputs
	wire tx_out;

	// Instantiate the Unit Under Test (UUT)
	sender_uart uut (
		.clk(clk), 
		.rst(rst), 
		.tx_data(tx_data), 
		.ready(ready), 
		.tx_out(tx_out)
	);

	always #1 clk = ~clk;

	initial begin
		clk = 0;
		rst = 0;
		#1
		tx_data = 8'b1100_1101;
		ready = 1;
		#20
		tx_data = 8'b1010_1001;
	end


endmodule

