`timescale 1ms / 1ns

module tb_stopwatch();
    reg clk, reset;
    reg sw_mode;
    reg btn_run, btn_clear;
    wire [3:0] fnd_comm;
    wire [7:0] fnd_font;

    top_stopwatch dut(
        .clk(clk),
        .reset(reset),
        .sw_mode(sw_mode),
        .btn_run(btn_run),
        .btn_clear(btn_clear),
        .fnd_comm(fnd_comm),
        .fnd_font(fnd_font)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1; 
        sw_mode = 0;
        btn_run = 0; 
        btn_clear = 0;
        
        #10;
        reset = 0;
        btn_run = 1;
        
        #1000;
        $stop;
    end
endmodule
