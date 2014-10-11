module PCLogic(pcOld, imm, isBranch, condVal, pcNew);
    parameter BIT_WIDTH = 32;

    input[(BIT_WIDTH - 1): 0] pcOld;
    input[(BIT_WIDTH - 1): 0] imm;
    input condVal, isBranch;

    output[BIT_WIDTH - 1:0] pcNew;

    assign pcNew = pcOld + ((isBranch & condVal) ? imm << 2 : 4);
endmodule
