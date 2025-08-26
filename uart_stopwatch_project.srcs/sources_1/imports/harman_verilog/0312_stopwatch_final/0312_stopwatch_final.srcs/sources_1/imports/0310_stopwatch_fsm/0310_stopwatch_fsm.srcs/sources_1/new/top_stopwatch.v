`timescale 1ns / 1ps

module top_stopwatch(
    input clk,
    input reset,
    input [1:0] sw_mode,
    input [3:0] btn,
    input [4:0] ctl,
    output [3:0] fnd_comm,
    output [7:0] fnd_font,
    output [3:0] led
    );

    wire w_run, w_clear;
    wire run, clear;
    wire w_clock;
    wire btn_c, btn_m, btn_s, btn_h_r;
    wire [6:0] msec,msec_stop, msec_clk; 
    wire [5:0] min,sec,sec_stop, min_stop, sec_clk, min_clk; 
    wire [4:0] hour,hour_stop, hour_clk;

    wire w_btn_c, w_btn_m, w_btn_s, w_btn_h, w_btn_r;
    wire ctl_c, ctl_r, ctl_h, ctl_m, ctl_s;

    assign w_btn_c = ctl[1] | btn_c;
    assign w_btn_r = ctl[0] | btn_h_r;
    assign w_btn_h = ctl[2] | btn_h_r;
    assign w_btn_m = ctl[3] | btn_m;
    assign w_btn_s = ctl[4] | btn_s;

    stopwatch_dp u_stopwatch_dp(
        .clk(clk),
        .reset(reset),
        .run(run),
        .clear(clear),
        .sw_mode(sw_mode[1]),
        .i_btn({w_btn_h,w_btn_m,w_btn_s}),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

    stopwatch_cu u_stopwatch_cu(
        .clk(clk),
        .reset(reset),
        .i_btn_run(w_btn_r),
        .i_btn_clear(w_btn_c),
        .o_run(run),
        .o_clear(clear)
    );

    fnd_controller u_fnd_controller(
        .clk(clk),
        .reset(reset),
        .sw_mode(sw_mode[0]),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );

    btn_debounce u_btn_db_up(
        .clk(clk),
        .reset(reset),
        .i_btn(btn[0]),
        .o_btn(btn_s)
    );

    btn_debounce u_btn_db_down(
        .clk(clk),
        .reset(reset),
        .i_btn(btn[1]),
        .o_btn(btn_m)
    );

    btn_debounce u_btn_db_left(
        .clk(clk),
        .reset(reset),
        .i_btn(btn[2]),
        .o_btn(btn_h_r)
    );

    btn_debounce u_btn_db_right(
        .clk(clk),
        .reset(reset),
        .i_btn(btn[3]),
        .o_btn(btn_c)
    );

    fnd_display u_dis(
        .sw_mode(sw_mode),
        .led(led)
    );

endmodule

module fnd_display (
    input [1:0]sw_mode,
    output [3:0] led
);
    assign led[1:0] = sw_mode[0] ? 2'b10: 2'b01;
    assign led[3:2] = sw_mode[1] ? 2'b10: 2'b01;
endmodule

