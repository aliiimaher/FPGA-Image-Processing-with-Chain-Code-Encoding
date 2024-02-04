`timescale 1ns / 1ps

module main(
	input wire clk_1,
	input wire clk_8,
	input wire reset,
	input wire start	
);

	wire [7:0] code___from___chain_code_encoder___to___sender_uart;
	wire done___from___chain_code_encoder___to___sender_uart;
	wire [8:0] perimeter___from___chain_code_encoder___to___chain_code_decoder;
	wire [11:0] area___from___chain_code_encoder___to___chain_code_decoder;
	wire [5:0] startX___from___chain_code_encoder___to___chain_code_decoder;
	wire [5:0] startY___from___chain_code_encoder___to___chain_code_decoder;
	wire tx_out___from___sender_uart___to___receiver_uart;
	wire [7:0] rx_data___from___receiver_uart___to___chain_code_decoder;
	wire ready___from___receiver_uart___to___chain_code_decoder;	

	chain_code_encoder chain_code_encoder (
        .reset(reset), 
        .clk(clk_8), 
        .start(start), 
        .code(code___from___chain_code_encoder___to___sender_uart), 
        .done(done___from___chain_code_encoder___to___sender_uart), 
        .error(), 
        .perimeter(perimeter___from___chain_code_encoder___to___chain_code_decoder), 
        .area(area___from___chain_code_encoder___to___chain_code_decoder), 
        .startX(startX___from___chain_code_encoder___to___chain_code_decoder), 
        .startY(startY___from___chain_code_encoder___to___chain_code_decoder)
    );

	sender_uart sender_uart (
        .clk(clk_1), 
        .rst(reset), 
        .tx_data(code___from___chain_code_encoder___to___sender_uart), 
        .ready(done___from___chain_code_encoder___to___sender_uart), 
        .tx_out(tx_out___from___sender_uart___to___receiver_uart)
    );

	receiver_uart receiver_uart (
        .clk(clk_1), 
        .rst(reset), 
        .rx_in(tx_out___from___sender_uart___to___receiver_uart), 
        .rx_data(rx_data___from___receiver_uart___to___chain_code_decoder), 
        .ready(ready___from___receiver_uart___to___chain_code_decoder)
    );
	 
	 chain_code_decoder chain_code_decoder (
        .clk(clk_8), 
        .reset(reset), 
        .code(rx_data___from___receiver_uart___to___chain_code_decoder), 
        .start(ready___from___receiver_uart___to___chain_code_decoder), 
        .perimeter(perimeter___from___chain_code_encoder___to___chain_code_decoder), 
        .area(area___from___chain_code_encoder___to___chain_code_decoder), 
        .startX(startX___from___chain_code_encoder___to___chain_code_decoder), 
        .startY(startY___from___chain_code_encoder___to___chain_code_decoder), 
        .done(), 
        .error()
    );

endmodule
