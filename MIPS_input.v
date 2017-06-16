//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:		Mar 22, 2016
// Modified Date: 	
// File Name:		MIPS_input.v 
// Description: 
//
//	
// Revision: 		1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module MIPS_input (
	//INPUTs
	input clk,
	input enable,				//Write Enable
	input rst,
	input [7:0] data_in,		//Data to be in flops
	
	//OUTPUTs
	output [7:0] data_out 	//Data stable data out
);

	reg [7:0] data;

	always @(posedge clk or negedge rst) begin
		if (~rst) begin
			data <= 8'h0;
		end else begin
			if(enable) begin
				data <= data_in;
			end
		end
	end
	
	assign data_out = data;


endmodule