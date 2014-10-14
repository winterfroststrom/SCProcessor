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
	wire isSW = op1[0] & op1[2];
    
    // InstrFetch
    output useImmPc;
    assign useImmPc = (isBranch & outCond) | isJAL;
    output[DBITS - 1:0] pcIn;
    assign pcIn = isJAL ? outAlu : imm32;

    // RegFetch
    output wrtEnReg;
    assign wrtEnReg = ~op1[2] & lock;
    output[31:0] wrtReg;
    assign wrtReg =
        op1[0] ? (op1[1] ? pcOut : outMem) : // JAL, LW
        outAlu;
 
    // Execute
    output isMvhi;
    assign isMvhi = op1[3] & ~op1[1] & op2[0] & op2[1];
    output useZeroExe;
    assign useZeroExe = (isBranch & op2[2]) | isMvhi;
    output useImmExe;
    assign useImmExe = op1[3] | isSW;
    output isBranchOrCond;
    assign isBranchOrCond = op1[1] & ~op1[0];
    output[OP_BIT_WIDTH - 1:0] opAlu;
    assign opAlu = isBranchOrCond ? OP2_SUB : op2;
    output[OP_BIT_WIDTH - 1:0] opCond;
    assign opCond = op2;

    // Memory
    output wrtEnMem;
    assign wrtEnMem = isSW & lock; // SW

endmodule
