`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/08 16:27:43
// Design Name: 
// Module Name: tb_RV32I
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


module tb_RV32I();
    logic clk;
    logic reset;

    MCU dut(
        .*
    );

    always #5 clk = ~clk;
    initial begin
        clk = 0;
        reset = 1;
        #10 reset = 0;

    end
endmodule
