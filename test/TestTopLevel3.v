module TestTopLevel3();

    reg [9:0] SW;
    reg [3:0] KEY;
    reg CLOCK_50;
    reg[31:0] instWord;
    wire [9:0] LEDR;
    wire [7:0] LEDG;
    wire [6:0] HEX0,HEX1,HEX2,HEX3;
    reg num1;
    reg[3:0] num4;
    reg[15:0] num16, num160, num161;
    reg[31:0] num32, num320, num321;
    


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
    

    
    //PLL, clock generation, and reset generation
    //Pll pll(.inclk0(CLOCK_50), .c0(clk), .locked(lock));
    wire clk, lock;
    assign clk = CLOCK_50;
    assign lock = 1'b1;
//    PLL   PLL_inst (.inclk0 (CLOCK_50),.c0 (clk),.locked (lock));
    wire reset = ~lock;

    // Controller Output
    wire useImmPc, isJal;
    wire[DBITS - 1:0] pcIn;
    wire wrtEnReg;
    wire[31:0] wrtReg;
    wire useZeroExe, useImmExe, isMvhi, isBranchOrCond;
    wire[OP_BIT_WIDTH-1:0] opAlu, opCond;    
    wire wrEnMem;

    // InstrFetch output
    wire[DBITS - 1: 0] pcAdded, pcOut;

    // InstMemory output
//    wire[IMEM_DATA_BIT_WIDTH - 1: 0] instWord;

    // Decoder Output
    wire[OP_BIT_WIDTH - 1: 0] op1, op2;
    wire[REG_INDEX_BIT_WIDTH - 1: 0] rd, rs1, rs2;
    wire[INST_BIT_WIDTH - OP_BIT_WIDTH * 2 - REG_INDEX_BIT_WIDTH * 2 - 1: 0] imm16;

    // RegFetch Output
    wire[31:0] outRegd, outReg1, outReg2, imm32;

    // Execute Output
    wire[31:0] outAlu;
    wire outCond;

    // DataMemory Output
    wire[31:0] outMem;
    
    // Controller
    SCProcController #(OP_BIT_WIDTH, DBITS, OP2_SUB) controller (
        lock, pcAdded, pcOut, op1, op2, imm32, outAlu, outCond, outMem,
        useImmPc, pcIn, isJal, // PC
        wrtEnReg, wrtReg, // RegFetch
        useZeroExe, useImmExe, isMvhi, isBranchOrCond, opAlu, opCond, // Execute
        wrEnMem // Memory
    );
  
    // PC module
    InstrFetch pc (clk, reset, useImmPc, pcIn, isJal, pcAdded, pcOut);
  
