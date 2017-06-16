//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:		Oct 11, 2015
// Modified Date:   April 13, 2016
// File Name:		MIPS.v 
// Description: 	
//   MIPS Top for a pipeline microprocessor
//						  
// Revision: 		3.0
// Additional Comments: 
//  IMPORTANT STAGES INFORMATION:
//		1st Instruction Fetch   (IF)
//		2nd Instruction Decode  (ID)
//		3rd Execute Instruction (EX)
//		4th Memory Access		(MEM)
//		5th Write Back			(WB)
//	All the stages are connected with proper Named Registers/Flops 
//  Complementary units are in special section called Improvement Performance Units (IPU) including forwarding unit, predictor and data harassment detector
//////////////////////////////////////////////////////////////////////////////////
/*ERRORS/BUGS FOUND
	1 JAL write back along with another instruction : Need to implement a hazard detection unit for wWrAddReg_WB == 1F or wWrAddReg_MEM== 1F or wFinalRDst== 1F enter nops until it reaches the instruction
	2 Branch is not working
	
	3 Test JAL and JR and Jmp
	4 Test all other instructions: add, addi, sub, or, ori, and, andi, nor, srl, sll, lw, sw, beq, bne, j, jal, jr
	
*/
////////MIPS TOP MODULE////////
module MIPS(
	input clk,
	input rst,
	input pin_valid,
	input  [7:0] pin,
	output pout_valid,
	output [7:0] pout,
	output [31:0] ALURes
);
/***********************Pipeline General Control*******************************/
wire flush_if_id, flush_id_ex, flush_ex_mem,flush_mem_wb;
assign flush_mem_wb = 1'h1;
assign flush_ex_mem = 1'h1;
assign flush_id_ex = 1'h1;
assign flush_if_id = 1'h1;
/***********************1st Stage Instruction Fetch*******************************/
///////IF DataPath Signals
	wire [31:0] wInst_IF, wPC_Next, wPC_Exec, wPC_Exec_Plus4_IF, wPC_PrevNext, wPC_Br_EX, wPC_JMP_ID, wPC_JR_ID;
///////IF Control Signals
	wire wBrEnable_EX, wPC_WrEn;
	wire [1:0] wJCtrl_ID;
