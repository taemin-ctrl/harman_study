`timescale 1ns / 1ps

module fnd_controller(
    input clk,
    input reset,
    input i_tick,
    input [13:0] fnddata,
    output [3:0] fndcom,
    output [7:0]fndfont
    );

    wire tick;
    wire dot;

    wire [1:0] digit_sel;

    wire [3:0] digit_1, digit_10, digit_100, digit_1000;

    wire [3:0] digit;
 
    clk_div_1khz u_clk_div_1khz(
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    counter_4 u_counter_4(
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .count(digit_sel)
    );

    decoder_2x4 u_decoder_2x4(
        .x(digit_sel),
        .y(fndcom)
    );

    digitsplitter u_digit_splitter(
        .fnddata(fnddata),
        .digit_1(digit_1),
        .digit_10(digit_10),
        .digit_100(digit_100),
        .digit_1000(digit_1000)
    );

    mux_4x1 u_mux(
        .sel(digit_sel),
        .dot(dot),
        .x0(digit_1),
        .x1(digit_10),
        .x2(digit_100),
        .x3(digit_1000),
        .y(digit),
        .seg_dot(fndfont[7])
    );

    fnd u_fnd(
        .num(digit),
        .seg(fndfont[6:0])
    );

    cnt_dot u_cnt_dot(
        .tick(i_tick),
        .reset(reset),
        .dot(dot)
);
endmodule

module clk_div_1khz(
    input clk,
    input reset,
    output reg tick
);
    reg [$clog2(100_000)-1:0] div_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end
        else begin
            if (div_counter == 100_000 -1) begin
                div_counter <= 0;
                tick <= 1'b1;
            end
            else begin
                div_counter <= div_counter + 1;
                tick <= 1'b0;
            end
        end
    end
endmodule

module counter_4(
    input clk,
    input reset,
    input tick,
    output reg [1:0] count
);

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
        end
        else begin
            if (tick) begin
                count <= count + 1;
            end
        end
    end
endmodule

module decoder_2x4 (
    input [1:0] x,
    output reg [3:0] y
);
    always @(*) begin
        case(x)
            2'b00: y = 4'b1110;
            2'b01: y = 4'b1101;
            2'b10: y = 4'b1011;
            2'b11: y = 4'b0111;
        endcase
    end
endmodule

module digitsplitter (
    input [13:0] fnddata,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);
    assign digit_1 = fnddata % 10;
    assign digit_10 = (fnddata / 10) % 10;
    assign digit_100 = (fnddata / 100) % 10;
    assign digit_1000 = (fnddata / 1000) % 10;
endmodule

module mux_4x1 (
    input [1:0] sel,
    input dot,
    input [3:0] x0,
    input [3:0] x1,
    input [3:0] x2,
    input [3:0] x3,
    output reg [3:0] y,
    output reg seg_dot
);
    always @(*) begin
        case (sel)
            2'b00: begin
                y = x0;
                seg_dot = 1;
            end 
            2'b01: begin
                y = x1;
                seg_dot = dot;
            end 
            2'b10: begin
                y = x2;
                seg_dot = 1;
            end 
            2'b11: begin
                y = x3;
                seg_dot = 1;
            end  
        endcase
    end
endmodule

module fnd (
    input [3:0] num,
    output [6:0] seg
);
    reg [7:0] r_seg;
    assign seg = r_seg;
    
    always @(*) begin
        case (num)
            4'd0: r_seg = 7'b100_0000;  
            4'd1: r_seg = 7'b111_1001;
            4'd2: r_seg = 7'b010_0100;
            4'd3: r_seg = 7'b011_0000;
            4'd4: r_seg = 7'b001_1001;
            4'd5: r_seg = 7'b001_0010;
            4'd6: r_seg = 7'b000_0010;
            4'd7: r_seg = 7'b101_1000;
            4'd8: r_seg = 7'b000_0000;
            4'd9: r_seg = 7'b001_0000;
            default: r_seg = 7'b111_1111; 
        endcase
    end
endmodule

module cnt_dot (
    input tick,
    input reset,
    output dot
);
    reg [2:0] cnt;

    reg r_dot;
    assign dot = r_dot;

    always @(posedge tick, posedge reset) begin
        if (reset) begin
            cnt <= 0;
            r_dot <= 0;
        end
        else begin
            if (cnt == 4) begin
                cnt <= 0;
                r_dot <= ~r_dot;
            end
            else begin
                cnt <= cnt + 1;
            end
        end
    end
endmodule