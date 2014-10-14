module TestExecute();
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

    
    wire[DBITS - 1:0] inRegd = 32'h00001111;
    wire[DBITS - 1:0] inReg1 = 8;
    wire[DBITS - 1:0] inReg2 = 3;
    wire[DBITS - 1:0] imm32 = 1;
    wire[15:0] immHi = 16'h2222;
    reg[OP_BIT_WIDTH - 1:0] op1, op2;
    wire isBranch = op1[2] & ~op1[0];
    wire isSW = op1[0] & op1[2];
    
    wire isMvhi;
    assign isMvhi = op1[3] & ~op1[1] & op2[0] & op2[1];
    wire useZero;
    assign useZero = (isBranch & op2[2]) | isMvhi;
    wire useImm;
    assign useImm = op1[3] | isSW;
    wire isBranchOrCond;
    assign isBranchOrCond = op1[1] & ~op1[0];
    wire[OP_BIT_WIDTH - 1:0] opAlu;
    assign opAlu = isBranchOrCond ? OP2_SUB : op2;
    wire[OP_BIT_WIDTH - 1:0] opCond;
    assign opCond = op2;
    
    
    wire[DBITS - 1:0] outAlu;
    wire outCond;
    reg[DBITS - 1:0] out1;
    reg out2;
    Execute #(OP_BIT_WIDTH, DBITS) unit0(
        inRegd, inReg1, inReg2, imm32, immHi,
        useZero, useImm, isMvhi, isBranchOrCond, opAlu, opCond,
        outAlu, outCond
    );
    initial begin
        $display("rd=0x1111\tr1=8tr2=3");
        $display("imm=1\timmhi=0x2222");
        op1 = OP1_ALUR;     op2 = OP2_ADD;
        #1
        out1 = outAlu; out2 = outCond;
        $display("ADD:\t%d\t %b", out1, out2);
        op1 = OP1_ALUR;     op2 = OP2_SUB;
        #1
        out1 = outAlu; out2 = outCond;
        $display("SUB:\t%d\t %b", out1, out2);
        op1 = OP1_ALUI;     op2 = OP2_ADD;
        #1
        out1 = outAlu; out2 = outCond;
        $display("ADDI:\t%d\t %b", out1, out2);
        op1 = OP1_ALUI;     op2 = OP2_SUB;
        #1
        out1 = outAlu; out2 = outCond;
        $display("SUBI:\t%d\t %b", out1, out2);
        op1 = OP1_CMPR;     op2 = OP2_LT;
        #1
        out1 = outAlu; out2 = outCond;
        $display("LT:\t%d\t %b", out1, out2);
        op1 = OP1_CMPR;     op2 = OP2_GTE;
        #1
        out1 = outAlu; out2 = outCond;
        $display("GTE:\t%d\t %b", out1, out2);
        op1 = OP1_CMPI;     op2 = OP2_F;
        #1
        out1 = outAlu; out2 = outCond;
        $display("FI:\t%d\t %b", out1, out2);
        op1 = OP1_BCOND;     op2 = OP2_LTE;
        #1
        out1 = outAlu; out2 = outCond;
        $display("BLTE:\t%d\t %b", out1, out2);
        op1 = OP1_BCOND;     op2 = OP2_GT;
        #1
        out1 = outAlu; out2 = outCond;
        $display("BGT:\t%d\t %b", out1, out2);
        op1 = OP1_BCOND;     op2 = OP2_GTZ;
        #1
        out1 = outAlu; out2 = outCond;
        $display("BGTZ:\t%d\t %b", out1, out2);
        op1 = OP1_JAL;     op2 = OP2_ADD;
        #1
        out1 = outAlu; out2 = outCond;
        $display("JAL:\t%d\t %b", out1, out2);
        op1 = OP1_LW;     op2 = OP2_ADD;
        #1
        out1 = outAlu; out2 = outCond;
        $display("LW:\t%d\t %b", out1, out2);
        op1 = OP1_SW;     op2 = OP2_ADD;
        #1
        out1 = outAlu; out2 = outCond;
        $display("SW:\t%d\t %b", out1, out2);
        op1 = OP1_ALUR;     op2 = OP2_XOR;
        #1
        out1 = outAlu; out2 = outCond;
        $display("XOR:\t%d\t %b", out1, out2);
        op1 = OP1_ALUI;     op2 = OP2_OR;
        #1
        out1 = outAlu; out2 = outCond;
        $display("ORI:\t%d\t %b", out1, out2);
        op1 = OP1_ALUR;     op2 = OP2_AND;
        #1
        out1 = outAlu; out2 = outCond;
        $display("AND:\t%d\t %b", out1, out2);
        
        
        op1 = OP1_ALUI;     op2 = OP2_MVHI;
        #1
        out1 = outAlu; out2 = outCond;
        $display("MVHI:\t%b\t %b", out1, out2);        
    end

endmodule
