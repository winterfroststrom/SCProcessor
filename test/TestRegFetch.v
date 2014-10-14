module TestRegFetch();
    parameter DBITS                        = 32;
    parameter INST_SIZE                    = 32'd4;
    parameter INST_BIT_WIDTH               = 32;
    parameter START_PC                     = 32'h40;
    parameter REG_INDEX_BIT_WIDTH          = 4;
    parameter OP_BIT_WIDTH                 = 4;
    parameter ADDR_KEY                     = 32'hF0000010;
    parameter ADDR_SW                      = 32'hF0000014;
    parameter ADDR_HEX                     = 32'hF0000000;
    parameter ADDR_LEDR                    = 32'hF0000004;
    parameter ADDR_LEDG                    = 32'hF0000008;

    parameter IMEM_INIT_FILE               = "src/asm/Test2_asm.mif";
    parameter IMEM_ADDR_BIT_WIDTH          = 11;
    parameter IMEM_DATA_BIT_WIDTH          = INST_BIT_WIDTH;
    parameter IMEM_PC_BITS_HI              = IMEM_ADDR_BIT_WIDTH + 2;
    parameter IMEM_PC_BITS_LO              = 2;

    parameter DMEMADDRBITS                 = 13;
    parameter DMEMWORDBITS                 = 2;
    parameter DMEMWORDS                    = 2048;
  
    // OP1  
    parameter OP1_ALUR                     = 4'b0000;
    parameter OP1_ALUI                     = 4'b1000;
    parameter OP1_CMPR                     = 4'b0010;
    parameter OP1_CMPI                     = 4'b1010;
    parameter OP1_BCOND                    = 4'b0110;
    parameter OP1_SW                       = 4'b0101;
    parameter OP1_LW                       = 4'b1001;
    parameter OP1_JAL                      = 4'b1011;

    // ALU/ALUI
    parameter OP2_ADD                      = 4'b0000;
    parameter OP2_SUB                      = 4'b0001;
    parameter OP2_AND                      = 4'b0100;
    parameter OP2_OR                       = 4'b0101;
    parameter OP2_XOR                      = 4'b0110;
    parameter OP2_NAND                     = 4'b1100;
    parameter OP2_NOR                      = 4'b1101;
    parameter OP2_XNOR                     = 4'b1110;
  
    // ALUI
    parameter OP2_MVHI                     = 4'b1011;
  
    // SW/LW/JAL
    parameter OP2_ZERO                     = 4'b0000;
  
    // CMP/CMPI/Bcond
    parameter OP2_F                        = 4'b0000;
    parameter OP2_EQ                       = 4'b0001;
    parameter OP2_LT                       = 4'b0010;
    parameter OP2_LTE                      = 4'b0011;
    parameter OP2_EQZ                      = 4'b0101;
    parameter OP2_LTZ                      = 4'b0110;
    parameter OP2_LTEZ                     = 4'b0111;
  
    parameter OP2_T                        = 4'b1000;
    parameter OP2_NE                       = 4'b1001;
    parameter OP2_GTE                      = 4'b1010;
    parameter OP2_GT                       = 4'b1011;
    parameter OP2_NEZ                      = 4'b1101;
    parameter OP2_GTEZ                     = 4'b1110;
    parameter OP2_GTZ                      = 4'b1111;

    
    reg clk;
    reg wrtEnReg;
    reg[OP_BIT_WIDTH - 1:0] rd, rs1, rs2;
    reg[31:0] wrtReg;
    reg[15:0] imm16;
    wire[31:0] outRegd, outReg1, outReg2, imm32;
    
    // Register File and Sign Extension
    RegFetch #(REG_INDEX_BIT_WIDTH, DBITS) regFetch (
        clk, wrtEnReg, rd, rs1, rs2, wrtReg, imm16,
        outRegd, outReg1, outReg2, imm32
    );

    reg[31:0] num32;
    
    initial begin
        #1
        rs1 = 4'b0001;
        rs2 = 4'b0010;
        imm16 = 16'hf0f0;
        
        clk = 1'b1;
        wrtEnReg = 1'b1;
        wrtReg = 5;
        rd = 4'b0000;
        $display("1 Wrote 5: %d", outRegd);
        #1
        clk = 1'b0;
        $display("0 Wrote 5: %d", outRegd);
        #1
        $display("0 Wrote 5: %d", outRegd);
        $display("Read: %d, %d, %d", outRegd, outReg1, outReg2);
        #1

        clk = 1'b1;
        wrtEnReg = 1'b1;
        wrtReg = 7;
        rd = 4'b0001;
        $display("1 Wrote 7: %d", outRegd);
        #1
        clk = 1'b0;
        $display("0 Wrote 7: %d", outRegd);
        #1
        $display("0 Wrote 7: %d", outRegd);
        $display("Read: %d, %d, %d", outRegd, outReg1, outReg2);
        #1

        clk = 1'b1;
        wrtEnReg = 1'b1;
        wrtReg = 9;
        rd = 4'b0010;
        $display("1 Wrote 9: %d", outRegd);
        #1
        clk = 1'b0;
        $display("0 Wrote 9: %d", outRegd);
        #1
        $display("0 Wrote 9: %d", outRegd);
        $display("Read: %d, %d, %d", outRegd, outReg1, outReg2);
        #1
        
        clk = 1'b1;
        wrtEnReg = 1'b1;
        wrtReg = 2;
        rd = 4'b0000;
        $display("1 Wrote 2: %d", outRegd);
        #1
        clk = 1'b0;
        $display("0 Wrote 2: %d", outRegd);
        #1
        $display("0 Wrote 2: %d", outRegd);
        $display("Read: %d, %d, %d", outRegd, outReg1, outReg2);
        #1
        
        clk = 1'b1;
        wrtEnReg = 1'b0;
        rd = 4'b0000;
        rs1 = 4'b0001;
        rs2 = 4'b0010;
        #1
        clk = 1'b0;
        #1
        $display("Read: %d, %d, %d", outRegd, outReg1, outReg2);
        #1
        
        
        num32 = imm32;
        $display("imm %b", num32);
        
    end
    
endmodule
