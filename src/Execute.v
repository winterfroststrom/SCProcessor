module Execute(
    inRegd, inReg1, inReg2, imm32, immHi, useZero, useImm, isMvhi, opAlu,
    outAlu, outCond
);
    parameter OPCODE_BIT_WIDTH;
    parameter DBITS;

    input[DBITS - 1: 0] inRegd, inReg1, inReg2, imm32;
    input[15:0] immHi;
    input useZero, useImm, isMvhi;
    input[OPCODE_BIT_WIDTH - 1: 0] opAlu;

    output[DBITS - 1: 0] outAlu;
    output outCond;
    
    wire[DBITS - 1: 0] inA, inB;

    assign inA =    isMvhi ? {immHi, inRegd[15:0]} : inReg1;
    assign inB =    useZero ? 0 :           // Comp with 0
                    useImm ? imm32 :        // immediate
                    inReg2;                 // register

    ALU #(OPCODE_BIT_WIDTH, DBITS) alu (opAlu, inA, inB, outAlu);
    ConditionalCheck #(DBITS) cond (opAlu, outAlu, outCond);
endmodule



module ConditionalCheck(opCond, in0, outCond);
    parameter DBITS;

    input[3:0] opCond;
    input[DBITS - 1: 0] in0;  // in0 = inA - inB in ALU

    output outCond;

    assign outCond = 1'b0;

endmodule