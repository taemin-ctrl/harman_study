`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/16 16:30:38
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
    logic clk;
    logic rst;
    logic btn;
    logic [15:0] sw;
    logic  [7:0] seg;
    logic  [3:0] seg_comm;
    
    SPI dut(
        .*
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #10 rst = 0;
        btn = 1;
        sw = 16'b1111_1111_1111_1111;
        #30 btn =0;
    end
endmodule
