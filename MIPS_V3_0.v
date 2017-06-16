//////////////////////////////////////////////////////////////////////////////////
// Author:			Francisco Delgadillo
// Create Date:	Oct 11, 2015
// Modified date  Mar 22, 2016
// File Name:		MIPs_TOP.v 
// Description: 
//   MIPs cpu Top
//						  
// Revision: 		3.0
// Additional Comments: MIPS processor with pipeline support compliant with data sheet and MARS simulator
// Instrucions Added (Not compliant):
// PIN
// POT
////////////////////////////////////////////////////////////////////////////////// 
 
 module MIPS_V3_0
(
	input rst,
	input clk,
	input enable,
	input [1:0] ClkSelector,
	input [7:0] pin_fpga,
	
	//Debug LEDs
	output [6:0] GreenLEDs,
	output [17:0] RedLEDs,
	
	//ALU output
	output [6:0] ALU_Nibble1_1,
	output [6:0] ALU_Nibble1_2,
	output [6:0] ALU_Nibble2_1,
	output [6:0] ALU_Nibble2_2,
	
	//Memory Output
	output [6:0] PortOut_Nibble_1,
	output [6:0] PortOut_Nibble_2,
	
	//UART Output
	output UART_TXD,
	output UART_RTS
);

	//FPGA Clocks
	wire ClkOut_wire;
	wire clkUART_wire;

	//MIPS connecting wires
	wire pout_valid;	
	wire [7:0] pin;
	wire [7:0] pout;
	wire [31:0] ALURes;

	
	wire UART_busy;
	wire write_UART;
	wire [7:0] UART_data;
	
	
	//Assigns from FPGA
	assign GreenLEDs[0] = ClkOut_wire;
	assign GreenLEDs[1] = ~rst;
	assign GreenLEDs[6:2] = 5'h0; 
	
   assign RedLEDs[7:0] = pin;
	assign RedLEDs[17]= enable;
	assign RedLEDs[15:14] = ClkSelector; 
	assign RedLEDs[13:8] = 7'h0; 
	assign RedLEDs[16] = 1'h0; 
	
//Clocks and OUTPUT for FPGA
ClockGenerator MainClk(
	.clk(clk),
	.reset(rst),
	.Selector(ClkSelector),
	.clkOut(ClkOut_wire),
	.clkUART(clkUART_wire));
	
UART_TX UART0(
   .uart_busy(UART_busy),		// High means UART is transmitting
   .uart_tx(UART_TXD),     	// UART transmit wire
	.uart_rts(UART_RTS),			// Set to transmit

   .uart_wr_i(write_UART),    // Raise to transmit byte
   .uart_dat_i(UART_data),   	// 8-bit data
	.ser_clk(clkUART_wire),		// 9600 baudios (provide a clk with the desired transfer rate
   .sys_rst_i(rst)        		// System reset  
);

//DISPLAY Output
Displays DisplayALU1(
	.BinaryInput(ALURes[7:0]),
	//.BinaryInput(8'hff),
	.DisplayUnits(ALU_Nibble1_1),
	.DisplayTens(ALU_Nibble1_2));

Displays DisplayALU2(
	.BinaryInput(ALURes[15:8]),
	//.BinaryInput({3'h0, UART_Enable ,3'h0, pout_valid}),
	.DisplayUnits(ALU_Nibble2_1),
	.DisplayTens(ALU_Nibble2_2));

Displays DisplayPortOut(
	.BinaryInput(pout),
	//.BinaryInput(8'hBB),
	.DisplayUnits(PortOut_Nibble_1),
	.DisplayTens(PortOut_Nibble_2));

// SW input
MIPS_input input_data(
	 .clk(ClkOut_wire),
	 .enable(enable),			//Write Enable
	 .rst(rst),
	 .data_in(pin_fpga),		//Data to be in flops
	 .data_out(pin)			//Data stable data out
);

UART_format_hanoi format(
	.clk(clkUART_wire),
	.rst(rst),
	.UART_busy(UART_busy),
	.valid(pout_valid),
	.data_in(pout),
	
	.data_UART(UART_data),
	.UART_Enable(write_UART)
);

MIPS MIPS0(
	.clk(ClkOut_wire),
	.rst(rst),
	.pin_valid(enable),
	.pin(pin),
	.pout(pout),
	.pout_valid(pout_valid),
	.ALURes(ALURes)
);

endmodule

/*/TEST UART :)
reg [7:0] values [0:15];
reg [3:0] counter;
reg toogle;
reg pout_valid_reg;	
reg [7:0] pout_reg;

always@(posedge ClkOut_wire or negedge rst) begin
	if (~rst) begin
			values[0] = 8'h1;
			values[1] = 8'h2;
			values[2] = 8'h0;
			values[3] = 8'h2;
			values[4] = 8'h4;
			values[5] = 8'h6;
			values[6] = 8'h7;
			values[7] = 8'h0;
			values[8] = 8'h5;
			values[9] = 8'h3;
			values[10] = 8'h8;
			values[11] = 8'h0;
			values[12] = 8'h9;
			values[13] = 8'h1;
			values[14] = 8'h0;
			values[15] = 8'h3;
			counter = 4'h0;
			toogle = 1'h0;
	end else begin
		if (toogle) begin
			pout_valid_reg = 1'h1;
			pout_reg = values[counter];
			counter = counter + 1; 
		end else begin
			pout_valid_reg = 1'h0;
			pout_reg = 8'h0;
		end
		toogle = ~toogle;
	end
end

assign pout_valid = pout_valid_reg;
assign pout = pout_reg;*/

