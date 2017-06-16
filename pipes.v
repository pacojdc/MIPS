//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:		April  13, 2016
// File Name:		pipes.v 
// Description: 
//
//	
// Revision: 		1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module pipe_IF_ID (
	input  clk,
	input  async_rst,
	input  sync_rst,
	input  [31:0] Inst_IF,
	input  [31:0] PC_Exec_Plus4_IF,
	output [31:0] Inst_ID,
	output [31:0] PC_Exec_Plus4_ID);
	
	reg [31:0] rInst_ID;
	reg [31:0] rPC_Exec_Plus4_ID;
	
	always @(negedge clk or negedge async_rst) begin
		if (~async_rst) begin
			rInst_ID <= 0;
			rPC_Exec_Plus4_ID <= 0;
		end else begin
			if (~sync_rst) begin
				rInst_ID <= 0;
				rPC_Exec_Plus4_ID <= 0;
			end else begin
				rInst_ID <= Inst_IF;
				rPC_Exec_Plus4_ID <= PC_Exec_Plus4_IF;
			end
		end
	end
	
	assign Inst_ID = rInst_ID;
	assign PC_Exec_Plus4_ID = rPC_Exec_Plus4_ID;
endmodule


module pipe_ID_EX(
	input  clk,
	input  async_rst,
	input  sync_rst,
	input  [16:0] FullCtrl_ID,
	input  [31:0] ValReg1_ID,
	input  [31:0] ValReg2_ID,
	input  [31:0] Inst_ID,
	input  [31:0] PC_Exec_Plus4_ID,
	input  [31:0] DataExt_ID,
	
	output [16:0] FullCtrl_EX,
	output [31:0] ValReg1_EX,
	output [31:0] ValReg2_EX,	
	output [31:0] Inst_EX,
	output [31:0] PC_Exec_Plus4_EX,
	output [31:0] DataExt_EX);
	
	reg [31:0] rPC_Exec_Plus4_EX, rDataExt_EX;
	reg [31:0] rValReg1_EX, rValReg2_EX, rInst_EX;
	reg [16:0] rFullCtrl_EX;
	
	always @(negedge clk or negedge async_rst) begin
		if (~async_rst) begin
			rDataExt_EX <= 0;
			rFullCtrl_EX <= 0;
			rValReg1_EX <= 0;
			rValReg2_EX <= 0;
			rInst_EX <= 0;
			rPC_Exec_Plus4_EX <= 0;
		end else begin
			if (~sync_rst) begin
				rDataExt_EX <= 0;
				rFullCtrl_EX <= 0;
				rValReg1_EX <= 0;
				rValReg2_EX <= 0;
				rInst_EX <= 0;
				rPC_Exec_Plus4_EX <= 0;
			end else begin
				rDataExt_EX 	<=  DataExt_ID;
				rFullCtrl_EX 	<=	FullCtrl_ID;
			    rValReg1_EX 	<=  ValReg1_ID;
			    rValReg2_EX 	<=  ValReg2_ID;
				rInst_EX 		<= 	Inst_ID;
				rPC_Exec_Plus4_EX <=PC_Exec_Plus4_ID ;
			end
		end
	end
	
	assign FullCtrl_EX = rFullCtrl_EX;
	assign ValReg1_EX = rValReg1_EX;
	assign ValReg2_EX = rValReg2_EX;
	assign Inst_EX = rInst_EX;
	assign PC_Exec_Plus4_EX = rPC_Exec_Plus4_EX;
	assign DataExt_EX = rDataExt_EX;
	
endmodule

module pipe_EX_MEM (
	input  clk,
	input  async_rst,
	input  sync_rst,
	input  [2:0]  Control_EX,
	input  [31:0] ALURes_EX,
	input  [31:0] WriteData_EX,
	input  [4:0]  DestReg_EX,
	input  [5:0]  opcode_EX,
	output [2:0]  Control_MEM,
	output [31:0] ALURes_MEM,
	output [31:0] WriteData_MEM,
	output [4:0]  DestReg_MEM,
	output [5:0]  opcode_MEM
	);
	
	reg [31:0] rALURes_MEM, rWriteData_MEM;
	reg [2:0] rControl_MEM;
	reg [4:0] rDestReg_MEM;
	reg [5:0] ropcode_MEM;
	always @(negedge clk or negedge async_rst) begin
		if (~async_rst) begin
			rControl_MEM <= 0;
			rDestReg_MEM <= 0;
			rALURes_MEM <= 0;
			rWriteData_MEM <= 0;
			ropcode_MEM <= 0;
		end else begin
			if (~sync_rst) begin
				rControl_MEM <= 0;
				rDestReg_MEM <= 0;
				rALURes_MEM <= 0;
				rWriteData_MEM <= 0;
				ropcode_MEM <= 0;
			end else begin
				rControl_MEM <= Control_EX;
				rDestReg_MEM <= DestReg_EX;
				rALURes_MEM <= ALURes_EX;
				rWriteData_MEM <= WriteData_EX;
				ropcode_MEM <= opcode_EX;
			end
		end
	end
	
	assign Control_MEM = rControl_MEM;
	assign DestReg_MEM = rDestReg_MEM;
	assign ALURes_MEM =  rALURes_MEM;
	assign WriteData_MEM = rWriteData_MEM;
	assign opcode_MEM = ropcode_MEM;
endmodule


module pipe_MEM_WB (
	input  clk,
	input  async_rst,
	input  sync_rst,
	input  [1:0]  Control_MEM,
	input  [31:0] MemData_MEM,
	input  [31:0] ALUData_MEM,
	input  [4:0]  WrAddReg_MEM,
	output [1:0]  Control_WB,
	output [31:0] MemData_WB,
	output [31:0] ALUData_WB,
	output [4:0]  WrAddReg_WB
	);
	
	reg [31:0] rMemData_WB, rALUData_WB;
	reg [1:0] rControl_WB;
	reg [4:0] rWrAddReg_WB;
	always @(negedge clk or negedge async_rst) begin
		if (~async_rst) begin
			rControl_WB <= 0;
			rMemData_WB <= 0;
			rALUData_WB <= 0;
			rWrAddReg_WB <= 0; 
		end else begin
			if (~sync_rst) begin
				rControl_WB <= 0;
				rMemData_WB <= 0;
				rALUData_WB <= 0;
				rWrAddReg_WB <= 0; 
			end else begin
				rControl_WB <= Control_MEM;
				rMemData_WB <= MemData_MEM;
				rALUData_WB <= ALUData_MEM;
				rWrAddReg_WB <= WrAddReg_MEM; 
			end
		end
	end
	
	assign Control_WB = rControl_WB;
	assign MemData_WB = rMemData_WB;
	assign ALUData_WB = rALUData_WB;
	assign WrAddReg_WB = rWrAddReg_WB; 
	
endmodule