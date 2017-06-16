//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:		Oct 11, 2015
// Modified Date: 	Mar  3, 2016
// File Name:		PC_Decoder.v 
// Description: 
//  
//						  
// Revision: 		2.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module PC_Reg (
	//INPUTs
	input rst,
	input clk, 				//100Mhz
	input [31:0] PC_in,		//Program Counter 
	input Wr_en,
	
	//OUTPUTs
	output [31:0] PC_out	//Program Counter to be executed this cycle
);

	reg [31:0] PC;
	reg [31:0] Inst;
	
	always @ (posedge clk or negedge rst) begin
		if (~rst) begin
			PC <= 32'h400000;
		end else begin
			if (Wr_en) begin
				PC <= PC_in;
			end
		end
	end
	assign PC_out = PC;
endmodule