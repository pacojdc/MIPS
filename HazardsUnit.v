//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:		April  26, 2016
// File Name:		HazardsUnit.v 
// Description: 
//
//	
// Revision: 		1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module DataHazardsUnit (
	input  MemRead_MEM,
	input  [16:0] wControl_EX,
	input  [4:0]  Rt_EXE,
	input  [4:0]  Rt_ID,
	input  [4:0]  Rs_ID,
	input [5:0]  opcode_ID,
	input [5:0]  opcode_EX,
	output PC_Stall,
	output MUX_Stall
	);
	
	localparam BEQ = 6'h04, BNE = 6'h05;
	
	reg rPC_Stall;
	reg rMUX_Stall;
	always @(*) begin
		if (MemRead_MEM && ((Rt_EXE == Rt_ID) || (Rt_EXE == Rs_ID))) begin // DATA HAZARD Support for halting the pipe when LW is detected
			rPC_Stall  = 1'b0;  //Stalled
			rMUX_Stall = 1'b1;  //Control equal to bubble
		end else if ((opcode_EX == BNE) || (opcode_EX == BEQ)) begin 
			rPC_Stall  = 1'b1;  //NotStalled
			if (wControl_EX) begin	
				rMUX_Stall = 1'b1;  //Control equal to bubble
			end else begin
				rMUX_Stall = 1'b0; 	//Normal Control
			end
		end else if ((opcode_ID == BNE) || (opcode_ID == BEQ)) begin
			rPC_Stall  = 1'b0; 	//Stalled
			rMUX_Stall = 1'b0; 	//Normal Control
		end  else begin
			rPC_Stall  = 1'b1; 	//NotStalled
			rMUX_Stall = 1'b0; 	//Normal Control
		end
	end
	assign MUX_Stall = rMUX_Stall;    
	assign PC_Stall = rPC_Stall;
endmodule


/*
module ControlPredictionUnit (
	input clk,
	input rst,
	input Real_Bch,
	input [5:0]  opcode_ID,
	input [5:0]  opcode_EX,
	input [31:0] PC_ExecPls4_ID,
	input [31:0] PC_ExecPls4_EX,
	input [31:0] Dt_Ext,

	output [1:0] PC_Pred_Mux,
	output fsh_ifid,
	output fsh_idex,
	output [31:0] PC_Pred
	);
	
	localparam BEQ = 6'h04, BNE = 6'h05;
	localparam NTK = 1'h0, TKN = 6'h1;
	
	reg [59:0] Predict_Arr [0:7]; //{PredictionBit, [27]PC_withBch_Detected, [32]PC_Predicted}
	wire [2:0] Pred_elem_ID, Pred_elem_EX;
	reg rfsh_ifid;
	reg rfsh_idex;
	reg [1:0] rPC_Pred_Mux; 	
	wire [31:0] wPC_pred;
	
	always @(negedge clk or negedge rst) begin		//??? clk to have time to save the predicted instruction
		if (~rst) begin
			Predict_Arr[3'h0] <= 60'h0;
			Predict_Arr[3'h1] <= 60'h0;
			Predict_Arr[3'h2] <= 60'h0;
			Predict_Arr[3'h3] <= 60'h0;
			Predict_Arr[3'h4] <= 60'h0;
			Predict_Arr[3'h5] <= 60'h0;
			Predict_Arr[3'h6] <= 60'h0;
			Predict_Arr[3'h7] <= 60'h0;		
		end else begin
			if ((opcode_ID == BNE) || (opcode_ID == BEQ)) begin 
				if({Predict_Arr[Pred_elem_ID][58:32],Pred_elem_ID} != PC_ExecPls4_ID) begin
					if(Predict_Arr[Pred_elem_ID][59] == NTK) begin
						Predict_Arr[Pred_elem_ID][31:0] <= PC_ExecPls4_ID;
						Predict_Arr[Pred_elem_ID][58:32] <= PC_ExecPls4_ID[31:5];
					end else if(Predict_Arr[Pred_elem_ID][59] == TKN) begin
						Predict_Arr[Pred_elem_ID] [31:0] <= wPC_pred;
						Predict_Arr[Pred_elem_ID][58:32] <= PC_ExecPls4_ID[31:5];
					end
				end else
					rPC_Pred_Mux <= 1'h1;
				end
			end else begin
				rPC_Pred_Mux <= 1'h0;
			end
		end
	end
	
	always @(*) begin
		else if (((opcode_EX == BNE) || (opcode_EX == BEQ)) begin
			if(Real_Bch != Predict_Arr[Pred_elem_EX][59])) begin
				Predict_Arr[Pred_elem_EX][59] <= Real_Bch;
				rfsh_ifid  <= 1'b0;
				rfsh_idex  <= 1'b0;
			end else begin
				rfsh_ifid  <= 1'b1;
				rfsh_idex  <= 1'b1;
			end
		end else begin
		
		end
	end
	
	assign Pred_elem_ID = PC_ExecPls4_ID[4:2];
	assign Pred_elem_EX = PC_ExecPls4_EX[4:2];
	
	assign fsh_ifid = rfsh_ifid;
	assign fsh_idex = rfsh_idex;
	assign PC_Pred_Mux = rPC_Pred_Mux;
	assign PC_Pred = Predict_Arr[Pred_elem_ID][31:0];
	
	Adder32bits AdderForBranch(
		.A_in(PC_ExecPls4_ID),
		.B_in((Dt_Ext<<2)),
		.Res_out(wPC_pred),
		.Carry());
	
endmodule
*/