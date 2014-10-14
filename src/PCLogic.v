module PCLogic(pcOld, imm, useImm, pcNew);
    parameter BIT_WIDTH = 32;

    input[(BIT_WIDTH - 1): 0] pcOld;
    input[(BIT_WIDTH - 1): 0] imm;
    input useImm;

    output[BIT_WIDTH - 1:0] pcNew;

    assign pcNew = pcOld + (useImm ? (imm + 1) << 2 : 4);
endmodule
