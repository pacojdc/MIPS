 /******************************************************************
* Description
*	This module generates frequency of 1 Hz or 5 hz depending on the value of clkOut
*		add
*		addi
*		sub
*		ori
*		or
*		bne
*		beq
*		and
*		nor
* Version:
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	01/03/2014
******************************************************************/
 
 module ClockGenerator
 (
	input 	clk,
	input 	reset,
	input 	[1:0] Selector,
	output  clkOut,
	output  clkUART
 );
wire c0_sig;
wire Counter1Hz_wire;
wire Counter5Hz_wire;
wire Counter10Hz_wire;
wire Counter20Hz_wire;
wire CounterUART_wire;
reg Mux_Clk;

//PLL instance 
PLL PLL0(
	.inclk0(clk),
	.c0(c0_sig));

//DEBUG Clocks
///////////////1HZ/////////////////////
ClockDivider#(
	.Frequency(1))
	
ClockDivider_1Hz(
	.clk(c0_sig),
	.reset(reset),
	.Clock_Signal_IO(Counter1Hz_wire));
///////////////5HZ/////////////////////
ClockDivider#(
	.Frequency(5))
	
ClockDivider_5Hz
(
	.clk(c0_sig),
	.reset(reset),
	.Clock_Signal_IO(Counter5Hz_wire));
///////////////10HZ/////////////////////
ClockDivider#(
	.Frequency(10))
	
ClockDivider_10Hz
(
	.clk(c0_sig),
	.reset(reset),
	.Clock_Signal_IO(Counter10Hz_wire));
///////////////20HZ/////////////////////
ClockDivider#(
	.Frequency(20))
	
ClockDivider_20Hz
(
	.clk(c0_sig),
	.reset(reset),
	.Clock_Signal_IO(Counter20Hz_wire));
	
//UART Clock
ClockDivider#(
	.Frequency(9600))
	
ClockDivider_9600Hz
(
	.clk(c0_sig),
	.reset(reset),
	.Clock_Signal_IO(CounterUART_wire));


//MUX selector on DEBUG Clocks
always@(Counter1Hz_wire,Counter5Hz_wire) begin
	case(Selector)
		2'b00: Mux_Clk = Counter5Hz_wire;
		2'b01: Mux_Clk = Counter1Hz_wire;
		2'b10: Mux_Clk = Counter10Hz_wire;
		2'b11: Mux_Clk = Counter20Hz_wire;
		default: Mux_Clk = Counter1Hz_wire;
	endcase
end


assign clkOut = Mux_Clk;
assign clkUART = CounterUART_wire;
 
endmodule