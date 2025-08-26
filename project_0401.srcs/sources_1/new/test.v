`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/01 10:32:11
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
module test (
    input clk,
    input rst,
    input sw,
    output [7:0] seg,
    output [3:0] ans
);

    wire tick;

    wire w_tick;

    wire [13:0] digit;
    
    wire [3:0] num1;
    wire [3:0] num10;
    wire [3:0] num100;
    wire [3:0] num1000;
    wire [3:0] num;

    wire [1:0] sel;

    
    clk_div u_clk_div(
        .clk(clk),
        .rst(rst),
        .o_tick(tick)
    );

    counter u_counter(
        .clk(tick),
        .rst(rst),
        .sw(sw),
        .digit(digit)
    );

    digit_div u_digit_div(
        .digit(digit),
        .num1(num1),
        .num10(num10),
        .num100(num100),
        .num1000(num1000)
    );
    
    clk_div_100us u_clk_10us(
        .clk(clk),
        .rst(rst),
        .o_tick(w_tick)
    );

    cnt_4 u_cnt_4(
        .clk(w_tick),
        .rst(rst),
        .sel(sel)
    );

    mux u_mux(
        .sel(sel),
        .num1(num1),
        .num10(num10),
        .num100(num100),
        .num1000(num1000),
        .num(num),
        .ans(ans) 
    );

    fnd u_fnd(
        .num(num),
        .seg(seg)
    );
endmodule

module counter #(
    CNT = 10000
)(
    input clk,
    input rst,
    input sw,
    output [$clog2(CNT)-1:0] digit
    );

    reg [$clog2(CNT)-1:0] cnt;
    assign digit = cnt;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            cnt <= 0;
        end
        else begin
            if (sw) begin
                if (cnt == 0) begin
                    cnt <= 9999;
                end
                else begin
                    cnt <= cnt - 1'b1;
                end
            end
            else begin
                if (cnt == 9999) begin
                    cnt <= 0;
                end
                else begin
                    cnt <= cnt + 1'b1;
                end
            end
        end
    end
endmodule

module digit_div #(
    K = 10000
)(
    input [$clog2(K)-1:0] digit,
    output [3:0] num1,
    output [3:0] num10,
    output [3:0] num100,
    output [3:0] num1000
);
    assign num1 = digit % 10;
    assign num10 = (digit % 100)/10;
    assign num100 = (digit % 1000) / 100;
    assign num1000 = digit / 1000;
endmodule

module mux (
    input [1:0] sel,
    input [3:0] num1,
    input [3:0] num10,
    input [3:0] num100,
    input [3:0] num1000,
    output [3:0] num,
    output [3:0] ans 
);
    reg [3:0] r_num;
    assign num = r_num;

    reg [3:0] r_ans;
    assign ans = r_ans;
    always @(*) begin
        case (sel)
            2'b00: begin 
                r_num = num1;
                r_ans = 4'b1110; 
            end
            2'b01: begin
                r_num = num10;
                r_ans = 4'b1101; 
            end
            2'b10: begin
                r_num = num100;
                r_ans = 4'b1011;
            end
            2'b11: begin
                r_num = num1000;
                r_ans = 4'b0111;
            end
        endcase
    end
endmodule

module clk_div (
    input clk,
    input rst,
    output o_tick
);
    localparam  CLOCK = 100 * 1000 * 100;
    reg tick;
    assign o_tick = tick;

    reg [$clog2(CLOCK)-1:0]cnt;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            tick <= 0;
            cnt <= 0;        
        end
        else begin
            if (cnt == CLOCK-1) begin
                tick <= 1;
                cnt <= 0;
            end        
            else begin
                tick <= 0;
                cnt <= cnt + 1;
            end
        end
    end
endmodule

module cnt_4(
    input clk,
    input rst,
    output [1:0] sel
);
    reg [1:0] r_sel;
    assign sel = r_sel;  
    
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_sel <= 0;
        end
        else begin
            r_sel <= r_sel + 1'b1;
        end
    end
endmodule

module fnd (
    input [3:0] num,
    output [7:0] seg
);
    reg [7:0] r_seg;
    assign seg = r_seg;
    
    always @(*) begin
        case (num)
            4'd0: r_seg = 8'b1100_0000;  
            4'd1: r_seg = 8'b1111_1001;
            4'd2: r_seg = 8'b1010_0100;
            4'd3: r_seg = 8'b1011_0000;
            4'd4: r_seg = 8'b1001_1001;
            4'd5: r_seg = 8'b1001_0010;
            4'd6: r_seg = 8'b1000_0010;
            4'd7: r_seg = 8'b1101_1000;
            4'd8: r_seg = 8'b1000_0000;
            4'd9: r_seg = 8'b1001_0000;
            default: r_seg = 8'b1111_1111; 
        endcase
    end
endmodule

module clk_div_100us(
    input clk,
    input rst,
    output o_tick
);
    reg [23:0] cnt;
    
    reg r_tick;
    assign o_tick = r_tick;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            cnt <= 0;
            r_tick <= 0;        
        end
        else begin
            if (cnt == 9999) begin
                cnt <= 0;
                r_tick <= 1;
            end
            else begin
                cnt <= cnt + 1;
                r_tick <= 0;
            end
        end
    end
endmodule