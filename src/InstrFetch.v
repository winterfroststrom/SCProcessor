module InstrFetch(clk, reset, imm, useImm, pcOut);
    
    parameter DBITS     = 32;
    parameter START_PC  = 32'h40;

    input clk;
    input reset;
    input[31:0] imm;
    input useImm;

    output[DBITS - 1:0] pcOut;

    wire pcWrtEn = ~reset;
    wire[DBITS - 1: 0] pcIn;

    PCLogic pcLogic (pcOut, imm, useImm, pcIn);
    Register #(.BIT_WIDTH(DBITS), .RESET_VALUE(START_PC)) pc (
        clk, reset, pcWrtEn, pcIn, pcOut
    );

endmodule
