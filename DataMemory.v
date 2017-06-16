//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:		Oct 11, 2015
// Modified Date: 	Mar  3, 2016
// File Name:		DataMemory.v 
// Description: 
//
//	
// Revision: 		2.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module DataMemory (
	//INPUTs
	input clk,
	input wren,					//Write Enable
	input [31:0] address,	//Address to Register for Read/Write
	input [31:0] data_in,	//Data to be written in memory
	
	//OUTPUTs
	output [31:0] data_out 	//Data read from the memory
);
	parameter MEM_SIZE = 1024; //Data memory on 1 KWord defined per spec in practice 2
	
	reg  [31:0] Main_memory [0:MEM_SIZE-1];
	wire [11:0] real_address;  //Only 10 bits are necesary to mapp the entire data memory but 12 are necesary for word alignment
	
	assign real_address = (address[11:0] >> 2);
	
	always @(posedge clk) begin
		if(real_address < MEM_SIZE) begin
			if (wren)
				Main_memory[real_address] <= data_in;
		end
    end
	 
	 assign data_out = (real_address < MEM_SIZE) ? Main_memory[real_address] : 31'hx;
	 
endmodule