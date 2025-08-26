`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/22 14:10:20
// Design Name: 
// Module Name: snow_rain_remove_filter
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


module snow_rain_remove_filter(
    input logic clk,
    input logic rst,
    output logic [15:0] filter_data
    );

    logic [15:0] med2unsharp;
    logic [15:0] inpaint2highlight;

    Removal_Filter Inpainting_filter(
        .clk(clk),
        .reset(reset),

    // 입력 스트림
        .orig_rgb(),   // 원본 프레임 픽셀
        .bg_rgb(),     // 배경 프레임 픽셀 (MOG2에서 추출)
        .mask_bit(),   // 눈 마스크(1=눈, 0=배경/객체 아님)
        .de_in(),      // data enable (1 clk per pixel)
        .bg_valid(),   // 배경 프레임이 유효한지 플래그

        // 출력 스트림
        .out_rgb(inpaint2highlight),
        .de_out()
    );

    Highlight_Removal #(
        .HIGHLIGHT_THRESHOLD(8'd230) // highlight_mask 및 출력 마스크 결정
    ) U_Highlight_Removal(
        .clk(clk),
        .reset(rst),       // 비동기 active-low reset
        .i_data(inpaint2highlight),
        .snow_mask(),
        .o_snow_mask()
    );

    Median_Filter U_Median_Filter(
        .clk(clk),
        .i_data(),
        .de(),
        .sdata(med2unsharp)                 
    );

    Unsharp_Filter U_Unsharp_Filter(
        .clk(clk),
        .reset(reset),
        .i_data(med2unsharp),
        .de(),
        .o_data(filter_data),
        .o_de()
    );

endmodule