module IOMemory(
    clk, reset, isHex, isLedr, isLedg, isSwitches, switches, keys, dataIn,
    ledr, ledg, hex0, hex1, hex2, hex3, ioOut
);

    parameter DATA_BIT_WIDTH;

    input clk;
    input reset;
    input isHex;
    input isLedr;
    input isLedg;
    input isSwitches;
    input[DATA_BIT_WIDTH - 1:0] dataIn;
    output[DATA_BIT_WIDTH - 1:0] ioOut;

    input[9:0] switches;
    input[3:0] keys;
    output[6:0] hex0;
    output[6:0] hex1;
    output[6:0] hex2;
    output[6:0] hex3;
    output[9:0] ledr;
    output[7:0] ledg;

    Register #(7, 7'b0) regHex0(clk, reset, isHex, dataIn[6:0], hex0);
    Register #(7, 7'b0) regHex1(clk, reset, isHex, dataIn[14:8], hex1);
    Register #(7, 7'b0) regHex2(clk, reset, isHex, dataIn[22:16], hex2);
    Register #(7, 7'b0) regHex3(clk, reset, isHex, dataIn[30:24], hex3);
    Register #(10, 10'b0) regLEDR(clk, reset, isLedr, dataIn[9:0], ledr);
    Register #(8, 8'b0) regLEDG(clk, reset, isLedg, dataIn[7:0], ledg);
    
    wire[9:0] switchesOut;
    Register #(10, 10'b0) regSwitches(clk, reset, 1'b1, switches, switchesOut);
    wire[3:0] keysOut;
    Register #(4, 4'b0) regKeys(clk, reset, 1'b1, keys, keysOut);

    assign ioOut = isSwitches ? {22'b0, switchesOut} : {28'b0, keysOut};

endmodule
