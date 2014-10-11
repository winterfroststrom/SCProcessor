module Execute(inReg1, inReg2, imm32, aluMux, op2, outAlu);
    parameter OPCODE_BIT_WIDTH;
    parameter DBITS;

    input[DBITS - 1: 0] inReg1, inReg2, imm32;
    input aluMux;
    input[OPCODE_BIT_WIDTH - 1: 0] op2;

    output[DBITS - 1: 0] outAlu;
    wire[DBITS - 1: 0] outAlu;

    wire[DBITS - 1: 0] inA, inB;

    assign inA = inReg1;
    assign inB = (aluMux) ? imm32 : inReg2;
    
    ALU #(OPCODE_BIT_WIDTH, DBITS) alu (op2, inA, inB, outAlu);

endmodule