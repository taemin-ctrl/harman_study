`timescale 1ns / 1ps

module tb_APB_BUS();

    // global siganl
    logic        PCLK;
    logic        PRESET;
    //Interface Signals
    logic [31:0] PADDR;
    logic        PSEL0;    
    logic        PSEL1;
    logic        PSEL2;
    logic        PSEL3;
    logic        PENABLE;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic [31:0] PRDATA0;
    logic [31:0] PRDATA1;
    logic [31:0] PRDATA2;
    logic [31:0] PRDATA3;
    logic        PREADY0;
    logic        PREADY1;
    logic        PREADY2;
    logic        PREADY3;
    //rnal Interface Signals
    logic        transfer; // trigger signal
    logic        ready;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic        write; // 1 : write, 0 : read

    APB_Master U_APB_Master(
        .*
    );

    APB_Slave U_Slave_Periph0(
        .*,
        .PSEL(PSEL0),
        .PRDATA(PRDATA0),
        .PREADY(PREADY0)
    );

    always #5 PCLK = ~PCLK;

    initial begin
        PCLK = 0;
        PRESET = 1;
        #10 PRESET = 0;

        @(posedge PCLK);
        @(posedge PCLK);
        #1; 
        addr = 32'h1000_0000;
        write = 1;
        wdata = 10;
        transfer = 1;
        wait(ready == 1'b1);
        #9;
        
        @(posedge PCLK);
        @(posedge PCLK);
        #1; 
        addr = 32'h1000_0004;
        write = 1;
        wdata = 11;
        transfer = 1;
        wait(ready == 1'b1);
        #9;

        @(posedge PCLK);
        @(posedge PCLK);
        #1; 
        addr = 32'h1000_0008;
        write = 1;
        wdata = 12;
        transfer = 1;
        wait(ready == 1'b1);
        #9;

        @(posedge PCLK);
        @(posedge PCLK);
        #1; 
        addr = 32'h1000_000c;
        write = 1;
        wdata = 13;
        transfer = 1;
        wait(ready == 1'b1);
        #9;

///////////////////////////////////////////
        @(posedge PCLK);
        #1; 
        addr = 32'h1000_0000;
        transfer = 1;
        write = 0;
        wait(ready == 1'b1);
        
        @(posedge PCLK);
        #1; 
        addr = 32'h1000_0004;
        transfer = 1;
        write = 0;
        wait(ready == 1'b1);

        @(posedge PCLK);
        #1; 
        addr = 32'h1000_0008;
        transfer = 1;
        write = 0;
        wait(ready == 1'b1);

        @(posedge PCLK);
        #1 addr = 32'h1000_000c;
        transfer = 1;
        write = 0;
        wait(ready == 1'b1);

    end
endmodule