///////IF Control Modules
	//Enable Branch to be executed
	Mux_2_to_1 #(32)
		PC_Bh_en(.in_0(wPC_PrevNext),
				 .in_1(wPC_Br_EX),
				 .sel(wBrEnable_EX),   
			     .out(wPC_Next));
	//Mux for JUMPS, Branchs, JR or PC+4
	Mux_4_to_1 #(32)
		PC_next_JP(.in_0(wPC_Exec_Plus4_IF),
				   .in_1(wPC_JR_ID),
				   .in_2(wPC_JMP_ID),
				   .in_3(32'hx),					
				   .sel(wJCtrl_ID),   //Error no ID for BRanch IF is proper
				   .out(wPC_PrevNext));

///////IF DataPath Modules	
	PC_Reg Program_Counter(
		.rst(rst),				//General Processor Reset
		.clk(clk), 				//Main processor clock
		.Wr_en(wPC_WrEn),
		.PC_in(wPC_Next),		//Program Counter input
		.PC_out(wPC_Exec));		//Program Counter to be executed this cycle
	//Instruction memory module
	InstMemory Instruction_mem(
		.address(wPC_Exec),		//Address to Register for Read/Write
		.data_out(wInst_IF));	//Data read from the memory
	//Adder + 4 to continue execution
	Adder32bits AdderPlus4(
		.A_in(wPC_Exec),
		.B_in(32'h4),
		.Res_out(wPC_Exec_Plus4_IF),
		.Carry());

/***********************1st-2nd Stage Transition IF_ID*******************************/
	wire [31:0] wIntr_ID, wPC_Exec_Plus4_ID;
	pipe_IF_ID pipe1(
		.clk(clk),
		.async_rst(rst),
		.sync_rst(flush_if_id),
		.Inst_IF(wInst_IF),
		.PC_Exec_Plus4_IF(wPC_Exec_Plus4_IF),
		.Inst_ID(wIntr_ID),
		.PC_Exec_Plus4_ID(wPC_Exec_Plus4_ID)); 

/***********************2nd Stage Instruction Decode*******************************/	
///////ID Control Signals
	wire wRegDst_ID, wALUSrc_ID, wMemtoReg_ID, wJal_ID, wMemRead_ID, wMemWrite_ID, wRegWrite_ID, wPINEN_ID,wBchCtrl_ID;
	wire wRegWrite_WB;
	wire [5:0] wALUOp_ID;
	wire [16:0] wControl_ID;
	wire [16:0] wControl;
	wire [16:0] wControl_EX;

///////ID DataPath Signals
	wire [5:0] opcode_ID, funct_ID,opcode_EX;
	wire [4:0] rs_ID, rt_ID, rd_ID, shamt_ID, wWrAddReg_WB, wFinalWrAddReg;
	wire [15:0] imme_ID;
	wire [25:0] jadd_ID;
	
	wire [31:0] wFinalRegData, wPIN, wWB_Data_WB;
	wire [31:0] wValReg1_ID, wValReg2_ID, wData_extended_ID;
	
	//Hazard Unit signals
	wire [4:0] rt_EX;
	wire wMemRead_EX, Mux_bubble,wNOP;
///////ID Control Modules
	//Main Control Unit
	MainControl Control(
		/**********INPUTs************/
		.opcode(opcode_ID),
		.funct(funct_ID),
		/**********OUTPUTs************/
		.FullControl(wControl)
	);
	
	assign {wRegDst_ID, wALUSrc_ID, wMemtoReg_ID, wJCtrl_ID, wJal_ID, wMemRead_ID, wMemWrite_ID, wRegWrite_ID, wALUOp_ID, wPINEN_ID, wBchCtrl_ID} = wControl_ID;
	
	//Main Hazard Unit for LW instruction
	DataHazardsUnit DataHzd(
		.MemRead_MEM(wMemRead_EX),
		.Rt_EXE(rt_EX),
		.Rt_ID(rt_ID),
		.Rs_ID(rs_ID),
		.opcode_ID(opcode_ID),
		.opcode_EX(opcode_EX),
		.wControl_EX(wControl_EX),
		.PC_Stall(wPC_WrEn),
		.MUX_Stall(Mux_bubble)
	);
	
	//Main Prediction Unit for BEQ and BNE instructions
	/*ControlPredictionUnit (
		.clk(clk),
		.rst(rst),
		.Real_Bch(wBrEnable_EX),
		.opcode_ID(opcode_ID),
		.opcode_EX(opcode_EX),
		.PC_Exec(wPC_Exec),
		.PC_Exec_EX(),
		.Dt_Ext(),
		.PC_ExecPls4(wPC_Exec_Plus4_IF),
		.PC_Pred_Mux(),
		.fsh_ifid(flush_if_id),
		.fsh_idex(flush_id_ex),
		.PC_Pred()
		);*/
	
	//Data IN mux for Register File
	Mux_2_to_1 #(17)
		Insert_BBl(.in_0(wControl),
				   .in_1(17'h0),
				   .sel((Mux_bubble|wNOP)),   
				   .out(wControl_ID));
				 
///////ID DataPath Assigns
	assign {opcode_ID, rs_ID, rt_ID, rd_ID, shamt_ID, funct_ID} = wIntr_ID;
	assign imme_ID = wIntr_ID[15:0];
	assign jadd_ID = wIntr_ID[25:0];
	assign wPIN = (pin_valid)?((pin[7] == 1)? {24'hFFFFFF,pin}:{24'h0,pin}): 32'h0; 
	assign wPC_JMP_ID = {wPC_Exec_Plus4_ID[31:28],(jadd_ID<<2)};
	assign wPC_JR_ID = wValReg1_ID;
	assign wNOP = (wIntr_ID)? 1'h0:1'h1;
///////ID DataPath Modules
	//Data IN mux for Register File
	Mux_2_to_1 #(32)
		Write_data(.in_0(wWB_Data_WB),
				   .in_1(wPIN),
				   .sel(wPINEN_ID),   
				   .out(wFinalRegData));
	//Register File
	GP_Regs General_Regs(
		.rst(rst),
		.clk(clk),
		.RegWrite(wRegWrite_WB),
		.JAL_write(wJal_ID),		
		.ReadReg1(rs_ID),	
		.ReadReg2(rt_ID),					
		.WriteReg(wWrAddReg_WB),			
		.data_in(wFinalRegData),
		.RA_data(wPC_Exec_Plus4_ID),
		.data_out1(wValReg1_ID), 				
		.data_out2(wValReg2_ID));
	//Extender for sign or Zero Extender	
	Extender_32b Extender0(
		.InVal(imme_ID),				//16bit
		.opcode(opcode_ID),
		.OutVal(wData_extended_ID));	//32bit

/***********************2nd-3rd Stage Transition ID_EX*******************************/
	wire [31:0] wValReg1_EX, wValReg2_EX, wPC_Exec_Plus4_EX, wData_extended_EX,wIntr_EX;
	pipe_ID_EX pipe2(
		.clk(clk),
		.async_rst(rst),
		.sync_rst(flush_id_ex),
		.FullCtrl_ID(wControl_ID),
		.ValReg1_ID(wValReg1_ID),
		.ValReg2_ID(wValReg2_ID),
		.Inst_ID(wIntr_ID),
		.PC_Exec_Plus4_ID(wPC_Exec_Plus4_ID),
		.DataExt_ID(wData_extended_ID),
		//OUTPUTS
		.FullCtrl_EX(wControl_EX),
		.ValReg1_EX(wValReg1_EX),
		.ValReg2_EX(wValReg2_EX),	
		.Inst_EX(wIntr_EX),
		.PC_Exec_Plus4_EX(wPC_Exec_Plus4_EX),
		.DataExt_EX(wData_extended_EX)); 

/***********************3rd Stage Instruction Execution****************************/
///////EX Control Signals
	wire wRegDst_EX, wALUSrc_EX, wMemtoReg_EX, wJal_EX, wMemWrite_EX, wRegWrite_EX, wPINEN_EX, wBchCtrl_EX;
	wire [5:0] wALUOp_EX;
	wire [1:0] wJCtrl_EX;
///////EX Control Signals
	assign {wRegDst_EX, wALUSrc_EX, wMemtoReg_EX, wJCtrl_EX, wJal_EX, wMemRead_EX, wMemWrite_EX, wRegWrite_EX, wALUOp_EX, wPINEN_EX, wBchCtrl_EX} = wControl_EX;

///////EX DataPath Signals
	wire [5:0] funct_EX;
	wire [4:0] rs_EX, rd_EX, shamt_EX, wFinalRDst;
	//FW wires
	wire [31:0] wALURes_MEM;
	wire [1:0] FW_MUX_A, FW_MUX_B;
	wire [4:0] wWrAddReg_MEM;
	wire wRegWrite_MEM;
	//ALU cables 
	wire [31:0] Operand_A, Operand_B, Result, preOperand_B;
	wire [5:0] wALUOp;
	wire [4:0] wALUshamt;
	wire Zero;
	
///////EX DataPath Assigns
	assign {opcode_EX, rs_EX, rt_EX, rd_EX, shamt_EX, funct_EX} = wIntr_EX;
	assign ALURes = Result;
	
///////EX Control Modules

	branch_control branch(
	.Branch_ctrl(wBchCtrl_EX),
	.opcode(opcode_EX),
	.zero(Zero),
	.branch_exec(wBrEnable_EX));
	
	MainALUControl ALU_Control(
		//INPUTs
		.funct(funct_EX),
		.I_shamt(shamt_EX),
		.ALUOp(wALUOp_EX),
		//OUTPUTs
		.OpSel(wALUOp),
		.shamt(wALUshamt)
	);
	
///////EX DataPath Modules
	//FW Unit
	FWUnit FW(
	.RegWrite_MEM(wRegWrite_MEM),
	.RegWrite_WB(wRegWrite_WB),
	.DstReg_MEM(wWrAddReg_MEM),
	.DstReg_WB (wWrAddReg_WB),
	.Rt_EXE(rt_EX),
	.Rs_EXE(rs_EX),
	.Mux_A(FW_MUX_A),
	.Mux_B(FW_MUX_B)
	);

	//Register Source
	Mux_2_to_1 #(5)
		Reg_Write (.in_0(rt_EX),
				   .in_1(rd_EX),
				   .sel(wRegDst_EX),   
				   .out(wFinalRDst));
	//Operand A for Forwarding Unit
	Mux_4_to_1 #(32)
		Data1_ALU (.in_0(wValReg1_EX),
				   .in_1(wWB_Data_WB),	//FW WB
				   .in_2(wALURes_MEM),	//FW MEM
				   .in_3(32'hx),		//NOT VALID!!
				   .sel(FW_MUX_A),   
				   .out(Operand_A));
	//Data B for Immediate or Reg2
	Mux_2_to_1 #(32)
		Data2_imm (.in_0(preOperand_B),
				   .in_1(wData_extended_EX),
				   .sel(wALUSrc_EX),   
				   .out(Operand_B));
	//Data B for Forwarding Unit
	Mux_4_to_1 #(32)
		Data2_ALU (.in_0(wValReg2_EX),
				   .in_1(wWB_Data_WB),	//FW WB
				   .in_2(wALURes_MEM),	//FW MEM
				   .in_3(32'hx),		//NOT VALID!!
				   .sel(FW_MUX_B),   
				   .out(preOperand_B));
	//Adder for Branch PC
	Adder32bits AdderForBranch(
		.A_in(wPC_Exec_Plus4_EX),
		.B_in((wData_extended_EX<<2)),
		.Res_out(wPC_Br_EX),
		.Carry());
	//Main ALU instance
	ALU ALU0_instance(
		.A(Operand_A),							
		.B(Operand_B),							
		.OpSel(wALUOp),					
		.shamt(wALUshamt),
		.zero(Zero),	 						
		.Res(Result));

/***********************3rd-4th Stage Transition EX_MEM****************************/
	wire [31:0] wWriteData_MEM;
	wire [2:0] wControl_MEM;
	wire [5:0] opcode_MEM;
	pipe_EX_MEM pipe3(
		.clk(clk),
		.async_rst(rst),
		.sync_rst(flush_ex_mem),
		.Control_EX({wMemtoReg_EX, wMemWrite_EX, wRegWrite_EX}),
		.ALURes_EX(Result),
		.WriteData_EX(preOperand_B),
		.DestReg_EX(wFinalRDst),
		.opcode_EX(opcode_EX),
		.Control_MEM(wControl_MEM),
		.ALURes_MEM(wALURes_MEM),
		.WriteData_MEM(wWriteData_MEM),
		.DestReg_MEM(wWrAddReg_MEM),
		.opcode_MEM(opcode_MEM)
		);

/***********************4th Stage Memory Access************************************/	
///////MEM Signals
	wire wMemtoReg_MEM, wMemWrite_MEM;
	wire [31:0] wMemData;
///////MEM  assignments
	assign {wMemtoReg_MEM, wMemWrite_MEM, wRegWrite_MEM} = wControl_MEM;

///////MEM Control Modules
	//POUT
	Pout_inst pout_i(
		.clk(clk),
		.mem_value(wMemData),
		.opcode(opcode_MEM),
		.pout(pout),
		.pout_valid(pout_valid));

///////EX DataPath Modules
	//MODULE TO PROGRAM DATA MIPs
	DataMemory Data_mem(
		.clk(clk),
		.wren(wMemWrite_MEM),	   	//Write Enable
		.address(wALURes_MEM),  	//Address to Register for Read/Write
		.data_in(wWriteData_MEM),	//Data to be written in memory
		.data_out(wMemData)			//Data read from the memory
		);

/***********************4th-5th Stage Transition MEM_WB*****************************/
	wire [31:0] wMemData_WB, wALURes_WB;
	wire [1:0] wControl_WB;
	pipe_MEM_WB pipe4(
		.clk(clk),
		.async_rst(rst),
		.sync_rst(flush_mem_wb),
		.Control_MEM({wMemtoReg_MEM, wRegWrite_MEM}),
		.MemData_MEM(wMemData),
		.ALUData_MEM(wALURes_MEM),
		.WrAddReg_MEM(wWrAddReg_MEM),
		.Control_WB(wControl_WB),
		.MemData_WB(wMemData_WB),
		.ALUData_WB(wALURes_WB),
		.WrAddReg_WB(wWrAddReg_WB)
	);
/***********************5th Stage Write Back***************************************/
///////WB Signals
	wire wMemtoReg_WB;
///////WB  assignments
	assign {wMemtoReg_WB, wRegWrite_WB} = wControl_WB;
////MUX for write back data
	Mux_2_to_1 #(32)
		WBack_mux (.in_0(wALURes_WB),
				   .in_1(wMemData_WB),
				   .sel(wMemtoReg_WB),   
				   .out(wWB_Data_WB));
endmodule
