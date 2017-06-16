module BCDTo7Segments
(
	input [3:0] BCD,
	output reg [6:0] Segments

);

always@(*) begin
	case(BCD)
		0: Segments = 7'b1_000_000;
		1: Segments = 7'b1_111_001;
		2: Segments = 7'b0_100_100;
		3: Segments = 7'b0_110_000;
		4: Segments = 7'b0_011_001;
		5: Segments = 7'b0_010_010;
		6: Segments = 7'b0_000_010;
		7: Segments = 7'b1_111_000;
		8: Segments = 7'b0_000_000;
		9: Segments = 7'b0_011_000;
		10: Segments = 7'b0_001_000;
		11: Segments = 7'b0_000_011;
		12: Segments = 7'b1_000_110;
		13: Segments = 7'b0_100_001;
		14: Segments = 7'b0_000_110;
		default:
			Segments = 7'b0_001_110;
		endcase	
end

endmodule