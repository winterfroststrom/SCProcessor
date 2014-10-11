module InstrFetch(clk, res, imm, pcMux, condVal, pcOut);
    
    parameter DBITS     = 32;
    parameter START_PC  = 32'h40;

    input clk;
    input res;
    input[31:0] imm;
    input pcMux;
    input condVal;

    output[DBITS - 1:0] pcOut;

    wire pcWrtEn = 1'b1;
    wire[DBITS - 1: 0] pcIn;

    PCLogic pcLogic (pcOut, imm, pcMux, condVal, pcIn);
    Register #(.BIT_WIDTH(DBITS), .RESET_VALUE(START_PC)) pc (clk, res, pcWrtEn, pcIn, pcOut);

endmodule
