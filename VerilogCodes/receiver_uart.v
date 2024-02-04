`timescale 1ns / 1ps

module receiver_uart (
	input wire clk,
	input wire rst,
	input wire rx_in,
	output reg [7:0] rx_data,
	output reg ready
);

	reg [3:0] bit_count = 0; 

	always @(posedge clk or posedge rst)
		if (!rst) begin   
			if (bit_count == 0) begin
				rx_data <= 8'bX;
				if (rx_in == 1'b0) begin
					bit_count <= 1;
					ready <= 0;
				end
			end else if (bit_count < 9 && bit_count > 0) begin
				rx_data[bit_count - 1] <= rx_in;
				bit_count <= bit_count + 1;
			end else if (rx_in == 1'b1 && bit_count == 9) begin
				ready <= 1;
				bit_count <= 4'b0;
			end               
		end

endmodule
