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
    
    wire[DMEMADDRBITS - DMEMWORDBITS - 1:0] address;
    RegisterWriteAlways #(DMEMADDRBITS - DMEMWORDBITS)
    regAddr(
        clk, addr[DMEMADDRBITS - 1:DMEMWORDBITS], address
    );
    wire[DATA_BIT_WIDTH - 1:0] dataInput;    
    RegisterWriteAlways #(DATA_BIT_WIDTH) regData(
        clk, dataIn, dataInput
    );

    reg[DATA_BIT_WIDTH - 1:0] data[0: DMEMWORDS - 1];

    integer i;
    initial begin
        for (i = 0; i < DMEMWORDS; i = i + 1) begin
            data[i] = {(DATA_BIT_WIDTH){1'b0}};
        end
    end
    
	always @ (negedge clk) begin
        if (isWrRegMem) begin
            data[address] <= dataInput;
        end
    end

    assign regOut = data[address];
    
endmodule
