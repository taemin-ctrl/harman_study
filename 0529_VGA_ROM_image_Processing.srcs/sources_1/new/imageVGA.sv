`timescale 1ns / 1ps

module imageVGA(
    input logic clk,
    input logic reset,
    input logic [3:0] sw,
    output logic h_sync,
    output logic v_sync,
    output logic [3:0] red_port,
    output logic [3:0] green_port,
    output logic [3:0] blue_port
    );

    logic DE;
    logic [9:0] x_pixel;
    logic [9:0] y_pixel;
    logic [3:0] red, green, blue;
    logic [3:0] g_red, g_green, g_blue;
    
    assign red_port = sw[3] ? g_red : sw[0] ? 4'b0 : red;
    assign green_port = sw[3] ? g_green : sw[1] ? 4'b0 : green;
    assign blue_port = sw[3] ? g_blue : sw[2] ? 4'b0 : blue;

    VGA_Controller U_VGA_Controller(
        .*
    );

    Image_Rom U_Image_Rom(
        .*,
        .red_port(red),
        .blue_port(green),
        .green_port(blue)
    );

    grayscale_converter U_gray(
        .red_port(red),
        .green_port(green),
        .blue_port(blue),
        .g_red_port(g_red),
        .g_green_port(g_green),
        .g_blue_port(g_blue)
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
