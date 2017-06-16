//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:		Oct 12, 2015
// Modified Date: 	April  15, 2016
// File Name:		MainControl.v 
// Description: 
//						  
// Revision: 		3.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module MainControl (
	//INPUTs
	input [5:0] opcode,
	input [5:0] funct,
	//OUTPUTs
	output [16:0] FullControl
	);
	
	//Instructions to support with their OPcodes definition
	localparam
				  //Type I Operations
				  SW  = 6'h2b, 
				  LW  = 6'h23,
				  BEQ = 6'h04,
				  BNE = 6'h05,
				  LUI = 6'h0f,
				  ADDI= 6'h08,
				  ORI = 6'h0d,
				  ANDI= 6'h0c,
				  //Type J Operations
				  JMP = 6'h02,
				  JAL = 6'h03,
				  //Type R Operations
				  ROP = 6'h00, //Instructions Grouped with same opcode for R
				  //Type I/O Operations
				  PIN = 6'h1f,
				  POUT= 6'h1e;
				  			  
	//Values for ALUOp to send to ALU control unit depending on type of instruction
	localparam ZER_R = 6'h0,
			   SUB_R = 6'h1,
			   SLL_R = 6'h2,
			   ADD_R = 6'h4,
			   AND_R = 6'h8,
			   OR_R  = 6'h10,
			   R_TYP = 6'h20;

	//Values for Jump Control flow
	localparam JMP_R 	= 2'h1,
			   JMP_JAL	= 2'h2,
			   NT_VAL	= 2'h3,
			   PC_P4	= 2'h0;

	reg [16:0] rControl;
	
	always @(*) begin      			//Control Signals 
		case(opcode)	//Full truth table for main control on all the Instructions
			//Type R inst
			ROP: begin 
				if (funct == 6'h08) begin //Support for JR instruction
							 //{RegDst,ALUSrc,MemtoReg,JCtrl, Jal, MemRead,MemWrite,RegWrite,ALUOp,PIN_EN,wBchCtrl}
					rControl = { 1'h1,  1'h0,  1'h0,   JMP_R, 1'h0, 1'h0,   1'h0,    1'h0,   R_TYP, 1'h0,  1'h0};
				end else begin
							 //{RegDst,ALUSrc,MemtoReg,JCtrl, Jal, MemRead,MemWrite,RegWrite,ALUOp,PIN_EN,wBchCtrl}
					rControl = { 1'h1,  1'h0,  1'h0,   PC_P4, 1'h0, 1'h0,   1'h0,    1'h1,   R_TYP, 1'h0,  1'h0};
				end                                     
			end                                         
			//Type I inst	   {RegDst,ALUSrc,MemtoReg,JCtrl, Jal, MemRead,MemWrite,RegWrite,ALUOp, PIN_EN,wBchCtrl}
			BEQ: 	rControl = { 1'h0,  1'h0,  1'hx,   PC_P4,  1'h0, 1'h0,   1'h0,    1'h0,  SUB_R, 1'h0,    1'h1};
			BNE: 	rControl = { 1'h0,  1'h0,  1'hx,   PC_P4,  1'h0, 1'h0,   1'h0,    1'h0,  SUB_R, 1'h0,    1'h1};
			SW: 	rControl = { 1'h0,  1'h1,  1'hx,   PC_P4,  1'h0, 1'h0,   1'h1,    1'h0,  ADD_R, 1'h0,    1'h0};
			LW: 	rControl = { 1'h0,  1'h1,  1'h1,   PC_P4,  1'h0, 1'h1,   1'h0,    1'h1,  ADD_R, 1'h0,    1'h0};
			LUI:	rControl = { 1'h0,  1'h1,  1'h0,   PC_P4,  1'h0, 1'h0,   1'h0,    1'h1,  SLL_R, 1'h0,    1'h0};
			ADDI:	rControl = { 1'h0,  1'h1,  1'h0,   PC_P4,  1'h0, 1'h0,   1'h0,    1'h1,  ADD_R, 1'h0,    1'h0};
			ORI:	rControl = { 1'h0,  1'h1,  1'h0,   PC_P4,  1'h0, 1'h0,   1'h0,    1'h1,  OR_R , 1'h0,    1'h0};
			ANDI:	rControl = { 1'h0,  1'h1,  1'h0,   PC_P4,  1'h0, 1'h0,   1'h0,    1'h1,  AND_R, 1'h0,    1'h0};
		                                                
			//Type J inst	   {RegDst,ALUSrc,MemtoReg,JCtrl, Jal, MemRead,MemWrite,RegWrite,ALUOp,PIN_EN,wBchCtrl}
			JMP:	rControl = { 1'h0,  1'hx,  1'hx,   JMP_JAL, 1'h0, 1'h0,   1'h0,    1'h0,  ZER_R, 1'h0,    1'h0};
			JAL:	rControl = { 1'h0,  1'hx,  1'hx,   JMP_JAL, 1'h1, 1'h0,   1'h0,    1'h0,  ZER_R, 1'h0,    1'h0};
			                                            
			//Type I/O inst	  {RegDst,ALUSrc,MemtoReg, JCtrl, Jal, MemRead,MemWrite,RegWrite,ALUOp,PIN_EN,wBchCtrl}
			PIN: 	rControl = { 1'h0,  1'hx,  1'hx,   PC_P4, 1'h0, 1'h0,   1'h0,    1'h1,  ZER_R,  1'h1,    1'h0};
			POUT: 	rControl = { 1'h0,  1'h1,  1'hx,   PC_P4, 1'h0, 1'h0,   1'h0,    1'h0,  ADD_R,  1'h0,    1'h0};
			default: rControl = 17'hx;
		endcase
	end
	assign FullControl = rControl;
endmodule
