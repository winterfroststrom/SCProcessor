module Execute(
    inRegd, inReg1, inReg2, imm32, immHi,
    useZero, useImm, isMvhi, isBranchOrCond, opAlu, opCond,
    outAlu, outCond
);
    parameter OPCODE_BIT_WIDTH;
    parameter DBITS;

    input[DBITS - 1: 0] inRegd, inReg1, inReg2, imm32;
    input[15:0] immHi;
    input useZero, useImm, isMvhi, isBranchOrCond;
    input[OPCODE_BIT_WIDTH - 1: 0] opAlu, opCond;

    output[DBITS - 1: 0] outAlu;
    output[0:0] outCond;
    
    wire[DBITS - 1: 0] inA, inB;

    assign inA =    isMvhi ? {immHi, inRegd[15:0]} : inReg1;
    assign inB =    useZero ? 0 :           // Comp with 0
                    useImm ? imm32 :        // immediate
                    inReg2;                 // register

    wire[DBITS - 1:0] outAlu1;
    ALU #(OPCODE_BIT_WIDTH, DBITS) alu (opAlu, inA, inB, outAlu1);
    // There should be opCond because comp/branch will always have opAlu as sub.
    ConditionalCheck #(DBITS) cond (opCond, outAlu1, outCond);
    assign outAlu = isBranchOrCond ? {{(DBITS - 1){1'b0}}, outCond} : outAlu1;
endmodule
