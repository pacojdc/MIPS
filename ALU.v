//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:		Oct 11, 2015
// Modified Date: Mar  3, 2016
// File Name:		ALU.v 
// Description: 
//	ALU ctl - Function
//		0000 - AND
//		0001 - OR
//		0010 - add
//		0110 - subtract
//		0111 - set on less than
//		1100 - NOR
//						  
// Revision: 		2.0
// Additional Comments: 
// Added Shift function into ALU, supporting the OpSelect directly from "funct" on Instruction
//
//////////////////////////////////////////////////////////////////////////////////

module ALU (
	//INPUTs
	input [31:0] A,		//R[rs]
	input [31:0] B,		//R[rt]
	input [5:0] OpSel,	//Operation Selector
	input [4:0] shamt,	//Shift Amount
	//OUTPUTs
	output zero, 			//Zero for BEQ & BNE
	output [31:0] Res 	//R[rd]
);
	//Codification for ALU Operation
	localparam AND = 6'h24, //CONC= for LUI instruction is a sll with shamt 16 
				   OR = 6'h25, 
				  ADD = 6'h20, 
				  SUB = 6'h22, 
				  SLT = 6'h2a, 
				  NOR = 6'h27,
				  SRL = 6'h2,
				  SLL = 6'h0;
				  
	reg [31:0] Res_out;

	wire [31:0] and_wire;
	wire [31:0] or_wire;
	wire [31:0] slt_wire;
	wire [31:0] nor_wire;
	wire [31:0] srl_wire;
	wire [31:0] sll_wire;
	wire [31:0] sum_sub_wire;
	wire [31:0] B_wire;
	wire carry;
	
	assign and_wire = A & B;
	assign or_wire  = A | B;
	assign slt_wire = (A < B)?  1 : 0;
	assign nor_wire = ~(A | B);
	assign srl_wire = B >> shamt;
	assign sll_wire = B << shamt;
	
	//Calculating 2's complement on B_wire if it's a substraction (except for 0)
	assign B_wire = (OpSel == SUB)? ((B==0)? 0 : ~B+1):B;
	//Adder for sum and substraction
	Adder32bits Sum(
		.A_in(A),		
		.B_in(B_wire),		
		.Res_out(sum_sub_wire),	
		.Carry(carry));
	
	assign Res =	(OpSel == AND)? and_wire:
						(OpSel == OR)? or_wire:
						(OpSel == ADD)? sum_sub_wire:
						(OpSel == SUB)? sum_sub_wire:
						(OpSel == SLT)? slt_wire:
						(OpSel == NOR)? nor_wire:
						(OpSel == SRL)? srl_wire:
						(OpSel == SLL)? sll_wire:32'hx;
						
	assign zero = (OpSel == SUB)? ((sum_sub_wire == 32'h0)? 1'b1 : 1'b0): 1'b0;

endmodule