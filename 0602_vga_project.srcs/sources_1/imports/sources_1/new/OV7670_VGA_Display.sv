`timescale 1ns / 1ps

module OV7670_VGA_Display(
    input  logic clk,
    input  logic reset,
    input  logic sw, 

    output logic        ov7670_xclk,
    input  logic        ov7670_pclk,
    input  logic        ov7670_href,
    input  logic        ov7670_v_sync,
    input  logic [ 7:0] ov7670_data,
    
    output logic        h_sync,
    output logic        v_sync,
    output logic [ 3:0] red_port,
    output logic [ 3:0] green_port,
    output logic [ 3:0] blue_port,
    inout               sda,
    output logic        scl  
    );

    logic we, DE, w_rclk, oe, rclk;
    logic [15:0] wData, rData;  
    
    logic [3:0] sdata, fdata;

    logic [16:0] wAddr, rAddr;
    logic [9:0] x_pixel, y_pixel;
    logic [11:0] data00, data01, data02, data10, data11, data12, data20, data21, data22;
    logic [11:0] fdata00, fdata01, fdata02, fdata10, fdata11, fdata12, fdata20, fdata21, fdata22;
    logic pclk;
    logic [4:0] red;
    logic [5:0] green;
    logic [4:0] blue;
    assign red_port = red[4:1];
    assign green_port = green[5:2];
    assign blue_port = blue[4:1];

    pixel_clk_gen U_OV7670_Clk_Gen(
        .clk(clk),
        .reset(reset),
        .pclk(ov7670_xclk)
    );

    SCCB_Master U_SCCB(
        .clk(clk),
        .reset(reset),
        .sda(sda),  //sccb data
        .scl(scl)  //sccb clock
    );

    VGA_Controller U_VGA_Controller(
        .clk(clk),
        .reset(reset),
        .rclk(w_rclk),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .DE(DE),
        .pclk(pclk),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel)
    );

    QVGA_Controller U_QVGA_Controller(
        .clk(w_rclk),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .DE(DE),
        .rclk(rclk),
        .d_en(oe),
        .sw(sw),
        .rAddr(rAddr),
        .rData(rData),
        .red_port(red),
        .green_port(green),
        .blue_port(blue) 
    );

    OV7670_MemController U_OV7670_MemController(
        .pclk(ov7670_pclk),
        .reset(reset),
        .href(ov7670_href),
        .v_sync(ov7670_v_sync),
        .ov7670_data(ov7670_data),
        .we(we),
        .wAddr(wAddr),
        .wData(wData)
    );

    frame_buffer1 U_frame_buffer(
        .wclk(ov7670_pclk),
        .we(we),
        .wAddr(wAddr),
        .wData(wData),
        .rclk(rclk),
        .oe(oe),
        .rAddr(rAddr),
        .rData(rData)
    );
    
endmodule

module grayscale_converter (
    input logic [3:0] red_port,
    input logic [3:0] green_port,
    input logic [3:0] blue_port,
    output logic [11:0] gray_port
);
    logic [10:0] red;
    logic [11:0] green;
    logic [8:0] blue; 
    logic [12:0] gray;
    assign red = (red_port * 77);
    assign green = (green_port * 150);
    assign blue = (blue_port * 29);
    assign gray = red + green + blue;

    assign gray_port = gray[12:1];
endmodule

module line_buffer_640 (
    input logic pclk,
    input logic [9:0] x_pixel,
    input logic [9:0] y_pixel,
    input logic [11:0] data,
    output logic [11:0] data_00,
    output logic [11:0] data_01,
    output logic [11:0] data_02,
    output logic [11:0] data_10,
    output logic [11:0] data_11,
    output logic [11:0] data_12,
    output logic [11:0] data_20,
    output logic [11:0] data_21,
    output logic [11:0] data_22
);
    // median filter parameters
    reg [11:0] fmem0[639:0];
    reg [11:0] fmem1[639:0];
    reg [11:0] fmem2[639:0];
    reg [11:0] temp;
    always_ff @(posedge pclk) begin
        if (x_pixel < 640 && y_pixel < 480) begin
            temp <= fmem2[x_pixel];
            fmem2[x_pixel] <= fmem1[x_pixel];
            fmem1[x_pixel] <= fmem0[x_pixel];
            fmem0[x_pixel] <= data;
        end
    end

    always_ff @(posedge pclk) begin
        data_00 <= (y_pixel == 0 || x_pixel == 0) ? 0 : temp;
        data_01 <= (y_pixel == 0) ? 0 : fmem2[x_pixel];
        data_02 <= (y_pixel == 0 || x_pixel == 639) ? 0 : fmem2[x_pixel+1];
        data_10 <= (x_pixel == 0) ? 0 : fmem2[x_pixel-1];
        data_11 <= fmem1[x_pixel];
        data_12 <= (x_pixel == 639) ? 0 : fmem1[x_pixel+1];
        data_20 <= (x_pixel == 0 || y_pixel == 479) ? 0 : fmem1[x_pixel-1];
        data_21 <= (y_pixel == 479) ? 0 : fmem0[x_pixel];
        data_22 <= (x_pixel == 639 || y_pixel == 479) ? 0 : fmem0[x_pixel+1];
    end

endmodule

module unsharp_masking (
    input  logic [3:0] original,   // 원본 픽셀
    input  logic [3:0] blurred,    // 가우시안 필터 결과
    output logic [3:0] sharpened   // 샤프닝된 결과
);
    logic [4:0] doubled_original;
    wire signed [4:0] temp_sharpened;

    // 원본 × 2
    assign doubled_original = original << 1;

    // Sharpened = 2 * original - blurred
    assign temp_sharpened = doubled_original - blurred;

    // Saturation 처리 (0~15 범위로 클램핑)
    always_comb begin
        if (temp_sharpened > 5'sd15)
            sharpened = 4'hf;
        else if (temp_sharpened < 5'sd0)
            sharpened = 4'h0;
        else
            sharpened = temp_sharpened[3:0];
    end
endmodule

module Sharpening_Filter (
    input  logic [11:0] data00, data01, data02,
    input  logic [11:0] data10, data11, data12,
    input  logic [11:0] data20, data21, data22,
    output logic [11:0] shdata
);

    logic signed [11:0] win[0:8];  //음수일 수도 있어서 signed 처리
    logic signed [13:0] filtered;  //음수일 수도 있어서 signed 처리
    logic [3:0] r_result, g_result, b_result;

    logic [3:0] R[0:8];
    logic [3:0] G[0:8];
    logic [3:0] B[0:8];

    assign win[0] = data00;  // P0
    assign win[1] = data10;  // P1
    assign win[2] = data20;  // P2
    assign win[3] = data01;  // P3
    assign win[4] = data11;  // P4 (중앙)
    assign win[5] = data21;  // P5
    assign win[6] = data02;  // P6
    assign win[7] = data12;  // P7
    assign win[8] = data22;  // P8

    always_comb begin
        for (int i = 0; i < 9; i++) begin
            R[i] = win[i][11:8];  // 상위 4비트
            G[i] = win[i][7:4];  // 중간 4비트
            B[i] = win[i][3:0];  // 하위 4비트
        end
    end

    //assign filtered = -win[1] - win[3] + 5 * win[4] - win[5] - win[7];

    // R 필터
    logic signed [7:0] r_filtered;
    assign r_filtered = -R[1] - R[3] + 5 * R[4] - R[5] - R[7] + 2;
    assign r_result = (r_filtered < 0) ? 4'd0 :(r_filtered > 15) ? 4'd15 : r_filtered[3:0];

    // G 필터
    logic signed [7:0] g_filtered;
    assign g_filtered = -G[1] - G[3] + 5 * G[4] - G[5] - G[7] + 2;
    assign g_result = (g_filtered < 0) ? 4'd0 :(g_filtered > 15) ? 4'd15 : g_filtered[3:0];

    // B 필터
    logic signed [7:0] b_filtered;
    assign b_filtered = -B[1] - B[3] + 5 * B[4] - B[5] - B[7] + 2;
    assign b_result = (b_filtered < 0) ? 4'd0 : (b_filtered > 15) ? 4'd15 : b_filtered[3:0];


    assign shdata = {r_result, g_result, b_result};  // 12비트 R4G4B4 출력
endmodule