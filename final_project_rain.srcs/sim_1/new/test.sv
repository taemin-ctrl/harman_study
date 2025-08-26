`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/20 20:31:25
// Design Name: 
// Module Name: test
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


module test();
    logic clk;
    logic rst;
    logic [7:0] pixel;
    logic [7:0] abs_diff[4:0];
    logic [23:0] variance;
    logic [7:0] mean_final[4:0];
    logic [23:0] variance_final[4:0];
    logic [15:0] weight_preserve[4:0];
    logic [15:0] weight_update[4:0];
    logic [7:0] omean[4:0];
    logic [23:0] ovariance[4:0];
    logic [15:0] oweight[4:0];

    gaussian_update dut(.*);
    always #5 clk = ~clk;

    task random(int k);
        for (int i = 0; i < k ; i++ ) begin
            pixel = $urandom % 256;
            variance = $urandom % 64;
            for (int i = 0; i < 5; i++) begin
                abs_diff[i] = $urandom_range(0, 255);
                mean_final[i] = $urandom_range(0, 255);
                variance_final[i] = $urandom_range(1, 24'h00FF00);  // 적절한 범위로 제한
                weight_preserve[i] = $urandom_range(0, 65535);
                weight_update[i] = $urandom_range(0, 65535);
            end
            #10;
        end
    endtask //automatic
    initial begin
        clk = 0;
        rst = 1;
        pixel = 0;
        variance = 0;
        for (int i = 0; i < 5; i++) begin
            abs_diff[i] = 0;
            mean_final[i] = 0;
            variance_final[i] = 0;  // 적절한 범위로 제한
            variance[i] = 0;
            weight_preserve[i] = 0;
            weight_update[i] = 0;
        end
        # 10 rst = 0;
        random(10);

    end
endmodule
