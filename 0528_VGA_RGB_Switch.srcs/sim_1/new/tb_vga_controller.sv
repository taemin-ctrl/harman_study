`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/28 14:49:57
// Design Name: 
// Module Name: tb_vga_controller
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


module tb_vga_controller();
    logic clk;
    logic reset;
    logic [3:0] sw_red;
    logic [3:0] sw_green;
    logic [3:0] sw_blue;
    logic h_sync;
    logic v_sync;
    logic [3:0] red_port;
    logic [3:0] green_port;
    logic [3:0] blue_port;

    VGA_Controller dut(
        .*
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        #10 reset = 0;

        #10 sw_red = 0; sw_green = 0; sw_blue = 0;
    end
endmodule
