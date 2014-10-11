module PCLogic(pcOld, imm, pcMux, pcNew);
    parameter BIT_WIDTH = 32;

    input[(BIT_WIDTH - 1): 0] pcOld;
    input[(BIT_WIDTH - 1): 0] imm;
    input[0:0] pcMux;

    output pcNew;

    assign pcNew = pcOld + ((pcMux) ? 4 : imm << 2);
endmodule