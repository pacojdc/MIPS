//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:		Mar 22, 2016
// Modified Date: 	
// File Name:		UART_format_hanoi.v 
// Description: 
//
//	
// Revision: 		1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module UART_format_hanoi(
	input clk,
	input rst,
	input UART_busy,
	input valid,
	input [7:0] data_in,
	
	output [7:0] data_UART,
	output UART_Enable

);

	reg UART_EnReg;
	reg [3:0] wait_new_data;
	reg [7:0] data_UART_reg;				  	
	
	assign UART_Enable = UART_EnReg;
	assign data_UART = data_UART_reg;
	
	
	always @(posedge clk or negedge rst) begin //POUT instructions must be separate one from another
		if (~rst) begin
			UART_EnReg <= 1'h0;
			wait_new_data <= 4'h0;
		end else begin
			if (valid) begin
				if ((~UART_busy) && (wait_new_data == 4'h0)) begin
					if (data_in == 8'h0) begin
						wait_new_data <= 4'h1;
						data_UART_reg <= 8'h30; 							//Start a new line if data in == 0 and Valid == 1
					end else begin
						wait_new_data <= 4'hf;
						data_UART_reg <= (data_in | 8'h30); 		//Support only for 9 disks if data in =!0 and Valid == 1
					end
					UART_EnReg <= 1'h1;
				end else if ((~UART_busy) && (wait_new_data < 4'h6)) begin
					wait_new_data <= wait_new_data + 1'h1;
					UART_EnReg <= 1'h0;
				end else if (wait_new_data == 4'h6) begin
					data_UART_reg <= 8'hA;
					UART_EnReg <= 1'h1;
					wait_new_data <= 4'h7;
				end else if ((~UART_busy) && (wait_new_data > 4'h6) && (wait_new_data < 4'hC)) begin
					wait_new_data <= wait_new_data + 1'h1;
					UART_EnReg <= 1'h0;
				end else if (wait_new_data == 4'hC) begin
					data_UART_reg <= 8'hD;
					UART_EnReg <= 1'h1;
					wait_new_data <= 4'hf;
				end else begin
					UART_EnReg <= 1'h0;
				end
			end else begin
				UART_EnReg <= 1'h0;
				data_UART_reg <= 8'h0;
				wait_new_data <= 4'h0; //Null Char if Valid == 0
			end
		end
	end
	
	
endmodule