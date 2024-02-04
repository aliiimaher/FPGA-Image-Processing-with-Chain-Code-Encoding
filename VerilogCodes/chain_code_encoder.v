`timescale 1ns / 1ps

module chain_code_encoder(
    input wire reset,
    input wire clk,
    input wire start,
    output reg [7:0] code,
    output reg done,
    output wire error,
    output reg [8:0] perimeter,
    output reg [11:0] area,
    output wire [5:0] startX,
    output wire [5:0] startY
);

    localparam INITIALIZATIONS = 4'b0000;
    localparam WAITING = 4'b0001;
    localparam FIND_STARTING_PIXEL = 4'b0010;
    localparam CALCULATE_CHAIN_CODES = 4'b0011;
    localparam CHECK_DONE = 4'b0100;
    localparam INIT_PROPERTIES = 4'b0101; 
    localparam CALCULATE_AREA = 4'b0110;
    localparam SEND_CHAIN_CODES_VIA_UART = 4'b0111;
    localparam FINILIZATION = 4'b1000;

    reg [7:0] i = 0, j, current_row_index, current_column_index;
    reg [5:0] start_x, start_y;
    reg [2:0] current_code;
    reg [11:0] current_area, chain_code_results_index = 0;
    reg found_first_pixel;
    reg [0:63] loaded_ram [0:63];
    reg [2:0] chain_code_results [0:4095];
    reg [3:0] state = 0, next_state;
    wire [63:0] rom_out;
    reg [5:0] rom_address;
	
	 rom rom (
		.clka(clk),
		.addra(rom_address),
		.douta(rom_out)
	);
			
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= INITIALIZATIONS;
        end else begin
            case (state)
				
                INITIALIZATIONS: begin
                    if (i > 1)
                        loaded_ram[i-2] <= rom_out;
                    if (i == 65)
                        next_state = WAITING;
                    else
                        next_state<= INITIALIZATIONS;
                    i <= i + 1;
                    rom_address <= i;
                    found_first_pixel <= 0;
                    perimeter <= 0;
                    done <= 0;
                end

                WAITING: begin
                    if (start) 
                        next_state = FIND_STARTING_PIXEL;
                    else 
                        next_state = WAITING;
                end

                FIND_STARTING_PIXEL: begin
                    for (i = 63; i != 0; i = i - 1)
                        for (j = 63; j != 0; j = j - 1) begin
                            if (loaded_ram[i][j] == 1'b1 && found_first_pixel == 1'b0) begin
                                    start_x <=i;
                                    start_y <= j;
                                    current_row_index <= i;
                                    current_column_index <= j;
                                    found_first_pixel <= 1;
                                    next_state = CALCULATE_CHAIN_CODES;
                            end
                        end		  
                end

                CALCULATE_CHAIN_CODES: begin
                    if (loaded_ram[current_row_index][current_column_index + 1] == 1'b1 &&  loaded_ram[current_row_index - 1][current_column_index + 1] == 1'b0) begin
                        current_code <= 3'b000;
                        current_column_index <= current_column_index + 1;
                    end else if (loaded_ram[current_row_index - 1][current_column_index + 1] == 1'b1 && loaded_ram[current_row_index - 1][current_column_index] == 1'b0) begin
                        current_code <= 3'b001;
                        current_row_index <= current_row_index - 1;
                        current_column_index <= current_column_index + 1;
                    end else if (loaded_ram[current_row_index - 1][current_column_index] == 1'b1 && loaded_ram[current_row_index - 1][current_column_index - 1] == 1'b0) begin
                        current_code <= 3'b010;
                        current_row_index <= current_row_index - 1;
                    end else if (loaded_ram[current_row_index - 1][current_column_index - 1] == 1'b1 && loaded_ram[current_row_index][current_column_index - 1] == 1'b0) begin
                        current_code <= 3'b011;
                        current_row_index <= current_row_index - 1;
                        current_column_index <= current_column_index - 1;
                    end else if (loaded_ram[current_row_index][current_column_index - 1] == 1'b1 && loaded_ram[current_row_index + 1][current_column_index - 1] == 1'b0) begin
                        current_code <= 3'b100;
                        current_column_index <= current_column_index - 1;
                    end else if (loaded_ram[current_row_index + 1][current_column_index - 1] == 1'b1 && loaded_ram[current_row_index + 1][current_column_index] == 1'b0) begin
                        current_code <= 3'b101;
                        current_row_index <= current_row_index + 1;
                        current_column_index <= current_column_index - 1;
                    end else if (loaded_ram[current_row_index + 1][current_column_index] == 1'b1 && loaded_ram[current_row_index + 1][current_column_index + 1] == 1'b0) begin
                        current_code <= 3'b110;
                        current_row_index <= current_row_index + 1;
                    end else if (loaded_ram[current_row_index + 1][current_column_index + 1] == 1'b1 && loaded_ram[current_row_index][current_column_index - 1] == 1'b0) begin
                        current_code <= 3'b111;
                        current_row_index <= current_row_index + 1;
                        current_column_index <= current_column_index + 1;
                    end
						  
                    perimeter <= perimeter + 1;

                    chain_code_results[chain_code_results_index-1] <= current_code;
                    chain_code_results_index <= chain_code_results_index + 1;
                    next_state = CHECK_DONE;
                end
					 
                CHECK_DONE: begin
                    if (current_row_index == start_x && current_column_index == start_y)
                        next_state = INIT_PROPERTIES;
                    else 
                        next_state = CALCULATE_CHAIN_CODES;
				    end
					 
					INIT_PROPERTIES: begin
                        i <= 0;
                        j <= 0;
                        area <= 0;
                        next_state = CALCULATE_AREA;						
					end
					 
					CALCULATE_AREA: begin
                        if (loaded_ram[i][j] == 1'b1)
                            area <= area + 1;
                        if (j == 63) begin
                            j <= 0;
                            i <= i + 1;
                        end else 
                            j <= j + 1;
                        if (i == 63 && j == 63) begin
                            next_state = SEND_CHAIN_CODES_VIA_UART;
                            i <= 0;
                        end else
                            next_state = CALCULATE_AREA;
					end
					 
                    SEND_CHAIN_CODES_VIA_UART: begin
						code <= {5'b00000, chain_code_results[i]};						 
						 if (i < perimeter+1) begin
                            done <= i>0 ? 1 : 0;
                            next_state = SEND_CHAIN_CODES_VIA_UART;
                            i <= i + 1;
						 end else
                            next_state = FINILIZATION;		
						 end

                FINILIZATION: begin
                        next_state = FINILIZATION;
					 end

            endcase

            state <= next_state;
        end
    end

    assign error = area == 0 ? 1 : 0;
    assign startX = start_x;
    assign startY = start_y;

endmodule
