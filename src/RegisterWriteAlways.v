module RegisterWriteAlways(clk, dataIn, dataOut);
	parameter BIT_WIDTH = 32;
	
	input clk;
	input[BIT_WIDTH - 1: 0] dataIn;
	output[BIT_WIDTH - 1: 0] dataOut;
	reg[BIT_WIDTH - 1: 0] dataOut;
	
	always @(posedge clk) begin
		dataOut <= dataIn;
	end
	
endmodule