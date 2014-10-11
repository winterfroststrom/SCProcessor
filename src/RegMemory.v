module RegMemory(clk, reset, isWrRegMem, addr, dataIn, regOut);

    parameter DATA_BIT_WIDTH;
    parameter DMEMADDRBITS;
    parameter DMEMWORDBITS;
    parameter DMEMWORDS;

    input clk;
    input reset;
    input isWrRegMem;
    input[DATA_BIT_WIDTH - 1:0] addr;
    input[DATA_BIT_WIDTH - 1:0] dataIn;
    output[DATA_BIT_WIDTH - 1:0] regOut;
    
    reg[DATA_BIT_WIDTH - 1:0] data[0: DMEMWORDS - 1];

    wire[DMEMADDRBITS - DMEMWORDBITS - 1:0] address;
    Register #(DMEMADDRBITS - DMEMWORDBITS, {(DMEMADDRBITS - DMEMWORDBITS){1'b0}})
    regAddr(
        clk, reset, 1'b1, addr[DMEMADDRBITS - 1:DMEMWORDBITS], address
    );
    wire[DATA_BIT_WIDTH - 1:0] dataInput;    
    Register #(DATA_BIT_WIDTH, {(DATA_BIT_WIDTH){1'b0}}) regData(
        clk, reset, 1'b1, dataIn, dataInput
    );
        
	always @ (negedge clk) begin
        if (reset) begin
            data[address] <= {(DATA_BIT_WIDTH){1'b0}};
        end else if (isWrRegMem) begin
            data[address] <= dataInput;
        end
    end

    assign regOut = data[address];
    
endmodule
