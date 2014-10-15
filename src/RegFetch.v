module RegFetch(
    clk, wrtEn, isJal, rd, rs1, rs2, wrtData, imm16, outd, outReg1, outReg2, imm32Out
);

    parameter REG_INDEX_BIT_WIDTH;
    parameter DBITS;

    input clk;
    input wrtEn, isJal;

    input[REG_INDEX_BIT_WIDTH - 1: 0] rd, rs1, rs2;
    input[DBITS - 1: 0] wrtData;
    input[15: 0] imm16;

    output[DBITS - 1: 0] outd, outReg1, outReg2;
    output[DBITS - 1: 0] imm32Out;

    RegisterFile #(DBITS) registerFile (
        clk, wrtEn, rd, rs1, rs2, wrtData, outd, outReg1, outReg2
    );
    wire[DBITS - 1:0] imm32;
    SignExtension #(16, DBITS) signExtender (imm16, imm32);
    assign imm32Out = isJal ? imm32 << 2 : imm32;
endmodule