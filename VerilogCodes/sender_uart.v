`timescale 1ns / 1ps

module sender_uart (
	input wire clk,
	input wire rst,
	input wire [7:0] tx_data,
	input wire ready,
	output reg tx_out
);

  reg [7:0] data_reg;
  reg [3:0] bit_count = 0;
  
always @(posedge clk or posedge rst)
	if (!rst) begin
		if (ready) begin
			if (bit_count == 0) begin
				data_reg <= tx_data;
				tx_out <= 1'b0;
				bit_count <= bit_count + 1;
			end else if (bit_count < 9) begin
				tx_out <= data_reg[bit_count - 1];
				bit_count <= bit_count + 1;
			end else if (bit_count == 9) begin
				tx_out <= 1'b1;
				bit_count <= 0;
			end else if (bit_count == 10) begin
				tx_out <= 1'bX; 
				bit_count <= 0;
			end
		end
	end
							
endmodule
