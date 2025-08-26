`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/02 14:50:10
// Design Name: 
// Module Name: tb
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


module tb();
    reg clk, reset;

    wire w_tick;
    
    reg sw_mode;
    reg sw_clear;
    reg sw_run_stop;

    wire mode;
    wire clear;
    wire en;

    wire [13:0] count;
    wire [3:0] dot_data;

    localparam DELAY = 10_000_000*10;

    control_unit dut(
        .clk(clk),
        .reset(reset),
        .sw_mode(sw_mode),
        .sw_run_stop(sw_run_stop),
        .sw_clear(sw_clear),
        .mode(mode), 
        .clear(clear),
        .en(en)
);

counter_up_down uut(
        .clk(clk),
        .reset(reset),
        .clear(clear),
        .en(en),
        .mode(mode),
        .count(count),
        .dot_data(dot_data)
);


    always  #5 clk = ~clk;
    
    initial begin
        clk = 0;
        reset = 1;
        sw_mode = 0;
        sw_clear = 0;
        sw_run_stop = 0; 
        #10;
        reset = 0;
        sw_run_stop = 1;
        # DELAY;
        sw_mode = 1;
        # DELAY;
        sw_run_stop = 0;
        #DELAY;
        
    end
endmodule
