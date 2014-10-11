module RegMemory(clk, reset, isWrRegMem, addr, dataIn, regOut);

    parameter DATA_BIT_WIDTH;
    parameter DMEMADDRBITS;
    parameter DMEMWORDBITS;
    parameter DMEMWORDS;

    input clk;
    input reset;
    input isWrRegMem;
    input[DMEMADDRBITS:0] addr;
    input[DATA_BIT_WIDTH - 1:0] dataIn;
    output[DATA_BIT_WIDTH - 1:0] regOut;
    
    reg[DATA_BIT_WIDTH - 1:0] data[0: DMEMWORDS - 1];

    wire[DMEMADDRBITS - DMEMWORDBITS:0] address;
    Register #(DMEMADDRBITS - DMEMWORDBITS, 0) regAddr(clk, reset, 1'b1, addr[DMEMADDRBITS:DMEMWORDBITS], address);
    wire[DATA_BIT_WIDTH - 1:0] dataInput;    
    Register #(DATA_BIT_WIDTH, 0) regData(clk, reset, 1'b1, dataIn, dataInput);
        
	always @ (negedge clk) begin
        if (reset) begin
            data[address] <= 0;
        end else if (isWrRegMem) begin
            data[address] <= dataInput;
        end
    end

endmodule
