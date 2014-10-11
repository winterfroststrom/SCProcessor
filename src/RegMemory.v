module RegMemory(clk, isWrRegMem, addr, dataIn, regOut);

    parameter DATA_BIT_WIDTH;
    parameter DMEMADDRBITS;
    parameter DMEMWORDBITS;
    parameter DMEMWORDS;

    input clk;
    input isWrRegMem;
    input[DATA_BIT_WIDTH - 1:0] addr;
    input[DATA_BIT_WIDTH - 1:0] dataIn;
    output[DATA_BIT_WIDTH - 1:0] regOut;
    
    reg[DATA_BIT_WIDTH - 1:0] data[0: DMEMWORDS - 1];

    wire[DMEMADDRBITS - DMEMWORDBITS - 1:0] address;
    RegisterWriteAlways #(DMEMADDRBITS - DMEMWORDBITS)
    regAddr(
        clk, addr[DMEMADDRBITS - 1:DMEMWORDBITS], address
    );
    wire[DATA_BIT_WIDTH - 1:0] dataInput;    
    RegisterWriteAlways #(DATA_BIT_WIDTH) regData(
        clk, dataIn, dataInput
    );
        
	always @ (negedge clk) begin
        if (isWrRegMem) begin
            data[address] <= dataInput;
        end
    end

    assign regOut = data[address];
    
endmodule