/*    wire[31:0] instWordReal;
    // Instruction Memory
    InstMemory #(IMEM_INIT_FILE, IMEM_ADDR_BIT_WIDTH, IMEM_DATA_BIT_WIDTH) instMem (
        pcOut[IMEM_PC_BITS_HI - 1: IMEM_PC_BITS_LO], instWordReal
    );
*/

    // Instruction Decoder
    Decoder #(INST_BIT_WIDTH, REG_INDEX_BIT_WIDTH) instrDecoder (
        instWord, op1, op2, rd, rs1, rs2, imm16
    );
  
    // Register File and Sign Extension
    RegFetch #(REG_INDEX_BIT_WIDTH, DBITS) regFetch (
        clk, wrtEnReg, isJal, rd, rs1, rs2, wrtReg, imm16,
        outRegd, outReg1, outReg2, imm32
    );

    // ALU and conditional
    Execute #(OP_BIT_WIDTH, DBITS) execute (
        outRegd, outReg1, outReg2, imm32, imm16,
        useZeroExe, useImmExe, isMvhi, isBranchOrCond, opAlu, opCond,
        outAlu, outCond
    );

    // Put the code for data memory and I/O here
    // KEYS, SWITCHES, HEXS, and LEDS are memory mapped IO
    DataMemory dataMemory(
        clk, wrEnMem, outAlu, outReg2, SW, KEY,
        LEDR, LEDG, HEX0, HEX1, HEX2, HEX3, outMem
    );

    /*
-- @ 0x00000230 :	 ADDI	 T0,FP,0X37
0000008c : 804d0037;
-- @ 0x00000234 :	 ADDI	 T1,FP,0XE1
0000008d : 805d00e1;
-- @ 0x00000238 :	 ADDI	 A2,FP,1024
0000008e : 802d0400;
-- @ 0x0000023c :	 SW	 T0,0(A2)
0000008f : 50240000;
-- @ 0x00000240 :	 SW	 T1,4(A2)
00000090 : 50250004;
-- @ 0x00000244 :	 ADDI	 A2,A2,4
00000091 : 80220004;
-- @ 0x00000248 :	 LW	 A0,0(A2)
00000092 : 90020000;
-- @ 0x0000024c :	 BNE	 A0,T1,MEMFAILED
00000093 : 69050002;
-- @ 0x00000250 :	 LW	 A0,-4(A2)
00000094 : 9002fffc;
-- @ 0x00000254 :	 BEQ	 A0,T0,MEMWORKS
00000095 : 61040004;
*/
    
    initial begin
        $display("//-- @ 0x00000230 :	 ADDI	 T0,FP,0X37");
        instWord = 32'h804d0037;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = wrtReg; $display("wrtReg: %h", num32);

        $display("//-- @ 0x00000234 :	 ADDI	 T1,FP,0XE1");
        instWord = 32'h805d00e1;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = wrtReg; $display("wrtReg: %h", num32);
        
        $display("//-- @ 0x00000238 :	 ADDI	 A2,FP,1024");
        instWord = 32'h802d0400;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = wrtReg; $display("wrtReg: %h", num32);

        $display("//-- @ 0x0000023c :	 SW	 T0,0(A2)");
        instWord = 32'h50240000;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = outReg2; num320 = outAlu; 
        $display("outReg2: %h @ addr: %h", num32, num320);

        $display("//-- @ 0x00000240 :	 SW	 T1,4(A2)");
        instWord = 32'h50250004;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = outReg2; num320 = outAlu; 
        $display("outReg2: %h @ addr: %h", num32, num320);
        
        $display("//-- @ 0x00000244 :	 ADDI	 A2,A2,4");
        instWord = 32'h80220004;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = wrtReg; $display("wrtReg: %h", num32);
        num32 = outAlu; $display("outAlu: %h", num32);
        num32 = imm32; $display("imm: %h", num32);
        num32 = outReg1; $display("reg1: %h", num32);
        
        $display("//-- @ 0x00000248 :	 LW	 A0,0(A2)");
        instWord = 32'h90020000;
        CLOCK_50 = 1'b1; #1 
        num32 = wrtReg; $display("wrtReg: %h", num32);
        num32 = outAlu; $display("addr: %h", num32);
        num32 = imm32; $display("imm: %h", num32);
        num32 = outReg1; $display("reg1: %h", num32);
        num32 = outRegd; $display("regd: %h", num32);
        num32 = outMem; $display("outMem: %h", num32);
        CLOCK_50 = 1'b0; #1
        $display("-------------");
        num32 = wrtReg; $display("wrtReg: %h", num32);
        num32 = outAlu; $display("addr: %h", num32);
        num32 = imm32; $display("imm: %h", num32);
        num32 = outReg1; $display("reg1: %h", num32);
        num32 = outRegd; $display("regd: %h", num32);
        num32 = outMem; $display("outMem: %h", num32);

        $display("//-- @ 0x0000024c :	 BNE	 A0,T1,MEMFAILED");
        instWord = 32'h69050002;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = outReg1; num320 = outReg2;
        $display("reg1: %h, reg2 : %h", num32, num320);
        num32 = useImmPc; $display("branch?: %h", num32);
  /*     
instWord = 32'h9002fffc;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
        num32 = wrtReg; $display("wrtReg: %h", num32);
        num32 = outAlu; $display("addr: %h", num32);        
instWord = 32'h61040004;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);

    num32 = useImmPc; $display("useImmPc: %h", num32);
*/

    end

    
endmodule
