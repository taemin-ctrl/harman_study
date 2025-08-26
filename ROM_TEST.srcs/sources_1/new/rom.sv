`timescale 1ns / 1ps

module rom(
    input logic clk,
    input logic rst,
    output logic en,
    output logic [9:0] x_pixel,
    output logic [9:0] y_pixel,
    output logic h_sync,
    output logic v_sync,
    output logic [7:0] red,
    output logic [7:0] blue,
    output logic [7:0] green 
    );
    localparam H_Visible_area = 640;	
    localparam H_Front_porch  = 16;	
    localparam H_Sync_pulse   = 96;	
    localparam H_Back_porch   = 48;	
    localparam H_Whole_line   = 800;

    localparam V_Visible_area = 480;    
    localparam V_Front_porch  = 10;	    
    localparam V_Sync_pulse   = 2;	    
    localparam V_Back_porch   = 33;	    
    localparam V_Whole_frame  = 525;

    logic [9:0] xcnt;
    logic [9:0] ycnt;
    logic [15:0] pdata;
    logic [15:0] mem[640*480-1:0];

    assign en = (xcnt < 640) && (ycnt < 480);
    assign x_pixel = en ? xcnt : 10'b0;
    assign y_pixel = en ? ycnt : 10'b0;

    assign h_sync = !((xcnt >= (H_Visible_area + H_Front_porch)) && (xcnt < (H_Visible_area + H_Front_porch + H_Sync_pulse)));
    assign v_sync = !((ycnt >= (V_Visible_area + V_Front_porch)) && (ycnt < (V_Visible_area + V_Front_porch + V_Sync_pulse)));

    always_ff @( posedge clk, posedge rst ) begin 
        if (rst) begin
            xcnt <= 0;
            ycnt <= 0;
        end
        else begin
            if (xcnt == 800 - 1) begin
                xcnt <= 0;
                if (ycnt == 525 - 1) begin
                    ycnt <= 0;
                end
                else begin
                    ycnt <= ycnt + 1;
                end
            end
            else begin
                xcnt <= xcnt + 1;
            end
        end
    end
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            pdata <= 0;
        end
        else begin
            if (en) begin
                pdata <= mem[y_pixel * 640 + x_pixel];
            end
            else begin
            pdata <= 0; 
            end
        end
    end
    
    assign red = {pdata[15:11],3'b111};
    assign blue = {pdata[10:5], 2'b11};
    assign green = {pdata[4:0],3'b111};

    initial begin
        $readmemh("mem.mem",mem);
    end
endmodule
