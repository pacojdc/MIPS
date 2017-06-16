//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:		April  13, 2016
// File Name:		branch_control.v 
// Description: 
//
//	
// Revision: 		1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


module branch_control (
	//INPUTs
	input Branch_ctrl,
	input zero,
	input [5:0]  opcode,
	//OUTPUT
	output branch_exec
	);

		localparam BEQ = 6'h04, BNE = 6'h05;
		reg rbranch_exec;
		
		always @(*) begin
			if (Branch_ctrl) begin
				if(opcode == BEQ) begin
					if (zero == 1'h1) begin 
						rbranch_exec = 1'h1;
					end else begin
						rbranch_exec = 1'h0;
					end
				end else if(opcode == BNE) begin
					if (zero == 1'h0) begin 
						rbranch_exec = 1'h1;
					end else begin
						rbranch_exec = 1'h0;
					end
				end else begin
					rbranch_exec = 1'h0;
				end
			end else begin
					rbranch_exec = 1'h0;
			end
		end
		
		assign branch_exec = rbranch_exec;
			
endmodule