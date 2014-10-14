module TestDataMemory();
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

    reg clk, wrMEM;
    reg[31:0] addr, dataIn;
    reg[9:0] switches;
    reg[3:0] keys;
    
    wire[9:0] ledr;
    wire[7:0] ledg;
    wire[6:0] hex0, hex1, hex2, hex3;
    wire[31:0] dataOut;
    
    DataMemory unit0(
        clk, wrMEM, addr, dataIn, switches, keys,
        ledr, ledg, hex0, hex1, hex2, hex3, dataOut
    );


    reg[9:0] LEDR;
    reg[7:0] LEDG;
    reg[6:0] HEX0, HEX1, HEX2, HEX3;
    reg[31:0] OUT;
    
    initial begin
        switches = 10'b0;
        keys = 4'b0;
        dataIn = 32'h0000;
        addr = 32'h0000;
        
        clk = 1'b0; wrMEM = 1'b0;
        #1
        LEDR = ledr;LEDG = ledg;HEX0 = hex0;HEX1 = hex1;HEX2 = hex2;HEX3 = hex3;
        OUT = dataOut;
        $display("nothing");
        $display("LEDR %b", LEDR);
        $display("LEDG %b", LEDG);
        $display("HEX %b %b %b %b", HEX3, HEX2, HEX1, HEX0);
        $display("OUT %b", OUT);
        
        clk = 1'b1; wrMEM = 1'b0;
        #1
        clk = 1'b0;
        #1
        LEDR = ledr;LEDG = ledg;HEX0 = hex0;HEX1 = hex1;HEX2 = hex2;HEX3 = hex3;
        OUT = dataOut;
        $display("nothing");
        $display("LEDR %b", LEDR);
        $display("LEDG %b", LEDG);
        $display("HEX %b %b %b %b", HEX3, HEX2, HEX1, HEX0);
        $display("OUT %b", OUT);
        

        clk = 1'b1; wrMEM = 1'b1;
        addr = ADDR_HEX;
        dataIn = 32'h00000bad;
        #1
        clk = 1'b0;
        #1
        LEDR = ledr;LEDG = ledg;HEX0 = hex0;HEX1 = hex1;HEX2 = hex2;HEX3 = hex3;
        OUT = dataOut;
        $display("write hex");
        $display("LEDR %b", LEDR);
        $display("LEDG %b", LEDG);
        $display("HEX %b %b %b %b", HEX3, HEX2, HEX1, HEX0);
        $display("OUT %b", OUT);
        
        

        clk = 1'b1; wrMEM = 1'b0;
        dataIn = 32'hF8F8F8F8;
        addr = ADDR_SW;
        switches = 10'b1010101010;
        #1
        clk = 1'b0;
        #1
        LEDR = ledr;LEDG = ledg;HEX0 = hex0;HEX1 = hex1;HEX2 = hex2;HEX3 = hex3;
        OUT = dataOut;
        $display("read switches");
        $display("LEDR %b", LEDR);
        $display("LEDG %b", LEDG);
        $display("HEX %b %b %b %b", HEX3, HEX2, HEX1, HEX0);
        $display("OUT %b", OUT);

        clk = 1'b1; wrMEM = 1'b0;
        addr = ADDR_KEY;
        dataIn = 32'hF8F8F8F8;
        keys = 4'b0101;
        #1
        clk = 1'b0;
        #1
        LEDR = ledr;LEDG = ledg;HEX0 = hex0;HEX1 = hex1;HEX2 = hex2;HEX3 = hex3;
        OUT = dataOut;
        $display("read keys");
        $display("LEDR %b", LEDR);
        $display("LEDG %b", LEDG);
        $display("HEX %b %b %b %b", HEX3, HEX2, HEX1, HEX0);
        $display("OUT %b", OUT);

        clk = 1'b1; wrMEM = 1'b1;
        dataIn = 32'hff77ff77;
        addr = ADDR_LEDR;
        #1
        clk = 1'b0;
        #1
        LEDR = ledr;LEDG = ledg;HEX0 = hex0;HEX1 = hex1;HEX2 = hex2;HEX3 = hex3;
        OUT = dataOut;
        $display("write ledr");
        $display("LEDR %b", LEDR);
        $display("LEDG %b", LEDG);
        $display("HEX %b %b %b %b", HEX3, HEX2, HEX1, HEX0);
        $display("OUT %b", OUT);

        clk = 1'b1; wrMEM = 1'b1;
        dataIn = 32'hff0fff0f;
        addr = ADDR_LEDG;
        #1
        clk = 1'b0;
        #1
        LEDR = ledr;LEDG = ledg;HEX0 = hex0;HEX1 = hex1;HEX2 = hex2;HEX3 = hex3;
        OUT = dataOut;
        $display("write ledg");
        $display("LEDR %b", LEDR);
        $display("LEDG %b", LEDG);
        $display("HEX %b %b %b %b", HEX3, HEX2, HEX1, HEX0);
        $display("OUT %b", OUT);

        clk = 1'b1; wrMEM = 1'b1;
        dataIn = 32'h00001234;
        addr = ADDR_HEX;
        #1
        clk = 1'b0;
        #1
        LEDR = ledr;LEDG = ledg;HEX0 = hex0;HEX1 = hex1;HEX2 = hex2;HEX3 = hex3;
        OUT = dataOut;
        $display("write hex");
        $display("LEDR %b", LEDR);
        $display("LEDG %b", LEDG);
        $display("HEX %b %b %b %b", HEX3, HEX2, HEX1, HEX0);
        $display("OUT %b", OUT);

        
    end
    
endmodule
