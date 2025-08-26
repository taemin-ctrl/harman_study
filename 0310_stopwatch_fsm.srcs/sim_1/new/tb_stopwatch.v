`timescale 1ns / 1ps

module tb_stopwatch();
    reg clk, reset;
    reg run, clear;
    wire [6:0] msec, sec, min, hour;

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

    always #5 clk = ~clk;

    initial begin
        clk = 0; 
        reset = 1; 
        run = 0; 
        clear = 0;
        
        #10;
        reset = 0;
        run = 1;
        wait (sec == 2);
        
        #10;
        run = 0;
    end
endmodule
