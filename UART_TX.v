module UART_TX(
   // Outputs
   output uart_busy,   // High means UART is transmitting
   output uart_tx,     // UART transmit wire
	output uart_rts,
   // Inputs
   input uart_wr_i,          // Raise to transmit byte
   input [7:0] uart_dat_i,   // 8-bit data
	input ser_clk,					//9600 baudios (provide a clk with the desired transfer rate
   input sys_rst_i           // System reset  
);

  reg [3:0] bitcount;
  reg [8:0] shifter;
  reg uart_tx_reg;
  reg rts_reg;

  always @(posedge ser_clk or negedge sys_rst_i)
  begin
    if (~sys_rst_i) begin
      uart_tx_reg <= 1;
      bitcount <= 0;
      shifter <= 0;
		rts_reg <= 0;
    end else begin
      // just got a new byte
      if (uart_wr_i & ~uart_busy) begin
        shifter <= { uart_dat_i[7:0], 1'h0 };
        bitcount <= 4'hA;
		  rts_reg <= 1;
      end else if (uart_busy)
		//Send NEW byte
      begin
			uart_tx_reg <= shifter[0];
			shifter <= {1'h1, shifter[8:1]};
			bitcount <= bitcount - 4'h1;
			rts_reg <= 0;
      end
    end
  end
  
  assign uart_tx = uart_tx_reg;
  assign uart_rts = rts_reg;
  assign uart_busy = (bitcount) ? 1'h1: 1'h0;

endmodule