module RegisterFile(
    clk, wrtEn, rd, rs1, rs2, wrtData, outd, out1, out2
);

    parameter DBITS;
    
    input clk;
    input wrtEn;

    input[3:0] rd, rs1, rs2;
    input[DBITS - 1:0] wrtData;

    output[DBITS - 1:0] outd, out1, out2;

    reg[DBITS - 1:0] registers [15:0];

    integer i;
    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            registers[i] = {(DBITS){1'b0}};
        end
    end
      
    assign outd = registers[rd];
    assign out1 = registers[rs1];
    assign out2 = registers[rs2];

    always @(posedge clk) begin
        if(wrtEn) begin
            registers[rd] <= wrtData;
        end
    end

endmodule