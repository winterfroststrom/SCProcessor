module RegisterFile(clk, res, wrtEn, rd, rs1, rs2, wrtData, out1, out2);
    
    input clk;
    input res;
    input wrtEn;

    input[3:0] rd, rs1, rs2;
    input[31:0] wrtData;

    output[31:0] out1, out2;

    reg[31:0] registers [15:0];

    assign out1 = registers[rs1];
    assign out2 = registers[rs2];

    always @(posedge clk) begin
        if (res) begin
            registers[0]  <= 0;
            registers[1]  <= 0;
            registers[2]  <= 0;
            registers[3]  <= 0;
            registers[4]  <= 0;
            registers[5]  <= 0;
            registers[6]  <= 0;
            registers[7]  <= 0;
            registers[8]  <= 0;
            registers[9]  <= 0;
            registers[10] <= 0;
            registers[11] <= 0;
            registers[12] <= 0;
            registers[13] <= 0;
            registers[14] <= 0;
            registers[15] <= 0;
        end
        else if(wrtEn) begin
            registers[rd] <= wrtData;
        end
    end

endmodule