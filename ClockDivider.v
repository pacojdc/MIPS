
module ClockDivider
#(
	parameter Frequency = 1500000

)
(
	input clk, reset,
	
	output Clock_Signal_IO

);

localparam ticks =  10000000/Frequency;
wire Pulse_wire;
wire Clock_Signal_wire;

Up_Counter
#(
	.Half_Period(ticks >> 1)
)
Counter
(
	.clk(clk), 
	.reset(reset),
	
	.Pulse(Pulse_wire)

);



Toggle
FF_Toggle
(
	// Input Ports
	.clk(clk),
	.reset(reset),
	.Signal_Pulse(Pulse_wire),

	// Output Ports
	.Toggle_Signal(Clock_Signal_wire)
);


assign Clock_Signal_IO = Clock_Signal_wire;




endmodule

