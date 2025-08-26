`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/21 10:52:18
// Design Name: 
// Module Name: Separate_BackGround
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


module history_count #(
    CNT = 8
)(
    input logic clk, 
    input logic rst,
    input logic start,
    input logic out_pixel,
    output logic history 
    );

    logic mem [7:0][76799:0];
    logic [16:0] addr;

    always_ff @( posedge clk, posedge rst ) begin 
        if (rst) begin
            addr <= 0;
            history <= 0;
        end
        else begin
            if (start) begin
                mem[0][addr] <= out_pixel;
                for (int i = 1; i <8; i++) begin
                    mem[i] <= mem[i-1];
                end 
                if (addr == 76799) begin
                    addr <= 0;
                end
                else begin
                    addr <= addr + 1;
                end
            end
            history <= mem[0][addr] + mem[1][addr] + mem[2][addr] + mem[3][addr] + mem[4][addr] + mem[5][addr] + mem[6][addr] +mem[7][addr]; 
        end
    end
endmodule
