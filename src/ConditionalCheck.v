module ConditionalCheck(opCond, in0, outCond);
    parameter DBITS;

    input[3:0] opCond;
    input[DBITS - 1: 0] in0;  // in0 = inA - inB in ALU

    output[0:0] outCond;
    
    // Comparing to zero is checked in Execute.v module which will set inB of the ALU as zero
    /*  00      01      10      11
    00  F       EQ      LT      LTE
    01          EQZ     LTZ     LTEZ
    10  T       NE      GTE     GT
    11          NEZ     GTEZ    GTZ
    */

    wire eq  = |{in0} ? 1'b0 : 1'b1; // if in0 | 0 is zero, then eq should be 1
    wire lt  = (in0[31]) ? 1'b1 : 1'b0; // Checks most sig bit 2s comp neg
    wire lte = eq | lt;

    wire condResult = 
        (opCond[1:0] == 2'b01) ? eq  :
        (opCond[1:0] == 2'b10) ? lt  :
        (opCond[1:0] == 2'b11) ? lte :
                                 1'b0;

    assign outCond = (opCond[3]) ? ~condResult : condResult;

endmodule