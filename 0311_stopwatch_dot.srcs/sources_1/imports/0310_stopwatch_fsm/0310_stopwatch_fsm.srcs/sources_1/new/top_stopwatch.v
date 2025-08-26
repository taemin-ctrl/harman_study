`timescale 1ns / 1ps

module top_stopwatch(
    input clk,
    input reset,
    input sw_mode,
    input btn_run,
    input btn_clear,
    output [3:0] fnd_comm,
    output [7:0] fnd_font
    );

    wire w_run, w_clear;
    wire run, clear;
    wire [6:0] msec; 
    wire [5:0] sec, min; 
    wire [4:0] hour;

    stopwatch_dp u_stopwatch_dp(
        .clk(clk),
        .reset(reset),
        .run(run),
        .clear(clear),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

    stopwatch_cu u_stopwatch_cu(
        .clk(clk),
        .reset(reset),
        .i_btn_run(w_run),
        .i_btn_clear(w_clear),
        .o_run(run),
        .o_clear(clear)
    );

    fnd_controller u_fnd_controller(
        .clk(clk),
        .reset(reset),
        .sw_mode(sw_mode),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );

    btn_debounce u_btn_db_run(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_run),
        .o_btn(w_run)
    );

    btn_debounce u_btn_db_clear(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_clear),
        .o_btn(w_clear)
    );
endmodule
