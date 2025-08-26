`timescale 1ns / 1ps

module fnd_controller(
    input clk, reset,
    input [7:0] bcd,
    output [7:0] data,
    output [7:0] seg,
    output [3:0] seg_comm
    );

    wire w_clk;
    wire [3:0] w_digit1, w_digit10, w_digit100, w_digit1000;
    wire [3:0] w_bcd;
    wire [1:0] w_seg_sel;

    decoder decoder_uut(
        .seg_sel(w_seg_sel), .seg_comm(seg_comm)
    );
    
    bcdtoseg u_b2s(
        .bcd(w_bcd), .seg(seg)
    );

    digit_splitter uut(
        .bcd(bcd), .digit_1(w_digit1), .digit_10(w_digit10), .digit_100(w_digit100), .digit_1000(w_digit1000)
    );

    mux_4x1 mux_uut(
    .sel(w_seg_sel), .digit_1(w_digit1), .digit_10(w_digit10), .digit_100(w_digit100), .digit_1000(w_digit1000), .bcd(w_bcd)
    );
    
    counter_4 u_cnt_4(
        .clk(w_clk), .reset(reset), .o_sel(w_seg_sel)
    );

    clk_divider u_clk_div(
        .clk(clk), .reset(reset),  .o_clk(w_clk)
    );
    assign data = {w_digit10, w_digit1};
endmodule

module digit_splitter #(
    parameter n = 7
)(
    input [n:0] bcd,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);
    assign digit_1 = bcd %10;
    assign digit_10 = bcd /10 % 10;
    assign digit_100 = bcd / 100 %10;
    assign digit_1000 = bcd / 1000 % 10;
endmodule

module mux_4x1 (
    input [1:0] sel,
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    output reg [3:0] bcd
);

    always @(*) begin
        case (sel)
            2'b00: bcd = digit_1;
            2'b01: bcd = digit_10;
            2'b10: bcd = digit_100;
            2'b11: bcd = digit_1000;
            default: bcd = 4'bz;
        endcase
    end
endmodule

module decoder (
    input [1:0] seg_sel,
    output reg [3:0] seg_comm
);
    always @(*) begin
        case (seg_sel)
            2'b00: seg_comm = 4'b1110;
            2'b01: seg_comm = 4'b1101;
            2'b10: seg_comm = 4'b1011;
            2'b11: seg_comm = 4'b0111;
            default: seg_comm = 4'b1110;
        endcase
    end
    
endmodule

module bcdtoseg (
    input [3:0] bcd,
    output reg [7:0] seg
);
    always @(bcd) begin
        case (bcd)
            4'h0: seg =  8'hc0;
            4'h1: seg =  8'hf9;
            4'h2: seg =  8'ha4;
            4'h3: seg =  8'hb0;
            4'h4: seg =  8'h99;
            4'h5: seg =  8'h92;
            4'h6: seg =  8'h82;
            4'h7: seg =  8'hf8;
            4'h8: seg =  8'h80;
            4'h9: seg =  8'h90;
            4'ha: seg =  8'h88;
            4'hb: seg =  8'h83;
            4'hc: seg =  8'hc6;    
            4'hd: seg =  8'ha1;
            4'he: seg =  8'h86;
            4'hf: seg =  8'h8e;
            default: seg = 8'h0;
        endcase
    end
endmodule

module counter_4 (
    input clk,
    input reset,
    output [1:0] o_sel
);
    reg [1:0] r_cnt;
    
    assign o_sel = r_cnt;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_cnt <= 0;
        end

        else begin
            r_cnt <= r_cnt + 1'b1;
        end
    end
endmodule

module clk_divider (
    input clk,
    input reset,
    output o_clk
);
    reg [$clog2(50_000):0] r_counter;
    reg r_clk;
    assign o_clk = r_clk;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_clk <= 0;
        end
        else begin
            if (r_counter == 50_000 - 1) begin
                r_counter <= 0;
                r_clk <= 1'b1; 
            end
            else begin
                r_counter <= r_counter + 1'b1;
                r_clk <= 1'b0;
            end
        end
    end
endmodule

module counter_9999 #(
    parameter n = $clog2(9999) - 1
)(
    input clk,
    input reset,
    input clear, 
    output [n:0] o_cnt
);
    reg [n:0] cnt;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            cnt <= 0;
        end
        else if (clear) begin
            cnt <= 0;
        end
        else if (cnt == 9999) begin
            cnt <= 0;
        end
        else begin
            cnt <= cnt + 1'b1;
        end
    end

    assign o_cnt = cnt;
endmodule

module clk_div_100hz(
    input clk,
    input reset,
    input run_stop,
    output o_tick
);
    reg [$clog2(1_000_000)-1 : 0] r_counter;
    reg r_clk_10hz;

    assign o_clk_10hz = r_clk_10hz;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end
        else if (run_stop) begin
            r_counter <= r_counter;
        end
        else begin
            if (r_counter == 1_000_000 - 1) begin
                r_counter <= 0;
                r_clk_10hz <= 1'b1;
            end
            else if (r_counter == 1_000_000/2 - 1) begin // duty radio 50%
                r_counter <= r_counter + 1'b1; 
                r_clk_10hz <= 1'b0;
            end
            else begin
                r_counter <= r_counter + 1'b1;
                r_clk_10hz <= 1'b1;
            end
        end
    end
endmodule

module control_unit (
    input clk,
    input reset,
    input i_run_stop,
    input i_clear,
    output reg o_run_stop,
    output reg o_clear
);
    parameter STOP = 3'b000, RUN = 3'b001, CLEAR = 3'b010;

    // state management
    reg [2:0] state, next;

    // state sequencial logic
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STOP;
        end
        else begin
            state <= next;
        end
    end

    // next combinational logic
    always @(*) begin
        next = state;
        case (state)
            STOP: begin
                if (i_run_stop) begin
                    next = RUN;
                end
                else if (i_clear) begin
                    next = CLEAR;
                end
                else begin
                    next = STOP;
                end
            end
            RUN: begin
                if (!i_run_stop) begin
                    next = STOP;
                end
                else begin
                    next = RUN;
                end
            end
            CLEAR: begin
                if (!i_clear) begin
                    next = STOP;
                end
                else begin
                    next = CLEAR;
                end
            end
            default: begin
                next = state;
            end 
        endcase
    end

    //combinational output logic
    always @(*) begin
        case (state)
            STOP: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end
            RUN: begin
                o_run_stop = 1'b1;
                o_clear = 1'b0;
            end
            CLEAR:begin
                o_run_stop = 1'b0;
                o_clear = 1'b1;
            end
            default: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
            end 
        endcase
    end
endmodule

