//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:		Oct 11, 2015
// Modified Date: 	Mar  3, 2016
// File Name:		GP_Regs.v 
// Description: 
//
//						  
// Revision: 		2.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module GP_Regs (
	//INPUTs
	input clk,
	input rst,
	input RegWrite,
	input JAL_write,
	input [4:0] ReadReg1,	//
	input [4:0] ReadReg2,	//
	input [4:0] WriteReg,	//
	input [31:0] data_in,	//
	input [31:0] RA_data,	//
	//OUTPUTs
	output [31:0] data_out1, 	//
	output [31:0] data_out2 	//
);

	reg [31:0] GP_Registers [0:31];

	always @(posedge clk or negedge rst) begin
		if (~rst) begin
			GP_Registers[5'h0] <= 32'h0;
			GP_Registers[5'h1] <= 32'h0;
			GP_Registers[5'h2] <= 32'h0;
			GP_Registers[5'h3] <= 32'h0;
			GP_Registers[5'h4] <= 32'h0;
			GP_Registers[5'h5] <= 32'h0;
			GP_Registers[5'h6] <= 32'h0;
			GP_Registers[5'h7] <= 32'h0;
			GP_Registers[5'h8] <= 32'h0;
			GP_Registers[5'h9] <= 32'h0;
			GP_Registers[5'hA] <= 32'h0;
			GP_Registers[5'hB] <= 32'h0;
			GP_Registers[5'hC] <= 32'h0;
			GP_Registers[5'hD] <= 32'h0;
			GP_Registers[5'hE] <= 32'h0;
			GP_Registers[5'hF] <= 32'h0;
			GP_Registers[5'h10] <= 32'h0;
			GP_Registers[5'h11] <= 32'h0;
			GP_Registers[5'h12] <= 32'h0;
			GP_Registers[5'h13] <= 32'h0;
			GP_Registers[5'h14] <= 32'h0;
			GP_Registers[5'h15] <= 32'h0;
			GP_Registers[5'h16] <= 32'h0;
			GP_Registers[5'h17] <= 32'h0;
			GP_Registers[5'h18] <= 32'h0;
			GP_Registers[5'h19] <= 32'h0;
			GP_Registers[5'h1A] <= 32'h0;
			GP_Registers[5'h1B] <= 32'h0;
			GP_Registers[5'h1C] <= 32'h10008000;
			GP_Registers[5'h1D] <= 32'h7fffeffc;
			GP_Registers[5'h1E] <= 32'h0;
			GP_Registers[5'h1F] <= 32'h0;
		end else begin
			if(RegWrite) begin
				GP_Registers[WriteReg] <= data_in;
			end
			if (JAL_write) begin
				GP_Registers[5'h1F] <= RA_data;
			end
		end
	end
	
	assign data_out1 = GP_Registers[ReadReg1];
	assign data_out2 = GP_Registers[ReadReg2];

endmodule