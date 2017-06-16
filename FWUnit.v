//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:		April  16, 2016
// File Name:		FWUnit.v 
// Description: 
//
//	
// Revision: 		1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


module FWUnit (
	input  RegWrite_MEM,
	input  RegWrite_WB,
	input  [4:0] DstReg_MEM,
	input  [4:0] DstReg_WB,
	input  [4:0] Rt_EXE,
	input  [4:0] Rs_EXE,
	
	output [1:0] Mux_A,
	output [1:0] Mux_B
	);
	
	reg [1:0] rMux_A;
	reg [1:0] rMux_B;
	
	always @(*) begin
		if (RegWrite_MEM && (DstReg_MEM != 0) && (DstReg_MEM == Rs_EXE)) begin
			rMux_A = 2'b10;
		end else if(RegWrite_WB && (DstReg_WB != 0) && (DstReg_WB == Rs_EXE) && (DstReg_MEM != Rs_EXE)) begin 
			rMux_A = 2'b01;
		end else begin
			rMux_A = 2'b0;
		end
		if(RegWrite_MEM && (DstReg_MEM != 0) && (DstReg_MEM == Rt_EXE)) begin 
			rMux_B = 2'b10;
		end else if(RegWrite_WB && (DstReg_WB != 0) && (DstReg_WB == Rt_EXE) && (DstReg_MEM != Rt_EXE)) begin 
			rMux_B = 2'b01;
		end else begin
			rMux_B = 2'b0;
		end
	end
	
	assign Mux_A = rMux_A;
	assign Mux_B = rMux_B;
endmodule