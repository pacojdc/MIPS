//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:		April 13, 2016
// File Name:		Extender_32b.v 
// Description: 
//						  
// Revision: 		1.1
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Extender_32b (
	//INPUTs
	input [15:0] InVal,	//
	input [5:0] opcode, //
	//OUTPUTs
	output [31:0] OutVal //
);
	localparam 	  ORI = 6'h0d,
				  ANDI= 6'h0c;
	
	assign OutVal = ((opcode == ORI) ||(opcode == ANDI)) ? {16'h0000,InVal}:
														   (InVal[15] == 1) ? {16'hFFFF,InVal}:
																			  {16'h0000,InVal};

endmodule
