
module Toggle
(
	// Input Ports
	input clk,
	input reset,
	input Signal_Pulse,

	// Output Ports
	output Toggle_Signal
);

reg Shot_reg;

/*------------------------------------------------------------------------------------------*/
/*Asignacion de estado*/

always@(posedge clk or negedge reset)
begin

if(reset == 1'b0) begin 
		Shot_reg <= 0;
end
else begin
	if(Signal_Pulse)
		Shot_reg <= !Shot_reg;
	end
end//end always
/*------------------------------------------------------------------------------------------*/


assign Toggle_Signal = Shot_reg;


endmodule




