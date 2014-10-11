module Decoder(instr, op1, op2, rd, rs1, rs2, imm16);
    parameter INSTR_WIDTH = 32;
    parameter REG_WIDTH = 4;

    input[INSTR_WIDTH - 1: 0]   instr;
    output[3: 0]                op1;
    output[3: 0]                op2;
    output[REG_WIDTH - 1: 0]    rd;
    output[REG_WIDTH - 1: 0]    rs1;
    output[REG_WIDTH - 1: 0]    rs2;
    output[15: 0]               imm;

    assign op1 = instr[31: 28];
    assign op2 = instr[27: 24];
    assign rd  = instr[23: 20];
    assign rs1 = (instr[30]) ? instr[23: 20] : instr[19: 16];  // checks if op1 is 01xx for Branch or
    assign rs2 = (instr[30]) ? instr[19: 16] : instr[15: 12];
    assign imm16 = instr[15: 0];

endmodule