
module BinaryCoder
(
	//Input Ports
	input [7:0]BinaryNumber,
	
	//Output Ports
	output [3:0]Units,
	output [3:0]Tens
);



assign Tens = BinaryNumber[7:4];
assign Units  = BinaryNumber[3:0];
	
endmodule
