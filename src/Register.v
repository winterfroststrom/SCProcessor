module Register(clk, reset, wrtEn, dataIn, dataOut);
	parameter BIT_WIDTH = 32;
	parameter RESET_VALUE = 0;
	
	input clk, reset, wrtEn;
	input[BIT_WIDTH - 1: 0] dataIn;
	output[BIT_WIDTH - 1: 0] dataOut;
	reg[BIT_WIDTH - 1: 0] dataOut = RESET_VALUE;	
    
	always @(posedge clk) begin
		if (reset)
			dataOut <= RESET_VALUE;
		else if (wrtEn)
			dataOut <= dataIn;
	end
	
endmodule