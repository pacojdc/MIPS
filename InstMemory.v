//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:		Oct 11, 2015
// Modified Date:    Mar  3, 2016
// File Name:		InstMemory.v 
// Description: 
//
//						  
// Revision: 		2.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module InstMemory (
	//INPUTs
	input [31:0] address,	//Address to Register for Read/Write
	
	//OUTPUTs
	output [31:0] data_out 	//   Data read from the memory
);

	parameter MEM_SIZE = 256;

	reg [31:0] Main_memory [0:MEM_SIZE-1];
	reg [31:0] data_oreg;
	wire [31:0] real_address;
	
	//Load Program with text.dat for simulation. How to do it on FPGA??
	initial begin
		$readmemh("text.dat", Main_memory);
	end
	
	assign real_address = (address & 32'hFFBFFFFF) >> 2; //Change to support SP and data memory addressing
	
	always @(*) begin
		if(real_address < MEM_SIZE)
        data_oreg <= Main_memory[real_address];
		else
		  data_oreg <= 32'hx;
    end
	 
	 assign data_out = data_oreg;
endmodule