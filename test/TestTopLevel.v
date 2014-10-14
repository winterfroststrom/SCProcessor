module TestTopLevel();
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

    
    reg  [9:0] SW;
    reg  [3:0] KEY;
    reg  CLOCK_50;
    reg [9:0] LEDR;
    reg [7:0] LEDG;
    reg [6:0] HEX0,HEX1,HEX2,HEX3;

    wire clk, lock;
    assign lock = 1'b1;
    wire reset = ~lock;
    assign clk = CLOCK_50;

    wire useImmPc;
    wire[DBITS - 1:0] pcIn, pcOld;
    wire[DBITS - 1: 0] pcOut;
    
    wire wrtEnReg;
    wire[31:0] wrtReg;
    wire useZeroExe, useImmExe, isMvhi, isBranchOrCond;
    wire[OP_BIT_WIDTH-1:0] opAlu, opCond;    
    wire wrEnMem;
    
    
    wire[IMEM_DATA_BIT_WIDTH - 1: 0] instWordReal;
    reg[IMEM_DATA_BIT_WIDTH - 1: 0] instWord;
    
    
    wire[OP_BIT_WIDTH - 1: 0] op1, op2;
    wire[REG_INDEX_BIT_WIDTH - 1: 0] rd, rs1, rs2;
    wire[INST_BIT_WIDTH - OP_BIT_WIDTH * 2 - REG_INDEX_BIT_WIDTH * 2 - 1: 0] imm16;

    wire[31:0] outRegd, outReg1, outReg2, imm32;

    wire[31:0] outAlu;
    wire outCond;

    wire[31:0] outMem;
    
    // Controller
    SCProcController #(OP_BIT_WIDTH, DBITS, OP2_SUB) controller (
        lock, pcOut, op1, op2, imm32, outAlu, outCond, outMem,
        useImmPc, pcIn, pcOld, // PC
        wrtEnReg, wrtReg, // RegFetch
        useZeroExe, useImmExe, isMvhi, isBranchOrCond, opAlu, opCond, // Execute
        wrEnMem // Memory
    );
  
    // PC module
    InstrFetch pc (clk, reset, useImmPc, pcIn, pcOld, pcOut);
  
    // Instruction Memory
    InstMemory #(IMEM_INIT_FILE, IMEM_ADDR_BIT_WIDTH, IMEM_DATA_BIT_WIDTH) instMem (
        pcOut[IMEM_PC_BITS_HI - 1: IMEM_PC_BITS_LO], instWordReal
    );

    // Instruction Decoder
    Decoder #(INST_BIT_WIDTH, REG_INDEX_BIT_WIDTH) instrDecoder (
        instWord, op1, op2, rd, rs1, rs2, imm16
    );
  
    // Register File and Sign Extension
    RegFetch #(REG_INDEX_BIT_WIDTH, DBITS) regFetch (
        clk, wrtEnReg, rd, rs1, rs2, wrtReg, imm16,
        outRegd, outReg1, outReg2, imm32
    );

    // ALU and conditional
    Execute #(OP_BIT_WIDTH, DBITS) execute (
        outRegd, outReg1, outReg2, imm32, imm16,
        useZeroExe, useImmExe, isMvhi, isBranchOrCond, opAlu, opCond,
        outAlu, outCond
    );

    wire [9:0] ledr;
    wire [7:0] ledg;
    wire [6:0] hex0, hex1, hex2, hex3;

    
    // Put the code for data memory and I/O here
    // KEYS, SWITCHES, HEXS, and LEDS are memory mapped IO
    DataMemory dataMemory(
        clk, wrEnMem, outAlu, outReg2, SW, KEY,
        ledr, ledg, hex0, hex1, hex2, hex3, outMem
    );

    /*
-- @ 0x00000040 :	 MVHI	 GP,IOBASE
00000010 : 8bc0f000;
-- @ 0x00000044 :	 ANDI	 S0,S0,0
00000011 : 84660000;
-- @ 0x00000048 :	 NAND	 T0,S0,S0
00000012 : 0c466000;
-- @ 0x0000004c :	 SW	 T0,OFSLEDR(GP)
00000013 : 50c40004;
-- @ 0x00000050 :	 ADDI	 T0,S0,0XBAD
00000014 : 80460bad;
-- @ 0x00000054 :	 SW	 T0,OFSHEX(GP)
00000015 : 50c40000;
-- @ 0x00000058 :	 BT	 T0,T0,ATZERO
00000016 : 6844fff9;
    */
    reg num1;
    reg[3:0] num4;
    reg[15:0] num16;
    reg[31:0] num32;
    
    initial begin
        num1 = useImmPc; num32 = pcIn; $display("useImmPc: %b\t pcIn: %h", num1, num32);
        num32 = pcOld; $display("pcOld: %h", num32);
        #1
        CLOCK_50 = 1'b1;
        #1
        CLOCK_50 = 1'b0;
        #1
        num1 = useImmPc; num32 = pcIn; $display("useImmPc: %b\t pcIn: %h", num1, num32);
        num32 = pcOld; $display("pcOld: %h", num32);
        instWord = 32'h8bc0f000;
        #1
        CLOCK_50 = 1'b1;
        #1
        CLOCK_50 = 1'b0;
        #1
        $display("\tMVHI	 GP,IOBASE");
        LEDR = ledr;LEDG = ledg;HEX0 = hex0;HEX1 = hex1;HEX2 = hex2;HEX3 = hex3;
        num16 = imm16; $display("imm: %h", num16);
        num4 = rd; $display("rd: %b", num4);
        num32 = outAlu; $display("alu: %h", num32);
        num32 = wrtReg; num1 = wrtEnReg; $display("wrtEnReg: %b\t wrtReg: %h", num1, num32);
        num1 = useImmPc; num32 = pcIn; $display("useImmPc: %b\t pcIn: %h", num1, num32);
        num32 = pcOld; $display("pcOld: %h", num32);
        
        instWord = 32'h84660000;
        #1
        CLOCK_50 = 1'b1;
        #1
        CLOCK_50 = 1'b0;
        #1
        $display("\tANDI	 S0,S0,0");
        LEDR = ledr;LEDG = ledg;HEX0 = hex0;HEX1 = hex1;HEX2 = hex2;HEX3 = hex3;
        num32 = outAlu; $display("alu: %h", num32);
        num32 = wrtReg; num1 = wrtEnReg; $display("wrtEnReg: %b\t wrtReg: %h", num1, num32);
        num1 = useImmPc; num32 = pcIn; $display("useImmPc: %b\t pcIn: %h", num1, num32);
        num32 = pcOld; $display("pcOld: %h", num32);
        
        instWord = 32'h0c466000;
        #1
        CLOCK_50 = 1'b1;
        #1
        CLOCK_50 = 1'b0;
        #1
        $display("\tNAND	 T0,S0,S0");
        LEDR = ledr;LEDG = ledg;HEX0 = hex0;HEX1 = hex1;HEX2 = hex2;HEX3 = hex3;
        num32 = outAlu; $display("alu: %h", num32);
        num32 = wrtReg; $display("wrtReg: %h", num32);
        num1 = useImmPc; num32 = pcIn; $display("useImmPc: %b\t pcIn: %h", num1, num32);
        num32 = pcOld; $display("pcOld: %h", num32);
        
        instWord = 32'h50c40004;
        #1
        CLOCK_50 = 1'b1;
        #1
        CLOCK_50 = 1'b0;
        #1
        $display("\tSW	 T0,OFSLEDR(GP)");
        LEDR = ledr;LEDG = ledg;HEX0 = hex0;HEX1 = hex1;HEX2 = hex2;HEX3 = hex3;
        num32 = outAlu; $display("alu: %h", num32);
        num32 = outReg2; $display("reg2: %h", num32);
        $display("LEDR: %b", LEDR);
        num1 = wrEnMem; $display("wrEnMem: %b", num1);
        num1 = useImmPc; num32 = pcIn; $display("useImmPc: %b\t pcIn: %h", num1, num32);
        num32 = pcOld; $display("pcOld: %h", num32);
        
        instWord = 32'h80460bad;
        #1
        CLOCK_50 = 1'b1;
        #1
        CLOCK_50 = 1'b0;
        #1
        $display("\tADDI	 T0,S0,0XBAD");
        LEDR = ledr;LEDG = ledg;HEX0 = hex0;HEX1 = hex1;HEX2 = hex2;HEX3 = hex3;
        num32 = outAlu; $display("alu: %h", num32);
        num32 = wrtReg; num1 = wrtEnReg; $display("wrtEnReg: %b\t wrtReg: %h", num1, num32);
        num1 = useImmPc; num32 = pcIn; $display("useImmPc: %b\t pcIn: %h", num1, num32);
        num32 = pcOld; $display("pcOld: %h", num32);
        
        instWord = 32'h50c40000;
        #1
        CLOCK_50 = 1'b1;
        #1
        CLOCK_50 = 1'b0;
        #1
        $display("\tSW	 T0,OFSHEX(GP)");
        LEDR = ledr;LEDG = ledg;HEX0 = hex0;HEX1 = hex1;HEX2 = hex2;HEX3 = hex3;
        num32 = outReg2; $display("reg2: %h", num32);
        num32 = outAlu; $display("alu: %h", num32);
        num1 = useImmPc; num32 = pcIn; $display("useImmPc: %b\t pcIn: %h", num1, num32);
        num32 = pcOld; $display("pcOld: %h", num32);
        
        $display("hex %b %b %b %b", HEX3, HEX2, HEX1, HEX0);
        
        instWord = 32'h6844fff9;
        LEDR = ledr;LEDG = ledg;HEX0 = hex0;HEX1 = hex1;HEX2 = hex2;HEX3 = hex3;
        #1
        CLOCK_50 = 1'b1;
        #1
        CLOCK_50 = 1'b0;
        #1
        $display("\tBT	 T0,T0,ATZERO");
        LEDR = ledr;LEDG = ledg;HEX0 = hex0;HEX1 = hex1;HEX2 = hex2;HEX3 = hex3;
        num32 = outAlu; $display("alu: %h", num32);
        num32 = imm32; $display("imm32: %h", num32);
        num1 = outCond; $display("outCond: %b", num1);
        num1 = useImmPc; num32 = pcIn; $display("useImmPc: %b\t pcIn: %h", num1, num32);
        num32 = pcOut; $display("pcOut: %h", num32);
        

        #1
        
        $display("%b", LEDR);
        $display("%b", HEX0);
        $display("%b", HEX1);
        $display("%b", HEX2);
        $display("%b", HEX3);
    end

endmodule
