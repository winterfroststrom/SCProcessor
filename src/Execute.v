module Execute(
    inRegd, inReg1, inReg2, imm32, immHi, useZero, useImm, isMvhi, opAlu, opCond,
    outAlu, outCond
);
    parameter OPCODE_BIT_WIDTH;
    parameter DBITS;

    input[DBITS - 1: 0] inRegd, inReg1, inReg2, imm32;
    input[15:0] immHi;
    input useZero, useImm, isMvhi;
    input[OPCODE_BIT_WIDTH - 1: 0] opAlu, opCond;

    output[DBITS - 1: 0] outAlu;
    output[0:0] outCond;
    
    wire[DBITS - 1: 0] inA, inB;

    assign inA =    isMvhi ? {immHi, inRegd[15:0]} : inReg1;
    assign inB =    useZero ? 0 :           // Comp with 0
                    useImm ? imm32 :        // immediate
                    inReg2;                 // register

    ALU #(OPCODE_BIT_WIDTH, DBITS) alu (opAlu, inA, inB, outAlu);
    ConditionalCheck #(DBITS) cond (opCond, outAlu, outCond);   // There should be opCond because comp/branch will always have opAlu as sub.
endmodule
