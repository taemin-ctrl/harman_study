`timescale 1ns / 1ps

module OV7670_VGA_Display(
    input  logic clk,
    input  logic reset,
    input  logic [4:0] sw, 

    output logic        ov7670_xclk,
    input  logic        ov7670_pclk,
    input  logic        ov7670_href,
    input  logic        ov7670_v_sync,
    input  logic [ 7:0] ov7670_data,
    
    output logic        h_sync,
    output logic        v_sync,
    output logic [ 3:0] red_port,
    output logic [ 3:0] green_port,
    output logic [ 3:0] blue_port
    );

    logic we, DE, w_rclk, oe, rclk;
    logic [15:0] wData, rData;
    logic [16:0] wAddr, rAddr;
    logic [9:0] x_pixel, y_pixel;
    logic [3:0] red, green, blue;
    logic [3:0] gred, ggreen, gblue;

    logic href_1, href_2, v_sync_1, v_sync_2;
    logic pclk_1, pclk_2;
    logic [7:0] data_1, data_2;

    assign red_port = sw[3] ? gred : sw[0] ? 4'b0 : red;
    assign green_port = sw[3] ? ggreen : sw[1] ? 4'b0 : green;
    assign blue_port = sw[3] ? gblue : sw[2] ? 4'b0 : blue;

    always_ff @( posedge clk, posedge reset ) begin : blockName
        if (reset) begin
            pclk_1 <= 0;
            pclk_2 <= 0;
            href_1 <= 0;
            href_2 <= 0;
            v_sync_1 <= 0;
            v_sync_2 <= 0;
            data_1 <= 0;
            data_2 <= 0;
        end
        else begin
            pclk_1 <= ov7670_pclk;
            pclk_2 <= pclk_1;
            href_1 <= ov7670_href;
            href_2 <= href_1;
            v_sync_1 <= ov7670_v_sync;
            v_sync_2 <= v_sync_1;
            data_1 <= ov7670_data;
            data_2 <= data_1;
        end
    end

    pixel_clk_gen U_OV7670_Clk_Gen(
        .clk(clk),
        .reset(reset),
        .pclk(ov7670_xclk)
    );

    VGA_Controller U_VGA_Controller(
        .clk(clk),
        .reset(reset),
        .rclk(w_rclk),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .DE(DE),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel)
    );

    QVGA_Controller U_QVGA_Controller(
        .clk(w_rclk),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .DE(DE),
        .sw(sw[4]),
        .rclk(rclk),
        .d_en(oe),
        .rAddr(rAddr),
        .rData(rData),
        .red_port(red),
        .green_port(green),
        .blue_port(blue) 
    );

    OV7670_MemController U_OV7670_MemController(
        .pclk(pclk_2),
        .reset(reset),
        .href(href_2),
        .v_sync(v_sync_2),
        .ov7670_data(data_2),
        .we(we),
        .wAddr(wAddr),
        .wData(wData)
    );

    frame_buffer U_frame_buffer(
        .wclk(pclk_2),
        .we(we),
        .wAddr(wAddr),
        .wData(wData),
        .rclk(rclk),
        .oe(oe),
        .rAddr(rAddr),
        .rData(rData)
    );

    grayscale_converter u_gray(
        .red_port(red),
        .green_port(green),
        .blue_port(blue),
        .g_red_port(gred),
        .g_green_port(ggreen),
        .g_blue_port(gblue)
    );
endmodule

module grayscale_converter (
    input logic [3:0] red_port,
    input logic [3:0] green_port,
    input logic [3:0] blue_port,
    output logic [3:0] g_red_port,
    output logic [3:0] g_green_port,
    output logic [3:0] g_blue_port
);
    logic [10:0] red;
    logic [11:0] green;
    logic [8:0] blue; 
    logic [12:0] gray;
    assign red = (red_port * 77);
    assign green = (green_port * 150);
    assign blue = (blue_port * 29);
    assign gray = red + green + blue;

    assign g_red_port = gray[12:9];
    assign g_green_port = gray[12:9];
    assign g_blue_port = gray[12:9];
endmodule
