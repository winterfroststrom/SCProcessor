module DataMemoryController(wrMEM, addr, isHex, isLedr, isLedg, isSwitches, isWrRegMem, isIoOut);

    parameter DATA_BIT_WIDTH;

    input wrMEM;
    input[DATA_BIT_WIDTH - 1:0] addr;
    output isHex;
    output isLedr;
    output isLedg;
    output isSwitches;
    output isWrRegMem;
    output isIoOut;
    
    wire isIo;
    assign isIo = &{addr[31:28]};

    wire isIoIn;
    assign isIoIn = wrMEM & isIo & addr[4];
    wire isHex;
    assign isHex = isIoIn & ~addr[2] & ~addr[3];
    wire isLedr;
    assign isLedr = isIoIn & addr[2];
    wire isLedg;
    assign isLedg = isIoIn & addr[3];
    
    wire isIoOut;
    assign isIoOut = addr[4] & isIo;
    wire isSwitches;
    assign isSwitches = addr[2];
    
    wire isWrRegMem;
    assign isWrRegMem = wrMEM & ~isIo;

endmodule
