`timescale 1ns / 1ps

module receiver_uart_test;

	// Inputs
	reg clk;
	reg rst;
	reg rx_in;

	// Outputs
	wire [7:0] rx_data;
	wire ready;

	// Instantiate the Unit Under Test (UUT)
	receiver_uart uut (
		.clk(clk), 
		.rst(rst), 
		.rx_in(rx_in), 
		.rx_data(rx_data), 
		.ready(ready)
	);

  initial begin
    clk = 0;
    rst = 0;
    #10 rx_in = 0;
    #10 rx_in = 1'b0;
    #10 rx_in = 1'b0;
    #10 rx_in = 1'b1;
    #10 rx_in = 1'b0;
    #10 rx_in = 1'b1;
    #10 rx_in = 1'b0;
    #10 rx_in = 1'b1;
    #10 rx_in = 1'b0;
    #10 rx_in = 1'b1;
    #10 rx_in = 0;
    #10 rx_in = 1'b1;
    #10 rx_in = 1'b0; 
    #10 rx_in = 1'b1;
    #10 rx_in = 1'b0;
    #10 rx_in = 1'b1;
    #10 rx_in = 1'b0;
    #10 rx_in = 1'b1;
    #10 rx_in = 1'b0;
    #10 rx_in = 1'b1;
    #200 $stop;
  end

  always #5 clk = ~clk;
        
endmodule

