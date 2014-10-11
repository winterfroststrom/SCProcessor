module DataMemory(
    clk, wrMEM, addr, dataIn, switches, keys,
    ledr, ledg, hex0, hex1, hex2, hex3, dataOut
);
    parameter DATA_BIT_WIDTH                = 32;    
    parameter DMEMADDRBITS                  = 13;
    parameter DMEMWORDBITS                  = 2;
    parameter DMEMWORDS                     = 2048;

    input clk;
    input wrMEM;
    input[DATA_BIT_WIDTH - 1: 0] addr;
    input[DATA_BIT_WIDTH - 1:0] dataIn;
    input[9:0] switches;
    input[3:0] keys;
    output[9:0] ledr;
    output[7:0] ledg;
    output[6:0] hex0;
    output[6:0] hex1;
    output[6:0] hex2;
    output[6:0] hex3;
    output[DATA_BIT_WIDTH - 1:0] dataOut;
    
    wire isHex;
    wire isLedr;
    wire isLedg;
    wire isSwitches;
    wire isWrRegMem;
    wire isIoOut;
    DataMemoryController #(DATA_BIT_WIDTH) controller(
        wrMEM, addr,
        isHex, isLedr, isLedg, isSwitches, isWrRegMem, isIoOut
    );

    wire[DATA_BIT_WIDTH - 1:0] ioOut;
    IOMemory #(DATA_BIT_WIDTH) ioMem(
        clk, isHex, isLedr, isLedg, isSwitches, switches, keys, dataIn,
        ledr, ledg, hex0, hex1, hex2, hex3, ioOut
    );

    wire[DATA_BIT_WIDTH - 1:0] regOut;
    RegMemory #(DATA_BIT_WIDTH, DMEMADDRBITS, DMEMWORDBITS, DMEMWORDS) regMem(
        clk, isWrRegMem, addr, dataIn, regOut
    );
    
    assign dataOut = isIoOut ? ioOut : regOut;

endmodule
