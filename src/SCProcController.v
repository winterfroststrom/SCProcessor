module SCProcController(
    clk, lock, pcAdded, pcOut, op1, op2, imm32, outAlu, outCond, outMem,
    useImmPc, pcIn, isJal, pcWrtEn,
    wrtEnReg, wrtReg,
    useZeroExe, useImmExe, isMvhi, isBranchOrCond, opAlu, opCond,
    wrtEnMem
);

    parameter OP_BIT_WIDTH;
    parameter DBITS;
    parameter OP2_SUB;

    input lock, clk;
    input[DBITS - 1:0] pcAdded, pcOut;
    input[OP_BIT_WIDTH - 1:0] op1, op2;
    input[DBITS - 1:0] imm32, outAlu;
    input outCond;
    input[DBITS - 1:0] outMem;
    
    wire isBranch = op1[2] & ~op1[0];
	wire isSW = op1[0] & op1[2];
    
    reg writeCycle;
    
    initial writeCycle = 1'b0;
    
    always @ (posedge clk) begin
        writeCycle <= ~writeCycle;
    end
    
    
    // InstrFetch
    output isJal;
    assign isJal = op1[1] & op1[0];
    output useImmPc;
    assign useImmPc = isBranch & outCond;
    output[DBITS - 1:0] pcIn;
    assign pcIn = isJal ? outAlu : imm32;
    output pcWrtEn;
    assign pcWrtEn = ~writeCycle;
    
    // RegFetch
    output wrtEnReg;
    assign wrtEnReg = ~op1[2] & lock & writeCycle;
    output[31:0] wrtReg;
    assign wrtReg =
        op1[0] ? (op1[1] ? pcAdded : outMem) : // JAL, LW
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
    assign wrtEnMem = isSW & lock & writeCycle; // SW

endmodule
