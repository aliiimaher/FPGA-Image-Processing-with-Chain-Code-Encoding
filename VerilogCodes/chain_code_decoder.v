`timescale 1ns / 1ps

module chain_code_decoder(
    input wire clk,
    input wire reset,
    input wire [7:0] code,
    input wire start,
    input wire [8:0] perimeter,
    input wire [11:0] area,
    input wire [5:0] startX,
    input wire [5:0] startY,
    output reg done,
    output reg error
);

    localparam INITIALIZATIONS = 3'b000;
    localparam WAITING = 3'b001;
    localparam DECODE_IMAGE = 3'b010;
    localparam COLOR_OUTSIDE_FROM_LEFT_TO_RIGHT = 3'b011;
    localparam COLOR_OUTSIDE_FROM_RIGHT_TO_LEFT = 3'b100;
    localparam COLOR_OUTSIDE_FROM_TOP_TO_DOWN = 3'b101;
    localparam COLOR_OUTSIDE_FROM_BOTTOM_TO_UP = 3'b110;
    localparam FINILIZATION = 3'b111;

    reg [7:0] current_row_index = 8'b0000_0000, current_column_index = 8'b0000_0000, i, j;
	 initial $readmemb("output.txt", decoded_ram, 0, 63);
    reg [0:63] decoded_ram [0:63];
    reg reached_first_pixel;
    reg [2:0] state = 7, next_state;
    reg [8:0] current_perimeter = 0;
    reg [11:0] decoded_area;

    always @(posedge clk or posedge reset or posedge start) begin
        if (reset) begin
            state <= FINILIZATION;
            done <= 0;
            error <= 0;
        end else begin
            case (state)
                INITIALIZATIONS: begin
                    for (i = 0; i < 64; i = i + 1)
                        for (j = 0; j < 64; j = j + 1)
                            decoded_ram[i][j] <= 0;
                    reached_first_pixel <= 0;
                    next_state <= FINILIZATION;
                end

                WAITING: begin
                    if (start) begin
								current_row_index <= startX;
								current_column_index <= startY;
								decoded_ram[13][38] <= 1'b1;
                        next_state = DECODE_IMAGE;
                    end else begin
                        next_state = WAITING;
                    end
                end
                    
                DECODE_IMAGE: begin
							if (start) begin
								case (code)
									 0: begin
										  current_column_index <= current_column_index + 1;
									 end
									 1: begin
										  current_row_index <= current_row_index - 1;
										  current_column_index <= current_column_index + 1;
									 end
									 2: begin
										  current_row_index <= current_row_index - 1;
									 end
									 3: begin
										  current_row_index <= current_row_index - 1;
										  current_column_index <= current_column_index - 1;
									 end
									 4: begin
										  current_column_index <= current_column_index - 1;
									 end
									 5: begin
										  current_row_index <= current_row_index + 1;
										  current_column_index <= current_column_index - 1;
									 end
									 6: begin
										  current_row_index <= current_row_index + 1;
									 end
									 7: begin
										  current_row_index <= current_row_index + 1;
										  current_column_index <= current_column_index + 1;
									 end
								endcase

								if (current_perimeter != perimeter + 1) begin
									 decoded_ram[current_row_index][current_column_index] <= 1'b1;
									 current_perimeter <= current_perimeter + 1;
									 next_state = DECODE_IMAGE;
								end else begin
									 error = (decoded_area != area) || (current_perimeter != perimeter);
									 done <= 1;
									 i <= 0;
									 j <= 0;
									 next_state = COLOR_OUTSIDE_FROM_LEFT_TO_RIGHT;
								end
							end
                end

                COLOR_OUTSIDE_FROM_LEFT_TO_RIGHT: begin
							if (decoded_ram[i][j] == 1'b1 || j == 63) begin
								i <= i + 1;
								j <= 0;
							end else begin
								j <= j + 1;
							end
							if (i == 63 && j == 63) begin
								i <= 0;
								state <= COLOR_OUTSIDE_FROM_RIGHT_TO_LEFT;
							end
                end
					 
				    COLOR_OUTSIDE_FROM_RIGHT_TO_LEFT: begin
							if (decoded_ram[i][j] == 1'b1 || j == 0) begin
								i <= i + 1;
								j <= 63;
							end else begin
								j <= j - 1;
							end
							if (i == 63 && j == 0) begin
								i <= 0;
								state <= COLOR_OUTSIDE_FROM_TOP_TO_DOWN;
							end
                end

				    COLOR_OUTSIDE_FROM_TOP_TO_DOWN: begin
							if (decoded_ram[i][j] == 1'b1 || i == 63) begin
								j <= j + 1;
								i <= 0;
							end else begin
								i <= i + 1;
							end
							if (i == 0 && j == 0) begin
								i <= 63;
								j <= 63;
								state <= COLOR_OUTSIDE_FROM_BOTTOM_TO_UP;
							end
                end

				    COLOR_OUTSIDE_FROM_BOTTOM_TO_UP: begin
							if (decoded_ram[i][j] == 1'b1 || i == 0) begin
								j <= j - 1;
								i <= 63;
							end else begin
								i <= i - 1;
							end
							if (i == 63 && j == 0) begin
								state <= FINILIZATION;
							end
                end

                FINILIZATION: begin
                    next_state = FINILIZATION;
                end
                
            endcase

            state <= next_state;
        end
    end

endmodule
