module IOMemory(
    clk, isHex, isLedr, isLedg, isSwitches, switches, keys, dataIn,
    ledr, ledg, hex0, hex1, hex2, hex3, ioOut
);

    parameter DATA_BIT_WIDTH;

    input clk;
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

    wire[3:0] regHex0Out;
    wire[3:0] regHex1Out;
    wire[3:0] regHex2Out;
    wire[3:0] regHex3Out;
    RegisterResetless #(4) regHex0(clk, isHex, dataIn[3:0], regHex0Out);
    RegisterResetless #(4) regHex1(clk, isHex, dataIn[7:4], regHex1Out);
    RegisterResetless #(4) regHex2(clk, isHex, dataIn[11:8], regHex2Out);
    RegisterResetless #(4) regHex3(clk, isHex, dataIn[15:12], regHex3Out);
    SevenSeg sevenSeg0(regHex0Out, hex0);
    SevenSeg sevenSeg1(regHex1Out, hex1);
    SevenSeg sevenSeg2(regHex2Out, hex2);
    SevenSeg sevenSeg3(regHex3Out, hex3);
    
    RegisterResetless #(10) regLEDR(clk, isLedr, dataIn[9:0], ledr);
    RegisterResetless #(8) regLEDG(clk, isLedg, dataIn[7:0], ledg);
    
    wire[9:0] switchesOut;
    RegisterWriteAlways #(10) regSwitches(clk, switches, switchesOut);
    wire[3:0] keysOut;
    RegisterWriteAlways #(4) regKeys(clk, keys, keysOut);

    assign ioOut = isSwitches ? {22'b0, switchesOut} : {28'b0, keysOut};

endmodule
