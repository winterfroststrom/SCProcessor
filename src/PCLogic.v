module PCLogic(pcOld, imm, useImm, isJal, pcAdded, pcNew);
    parameter BIT_WIDTH = 32;

    input[(BIT_WIDTH - 1): 0] pcOld;
    input[(BIT_WIDTH - 1): 0] imm;
    input useImm, isJal;

    output[BIT_WIDTH - 1:0] pcNew;
    output[BIT_WIDTH - 1:0] pcAdded;
    assign pcAdded = pcOld + (useImm ? (imm + 1) << 2 : 4);
    assign pcNew = isJal ? imm : pcAdded;
endmodule
