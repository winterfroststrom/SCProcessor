module InstrFetch(clk, reset, pcWrtEn, useImm, imm, isJal, pcAdded, pcOut);
    
    parameter DBITS     = 32;
    parameter START_PC  = 32'h40;

    input clk;
    input reset, pcWrtEn;
    input[DBITS - 1:0] imm;
    input useImm, isJal;

    output[DBITS - 1:0] pcAdded, pcOut;

    wire[DBITS - 1: 0] pcIn;
    
    PCLogic pcLogic (pcOut, imm, useImm, isJal, pcAdded, pcIn);
    
    
    Register #(.BIT_WIDTH(DBITS), .RESET_VALUE(START_PC)) pc (
        clk, reset, pcWrtEn, pcIn, pcOut
    );

    
endmodule
