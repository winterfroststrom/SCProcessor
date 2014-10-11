module Project2(SW,KEY,LEDR,LEDG,HEX0,HEX1,HEX2,HEX3,CLOCK_50);
  input  [9:0] SW;
  input  [3:0] KEY;
  input  CLOCK_50;
  output [9:0] LEDR;
  output [7:0] LEDG;
  output [6:0] HEX0,HEX1,HEX2,HEX3;
 
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
  
  parameter IMEM_INIT_FILE               = "Sorter2.mif";
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


  //PLL, clock genration, and reset generation
  wire clk, lock;
  //Pll pll(.inclk0(CLOCK_50), .c0(clk), .locked(lock));
  PLL   PLL_inst (.inclk0 (CLOCK_50),.c0 (clk),.locked (lock));
  wire reset = ~lock;
  

  // PC module
  wire[DBITS - 1: 0] pcOut;
  InstrFetch pc(clk, reset, imm32, pcMux, pcOut);

  // Instruction Memoryy
  wire[IMEM_DATA_BIT_WIDTH - 1: 0] instWord;
  InstMemory #(IMEM_INIT_FILE, IMEM_ADDR_BIT_WIDTH, IMEM_DATA_BIT_WIDTH) instMem (pcOut[IMEM_PC_BITS_HI - 1: IMEM_PC_BITS_LO], instWord);
  
  // Instruction Decorder
  wire[OP_BIT_WIDTH - 1: 0] op1, op2;
  wire[REG_INDEX_BIT_WIDTH - 1: 0] rd, rs1, rs2;
  wire[INST_BIT_WIDTH / 2: 0] imm16;
  Decoder instrDecoder (instWord, op1, op2, rd, rs1, rs2, imm16);

  wire[31:0] outReg1, outReg2;
  RegisterFile registerFile (clk, reset, wrtEn, rd, rs1, rs2, wrtData, outReg1, outReg2);

  wire[31:0] imm32;
  SignExtension #(16, 32) signExtender (imm16, imm32);
  
  // Create ALU unit
  
  // Put the code for data memory and I/O here
  
  // KEYS, SWITCHES, HEXS, and LEDS are memeory mapped IO
    
endmodule

