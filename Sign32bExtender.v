//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:	Oct 12, 2015
// File Name:		Sign32bExtender.v 
// Description: 
//						  
// Revision: 		1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Sign32bExtender (
	//INPUTs
	input [15:0] InVal,	//
	input [5:0] opcode,
	//OUTPUTs
	output [31:0] OutVal //
);
	localparam 
				  //Type I Operations
				  ORI = 6'h0d,
				  ANDI= 6'h0c;
	
	assign OutVal = ((opcode == ORI) ||(opcode == ANDI)) ? {16'h0000,InVal}:
																		    (InVal[15] == 1) ? {16'hFFFF,InVal}:{16'h0000,InVal};

endmodule
