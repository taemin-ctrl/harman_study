`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/26 15:01:15
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb();
    
    // global signal
    logic        PCLK;
    logic        PRESET;
    // APB Interface Signals
    logic [ 3:0] PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PENABLE;
    logic        PSEL;
    logic [31:0] PRDATA;
    logic        PREADY;
    
    fifo_Periph dut(.*);

task automatic apb_write(input logic [3:0] addr, input logic [31:0] data);
    begin
        @(posedge PCLK);
        // Setup phase
        PSEL    <= 1;
        PWRITE  <= 1;
        PADDR   <= addr;
        PWDATA  <= data;
        PENABLE <= 0;

        @(posedge PCLK);
        PENABLE <= 1;

        wait (PREADY == 1'b1);

        PSEL    <= 0;
        PENABLE <= 0;
    end
endtask

task automatic apb_read(input logic [3:0] addr, output logic [31:0] data_out);
    begin
        @(posedge PCLK);
        PSEL    <= 1;
        PWRITE  <= 0;
        PADDR   <= addr;
        PENABLE <= 0;

        @(posedge PCLK);
        PENABLE <= 1;

        wait (PREADY == 1'b1);
        data_out = PRDATA;
        PSEL    <= 0;
        PENABLE <= 0;
    end
endtask

    always #5 PCLK = ~PCLK;

    initial begin
        PCLK = 0;
        PRESET = 1;
        PENABLE = 0;
        PWRITE = 0;
        #10;
        PRESET = 0; 
        apb_read(4'h0,PRDATA);
        if (PRDATA[1:0] !=2'b10) apb_write(4'h4, 5);
        apb_read(4'h0,PRDATA);
        if (PRDATA[1:0] !=2'b10) apb_write(4'h4, 6);
        apb_read(4'h0,PRDATA);
        if (PRDATA[1:0] !=2'b10) apb_write(4'h4, 7);
        apb_read(4'h0,PRDATA);
        if (PRDATA[1:0] !=2'b10) apb_write(4'h4, 8);
        apb_read(4'h0,PRDATA);
        if (PRDATA[1:0] !=2'b10) apb_write(4'h4, 9);
        
        apb_read(4'h0,PRDATA);
        if (PRDATA[1:0] !=2'b01) apb_read(4'h8,PRDATA);
        apb_read(4'h0,PRDATA);
        if (PRDATA[1:0] !=2'b01) apb_read(4'h8,PRDATA);
        apb_read(4'h0,PRDATA);
        if (PRDATA[1:0] !=2'b01) apb_read(4'h8,PRDATA);
        apb_read(4'h0,PRDATA);
        if (PRDATA[1:0] !=2'b01) apb_read(4'h8,PRDATA);
        apb_read(4'h0,PRDATA);
        if (PRDATA[1:0] !=2'b01) apb_read(4'h8,PRDATA);


        // finish
        #100 $finish;

    end


endmodule