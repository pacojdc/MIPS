//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:		April 13, 2016
// File Name:		Muxes.v 
// Description: 
//					Defines 2 to 1 and 4 to one parametizable muxes.
// Revision: 		1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Mux_2_to_1 #(parameter  WIDTH           = 32)
				   (
					input   [WIDTH-1:0]      in_0,
					input   [WIDTH-1:0]      in_1,
					input   				 sel,   
					output  [WIDTH-1:0]      out
					);
assign  out = (sel)? in_1 : in_0;
endmodule

module Mux_4_to_1 #(parameter  WIDTH           = 32)
				   (
					input   [WIDTH-1:0]      in_0,
					input   [WIDTH-1:0]      in_1,
					input   [WIDTH-1:0]      in_2,
					input   [WIDTH-1:0]      in_3,
					input   [1:0]			 sel,   
					output  [WIDTH-1:0]      out
					);
assign  out = (sel == 2'h0)? in_0 : 
			  (sel == 2'h1)? in_1:
			  (sel == 2'h2)? in_2:in_3;
endmodule