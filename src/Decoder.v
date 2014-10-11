module Decoder(inst, op1, op2, rd, rs1, rs2, imm16);
    parameter INST_WIDTH;
    parameter REG_WIDTH;

    input[INST_WIDTH - 1: 0]    inst;
    output[3: 0]                op1;
    output[3: 0]                op2;
    output[REG_WIDTH - 1: 0]    rd;
    output[REG_WIDTH - 1: 0]    rs1;
    output[REG_WIDTH - 1: 0]    rs2;
    output[15: 0]               imm16;

    assign op1 = inst[31: 28];
    assign op2 = inst[27: 24];
    assign rd  = inst[23: 20];
    assign rs1 = (inst[30]) ? inst[23: 20] : inst[19: 16];  // checks if op1 is 01xx for Branch or
    assign rs2 = (inst[30]) ? inst[19: 16] : inst[15: 12];
    assign imm16 = inst[15: 0];

endmodule