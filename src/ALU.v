module ALU(aluOp, inA, inB, outAlu);
    parameter OPCODE_BIT_WIDTH;
    parameter DBITS;

    input[OPCODE_BIT_WIDTH - 1: 0] aluOp;
    input[DBITS - 1: 0] inA, inB;

    output[DBITS - 1: 0] outAlu;

    wire[DBITS - 1: 0] arithResult, bitResult;

    /*  00      01      10      11
    00  ADD     SUB
    01  AND     OR      XOR
    10
    11  NAND    NOR     NXOR
    */

    assign arithResult = inA + ((aluOp[0]) ? inB : (~inB + 1)); // add 4'bxxx0 or sub 4'bxxx1
    assign bitResult = 
            (aluOp[1:0] == 2'b00) ? inA & inB : // and 4'bxx00
            (aluOp[1:0] == 2'b01) ? inA | inB : // or  4'bxx01
           /*aluOp[1:0] == 2'b10*/  inA ^ inB;  // xor 4'bxx10

    assign outAlu = 
            (aluOp[2]) ? 
                ((aluOp[3]) ? ~bitResult  :     // nand, nor, nxor
                               bitResult) :     // and, or, xor
                arithResult;                    // add, sub

endmodule