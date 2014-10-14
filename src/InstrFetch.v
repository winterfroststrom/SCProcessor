module InstrFetch(clk, reset, useImm, imm, pcOld, pcOut);
    
    parameter DBITS     = 32;
    parameter START_PC  = 32'h40;

    input clk;
    input reset;
    input[31:0] imm, pcOld;
    input useImm;

    output[DBITS - 1:0] pcOut;

    wire pcWrtEn = 1'b1;
    wire[DBITS - 1: 0] pcIn;

    PCLogic pcLogic (pcOld, imm, useImm, pcIn);
    Register #(.BIT_WIDTH(DBITS), .RESET_VALUE(START_PC)) pc (
        clk, reset, pcWrtEn, pcIn, pcOut
    );

endmodule
