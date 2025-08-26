`timescale 1ms / 1ns

module tb_stopwatch();
    reg clk, reset;
    reg sw_mode;
    reg run, clear;
    wire [6:0] msec;
    wire [5:0] sec, min; 
    wire [4:0] hour;
    wire [3:0] fnd_comm;
    wire [7:0] fnd_font;

    stopwatch_dp dut(
        .clk(clk),
        .reset(reset),
        .run(run),
        .clear(clear),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

    fnd_controller dut1(
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
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1; 
        sw_mode = 0;
        run = 0; 
        clear = 0;
        
        #10;
        run = 1;
        reset = 0;
        
        #1000;
        $stop;
    end
endmodule
