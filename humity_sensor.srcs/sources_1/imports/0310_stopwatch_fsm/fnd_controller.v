`timescale 1ns / 1ps

module fnd_controller (
    input clk,
    input reset,
    input sw_mode,
    input [6:0] msec,
    input [5:0] sec,
    input [5:0] min,
    input [4:0] hour,
    output [7:0] fnd_font,
    output [3:0] fnd_comm
);

    wire [3:0] w_bcd, w_digit_msec_1, w_digit_msec_10,
                    w_digit_sec_1, w_digit_sec_10,
                    w_digit_min_1, w_digit_min_10,
                    w_digit_hour_1, w_digit_hour_10, w_dot;


    wire [2:0] w_seg_sel;
    wire w_clk_100hz;
    wire w_clk_5s;
    wire [3:0] w_msec_sec, w_min_hour;

    clk_divider U_Clk_Divider (
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_100hz)
    );

    counter_8 U_Counter_8 (
        .clk  (w_clk_100hz),
        .reset(reset),
        .o_sel(w_seg_sel)
    );


    decoder_3x8 U_decoder_3x8 (
        .seg_sel (w_seg_sel),
        .seg_comm(fnd_comm)
    );


    digit_splitter #(.BIT_WIDTH(7)) U_back_ds(
        .bcd(msec),
        .digit_1(w_digit_msec_1),
        .digit_10(w_digit_msec_10)
    );

    digit_splitter #(.BIT_WIDTH(6)) U_front_ds(
        .bcd(sec),
        .digit_1(w_digit_sec_1),
        .digit_10(w_digit_sec_10)
    );

    mux_8x1 u_mux_8x1_msec_sec(
        .sel(w_seg_sel),
        .x0(w_digit_msec_1),
        .x1(w_digit_msec_10),
        .x2(w_digit_sec_1),
        .x3(w_digit_sec_10),
        .x4(4'hf),
        .x5(4'hf),
        .x6(w_dot),
        .x7(4'hf),
        .y(w_msec_sec)
    );

    mux_8x1 u_mux_8x1_min_hour(
        .sel(w_seg_sel),
        .x0(w_digit_min_1),
        .x1(w_digit_min_10),
        .x2(w_digit_hour_1),
        .x3(w_digit_hour_10),
        .x4(4'hf),
        .x5(4'hf),
        .x6(w_dot),
        .x7(4'hf),
        .y(w_min_hour)
    );


    bcdtoseg U_bcdtoseg (
        .bcd(w_bcd),  // [3:0] sum 값 
        .seg(fnd_font)
    );

endmodule

module clk_divider #(
    parameter FCOUNT = 100_000// 이름을 상수화하여 사용.
)(
    input  clk,
    input  reset,
    output o_clk
);
    
    // $clog2 : 수를 나타내는데 필요한 비트수 계산
    reg [$clog2(FCOUNT)-1:0] r_counter;
    reg r_clk;
    assign o_clk = r_clk;

    always @(posedge clk, posedge reset) begin
        if (reset) begin  // 
            r_counter <= 0;  // 리셋상태
            r_clk <= 1'b0;
        end else begin
            // clock divide 계산, 100Mhz -> 200hz
            if (r_counter == FCOUNT - 1) begin
                r_counter <= 0;
                r_clk <= 1'b1;  // r_clk : 0->1
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;  // r_clk : 0으로 유지.;
            end
        end
    end

endmodule

module counter_8 (
    input        clk,
    input        reset,
    output [2:0] o_sel
);

    reg [2:0] r_counter;
    assign o_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end


endmodule

module decoder_3x8 (
    input [2:0] seg_sel,
    output reg [3:0] seg_comm
);

    // 3x8 decoder
    always @(seg_sel) begin
        case (seg_sel)
            3'b000:   seg_comm = 4'b1110;
            3'b001:   seg_comm = 4'b1101;
            3'b010:   seg_comm = 4'b1011;
            3'b011:   seg_comm = 4'b0111;
            3'b100:   seg_comm = 4'b1110;
            3'b101:   seg_comm = 4'b1101;
            3'b110:   seg_comm = 4'b1011;
            3'b111:   seg_comm = 4'b0111;
            default: seg_comm = 4'b1111;
        endcase
    end

endmodule

module digit_splitter #(parameter BIT_WIDTH =7) (
    input  [BIT_WIDTH-1:0] bcd,
    output [3:0] digit_1,
    output [3:0] digit_10
);
    assign digit_1 = bcd % 10;  // 10의 1의 자리
    assign digit_10 = (bcd / 10) % 10;  // 10의 10의 자리
endmodule

module mux_2x1 (
    input sw_mode,
    input [3:0] msec_sec,
    input [3:0] min_hour,
    output reg [3:0] bcd
);
    // assign bcd = sw_mode ? min_hour : msec_sec;

    always @(*) begin
        case(sw_mode)
            1'b0: bcd = msec_sec;
            1'b1: bcd = min_hour;
            default: bcd = 4'hf;
        endcase
    end
endmodule

module mux_8x1 (
    input [2:0] sel,
    input [3:0] x0,
    input [3:0] x1,
    input [3:0] x2,
    input [3:0] x3,
    input [3:0] x4,
    input [3:0] x5,
    input [3:0] x6,
    input [3:0] x7,
    output reg [3:0] y
);
    always @(*) begin
        case(sel)
            3'b000: y = x0;
            3'b001: y = x1;
            3'b010: y = x2;
            3'b011: y = x3;
            3'b100: y = x4;
            3'b101: y = x5;
            3'b110: y = x6;
            3'b111: y = x7;
            default: y = 4'hf;
        endcase
    end
    
endmodule

module bcdtoseg (
    input [3:0] bcd,  // [3:0] sum 값 
    output reg [7:0] seg
);
    // always 구문 출력으로 reg type을 가져야 한다.
    always @(bcd) begin

        case (bcd)
            4'h0: seg = 8'hc0;
            4'h1: seg = 8'hF9;
            4'h2: seg = 8'hA4;
            4'h3: seg = 8'hB0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hf8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            4'hA: seg = 8'h88;
            4'hB: seg = 8'h83;
            4'hC: seg = 8'hc6;
            4'hD: seg = 8'ha1;
            4'hE: seg = 8'h7f; // dot display
            4'hF: seg = 8'hff;
            default: seg = 8'hff;
        endcase
    end
endmodule




