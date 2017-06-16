//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:	Oct 12, 2015
// Modified Date: Mar  3, 2016
// File Name:		MainALUControl.v 
// Description: 
//		Changed values on Control for ALUOp and OpSel
// Revision: 		2.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module MainALUControl (
	//INPUTs
	input [5:0] funct,
	input [4:0] I_shamt,
	input [5:0] ALUOp,
	//OUTPUTs
	output [5:0] OpSel,
	output [4:0] shamt 
	);
	
	//Values for ALUOp from Main control unit depending on type of instruction
	localparam ZER_R = 6'h0,
			   SUB_R = 6'h1,
			   SLL_R = 6'h2,
			   ADD_R = 6'h4,
			   AND_R = 6'h8,
			   OR_R  = 6'h10,
			   R_TYP = 6'h20;
	
	//Codification for ALU Operation
	localparam AND = 6'h24, //CONC= for LUI instruction is a sll with shamt 16 
				   OR = 6'h25, 
				  ADD = 6'h20, 
				  SUB = 6'h22,
				  SLL = 6'h0;
	
	reg [5:0] OpSel_reg;
	
	//Truth Table from FIGURE 4.12 P.260 and table 4.13 P.261 
	always @(*) begin
		case(ALUOp)  //Check if we can use casex for x1 and 1x
			ZER_R: OpSel_reg = 6'h0;
			ADD_R: OpSel_reg = ADD;
			SUB_R: OpSel_reg = SUB;
			SLL_R: OpSel_reg = SLL;
			OR_R: OpSel_reg  = OR;
			AND_R: OpSel_reg = AND;		
			R_TYP: begin
				if (funct != 6'h08) //JR  = 6'h08
					OpSel_reg = funct;
				else
					OpSel_reg = AND; //Support for JR instruction to be compatible with other R type instructions
			end
			default: OpSel_reg = 6'hx;
		endcase
	end
	
	assign OpSel = OpSel_reg;
	assign shamt = (ALUOp == SLL_R)? 5'h10: I_shamt; //Support for LUI instruction
	
endmodule