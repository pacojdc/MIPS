

module Up_Counter
#(
	// Parameter Declarations
	parameter Half_Period = 2,
	parameter NBits=CeilLog2(Half_Period)
	
)

(
	// Input Ports
	input clk, reset,
	
	output Pulse

);

reg Max;
reg[NBits-1:0] Count;
always @ (posedge clk or negedge reset) begin
		if (reset==1'b0)
			Count = {NBits{1'b0}};
		else begin
				if(Count==Half_Period-1)
					Count= {NBits{1'b0}};
				else
					Count = Count + 1'b1;
		end
	end

//--------------------------------------------------------------------------------------------

always@(Count)
	begin
			 if (Count == Half_Period-1)
				Max = 1'b1;
			else 
				Max = 1'b0;
	end
//----------------------------------------------------------------------------------------------
assign Pulse = Max;
 /*--------------------------------------------------------------------*/
 /*--------------------------------------------------------------------*/
 /*--------------------------------------------------------------------*/
   
 /*Log Function*/
     function integer CeilLog2;
       input integer data;
       integer i,result;
       begin
          for(i=0; 2**i < data; i=i+1)
             result = i + 1;
          CeilLog2 = result;
       end
    endfunction

/*--------------------------------------------------------------------*/
 /*--------------------------------------------------------------------*/
 /*--------------------------------------------------------------------*/
endmodule




