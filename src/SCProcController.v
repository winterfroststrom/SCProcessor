module SCProcController(
    lock, pcOut, op1, op2, imm32, outAlu, outCond, outMem,
    useImmPc, pcIn,
    wrtEnReg, wrtReg,
    useZeroExe, useImmExe, isMvhi, isBranchOrCond, opAlu, opCond,
    wrtEnMem
);

    parameter OP_BIT_WIDTH;
    parameter DBITS;
    parameter OP2_SUB;

    input lock;
    input[DBITS - 1:0] pcOut;
    input[OP_BIT_WIDTH - 1:0] op1, op2;
    input[DBITS - 1:0] imm32, outAlu;
    input outCond;
    input[DBITS - 1:0] outMem;
    
    wire isBranch = op1[2] & ~op1[0];
    wire isJAL = op1[1] & op1[0];

    // InstrFetch
    output useImmPc = (isBranch & outCond) | isJAL;
    output[DBITS - 1:0] pcIn = isJAL ? outAlu : imm32;

    // RegFetch
    output wrtEnReg = ~op1[2] & lock;
    output[31:0] wrtReg =
        op1[0] ? (op1[1] ? pcOut : outMem) : // JAL, LW
        outAlu;
 
    // Execute
    output isMvhi = op1[3] & ~op1[1] & op2[0] & op2[1];
    output useZeroExe = (isBranch & op2[2]) | isMvhi;
    output useImmExe = op1[3];
    output isBranchOrCond = op1[1] & ~op1[0];
    output[OP_BIT_WIDTH - 1:0] opAlu = isBranchOrCond ? OP2_SUB : op2;
    output[OP_BIT_WIDTH - 1:0] opCond = op2;

    // Memory
    output wrtEnMem = op1[0] & op1[2] & lock; // SW

endmodule
