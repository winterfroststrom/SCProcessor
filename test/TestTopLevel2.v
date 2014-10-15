module TestTopLevel2();

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

    reg [9:0] SW;
    reg [3:0] KEY;
    reg CLOCK_50;
    reg[31:0] instWord;
    wire [9:0] LEDR;
    wire [7:0] LEDG;
    wire [6:0] HEX0,HEX1,HEX2,HEX3;
   
   
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
  
    wire[31:0] instWordReal;
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

    reg num1;
    reg[3:0] num4;
    reg[15:0] num16;
    reg[31:0] num32;
    
    /*
    
-- @ 0x00000040 :	 ADDI	 S2,S0,0X0BEF
00000010 : 80860bef;
-- @ 0x00000044 :	 XOR	 FP,FP,FP
00000011 : 06ddd000;
-- @ 0x00000048 :	 MVHI	 GP,IOBASE
00000012 : 8bc0f000;
-- @ 0x0000004c :	 MVHI	 S0,0
00000013 : 8b600000;
-- @ 0x00000050 :	 ADDI	 S0,S0,1
00000014 : 80660001;
-- @ 0x00000054 :	 SW	 S0,OFSLEDG(GP)
00000015 : 50c60008;
-- @ 0x00000058 :	 SW	 FP,OFSLEDR(GP)
00000016 : 50cd0004;
-- @ 0x0000005c :	 ADDI	 S0,S0,1
00000017 : 80660001;
-- @ 0x00000060 :	 SW	 S0,OFSLEDG(GP)
00000018 : 50c60008;
-- @ 0x00000064 :	 ADDI	 T0,FP,-1
00000019 : 804dffff;
-- @ 0x00000068 :	 ADDI	 T1,FP,2
0000001a : 805d0002;
-- @ 0x0000006c :	 ADDI	 A0,FP,1
0000001b : 800d0001;
-- @ 0x00000070 :	 ADD	 A1,T0,T1
0000001c : 00145000;
-- @ 0x00000074 :	 BEQ	 A0,A1,ADDWORKS
0000001d : 61010004;
    */
 /*   
    initial begin
 
instWord = 32'h80860bef;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
instWord = 32'h06ddd000;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
instWord = 32'h8bc0f000;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
instWord = 32'h8b600000;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
instWord = 32'h80660001;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
instWord = 32'h50c60008;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
instWord = 32'h50cd0004;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
instWord = 32'h80660001;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
instWord = 32'h50c60008;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
instWord = 32'h804dffff;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
instWord = 32'h805d0002;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
instWord = 32'h800d0001;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
instWord = 32'h00145000;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
instWord = 32'h61010004;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
    num32 = outAlu; $display("alu: %h", num32);
    num32 = useImmPc; $display("useImmPc: %h", num32);

        #1
instWord = {OP1_JAL, OP2_ADD, 4'h0, 4'h0, 16'h0008};
        CLOCK_50 = 1'b1; #1 
        num32 = outAlu; $display("alu: %h", num32);
    
        CLOCK_50 = 1'b0; #1
        // note, rs1 contains 1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
        num32 = wrtReg >> 2; $display("wrtReg %h", num32);
    num32 = rs1; $display("r: %h", num32);
    num32 = outRegd >> 2; $display("rd: %h", num32);    
    num32 = pcAdded >> 2; $display("pcAdded: %h", num32);
    num32 = outAlu; $display("alu: %h", num32);
    num32 = imm32; $display("imm32: %h", num32);
    num32 = pcIn; $display("pcIn: %h", num32);
    num32 = imm32; $display("imm32: %h", num32);
    num32 = useImmPc; $display("useImmPc: %h", num32);
    num32 = {useImmExe, useZeroExe}; $display("useImmExe, useZeroExe: %h", num32);

    instWord = 32'h00145000;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
    
    end
    */
      
    initial begin
// on read hardware, the pcAdded does not update instantly,
// so in simulation, the pcOut value is one ahead of where it should be
instWord = {OP1_JAL, OP2_ADD, 4'h0, 4'h0, 16'h009a};
        CLOCK_50 = 1'b1; #1     CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
        
//-- @ 0x00000268 :	 ADDI	 S0,S0,1
    instWord = 32'h80660001;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
//-- @ 0x0000026c :	 SW	 S0,OFSLEDG(GP)
    instWord = 32'h50c60008;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
//-- @ 0x00000270 :	 ADDI	 T1,FP,JALRET
    instWord = 32'h805d0278;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
        num32 = outRegd >> 2; $display("t1 rd %h should be 9e", num32);
        num32 = pcAdded >> 2; $display("pcAdded %h should be 9e", num32);
//-- @ 0x00000274 :	 JAL	 T0,JALTARG(FP)
    instWord = 32'hb04d009f;
        CLOCK_50 = 1'b1; #1 
        num32 = pcOut >> 2; $display("t0 pcOut %h should be 9d", num32);
        
        num32 = pcAdded >> 2; $display("t0 rd %h should be 9e", num32);
        num32 = outRegd >> 2; $display("t0 rd %h should be 9e", num32);

        CLOCK_50 = 1'b0; #1
        // note adds an extra one because half cycle is add
        num32 = pcOut >> 2; $display("pcOut %h", num32);
        num32 = pcAdded >> 2; $display("t0 rd %h should be 9e", num32);
        num32 = outRegd >> 2; $display("t0 rd %h should be 9e", num32);
  
        
//-- @ 0x0000027c :	 BNE	 T0,T1,JALFAILED
    instWord = 32'h69450001;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
        num32 = outReg1 >> 2; $display("t0 %h should be 9e", num32);
        num32 = outReg2 >> 2; $display("t1 %h should be 9e", num32);
        num32 = useImmPc; $display("branch? %h", num32);
//-- @ 0x00000280 :	 JAL	 T1,0(T0)
    instWord = 32'hb0540000;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
        num32 = outRegd >> 2; $display("rd %h", num32);
        num32 = outReg1 >> 2; $display("rs1 %h", num32);

//        -- @ 0x00000278 :	 BT	 T0,T0,JALWORKS
    instWord = 32'h68440006;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);


//-- @ 0x00000294 :	 ADDI	 S0,S0,1
    instWord = 32'h80660001;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
//-- @ 0x00000298 :	 SW	 S0,OFSLEDG(GP)
    // note, doesn't store because gp is not set correctly
    instWord = 32'h50c60008;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
    
        
/*        //-- @ 0x00000284 :	 NAND	 T0,FP,FP
    instWord = 32'h0c4dd000;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
//-- @ 0x00000288 :	 SW	 T0,OFSLEDR(GP)
    instWord = 32'h50c40004;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
//-- @ 0x0000028c :	 SW	 T0,OFSHEX(GP)
    instWord = 32'h50c40000;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
//-- @ 0x00000290 :	 BT	 T0,T0,JALFAILED
    instWord = 32'h6844fffc;
        CLOCK_50 = 1'b1; #1 CLOCK_50 = 1'b0; #1
        num32 = pcOut >> 2; $display("pcOut %h", num32);
    */
    end
    // t0 contained 80
    // t1 contained 81
endmodule
