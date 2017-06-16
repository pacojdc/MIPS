//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:		Oct 11, 2015
// File Name:		Adder32bits.v 
// Description: 
//
//						  
// Revision: 		1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


module Adder32bits (
	//INPUTs
	input [31:0] A_in,	//
	input [31:0] B_in,	//
	
	//OUTPUTs
	output [31:0] Res_out,	//
	output Carry				//
);

	wire [32:0] Res_reg;

	assign Res_reg = {1'b0,B_in} + {1'b0,A_in};

	assign Res_out = Res_reg[31:0];
	assign Carry = Res_reg[32];
	
endmodule