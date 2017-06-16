/******************************************************************
* Description
*	This module transform the binary output into a hexadecimal value to be shown in the 7-segment displays
* Version:
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	01/03/2014
******************************************************************/


module Displays
(
	input [7:0] BinaryInput,
	output SignOut,
	output [6:0] DisplayUnits,
	output [6:0] DisplayTens
);
wire [3:0] BCDUnit_wire;
wire [3:0] BCDTens_wire;
wire [7:0] BinaryInputComplement_wire;
reg Sign;

assign SignOut = Sign;

always@(*)begin
	if(BinaryInput[7]) begin
		Sign = 1;
	end
	else begin
		Sign = 0;
	end
end

assign BinaryInputComplement_wire = BinaryInput;

BCDTo7Segments
Units
(
	.BCD(BCDUnit_wire),
	.Segments(DisplayUnits)

);

BCDTo7Segments
Tens
(
	.BCD(BCDTens_wire),
	.Segments(DisplayTens)

);


BinaryCoder
BinCoder
(
	//Input Ports
	.BinaryNumber(BinaryInputComplement_wire),
	
	//Output Ports
	.Units(BCDUnit_wire),
	.Tens(BCDTens_wire)
);

endmodule