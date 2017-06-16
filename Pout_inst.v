//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:		April  13, 2016
// File Name:		Pout_inst.v 
// Description: 
//
//	
// Revision: 		2.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Pout_inst (
		input clk,
		input [31:0] mem_value,
		input [5:0] opcode,
		output [7:0] pout,
		output pout_valid
		);
		
	reg [7:0] pout_reg;
	reg pout_valid_reg;
	always @(posedge clk) begin
		pout_reg <= mem_value[7:0];
		pout_valid_reg <= (opcode == 6'h1E) ? 1'h1:1'h0;
	end
	assign pout = pout_reg;
	assign pout_valid = pout_valid_reg;
endmodule