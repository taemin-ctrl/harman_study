`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/21 10:25:57
// Design Name: 
// Module Name: uart_stopwatch_top
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


module uart_stopwatch_top(
    input clk,
    input reset,
    input [1:0] sw_mode,
    input [3:0] btn,
    output [3:0] fnd_comm,
    output [7:0] fnd_font,
    output [3:0] led,
    input rx,
    output tx
    );

    wire [7:0] data;
    wire [4:0] ctl, w_ctl;
    wire tig;

    top_stopwatch u_top_stopwatch(
        .clk(clk),
        .reset(reset),
        .sw_mode(sw_mode),
        .btn(btn),
        .ctl(w_ctl),
        .fnd_comm(fnd_comm),
        .fnd_font(fnd_font),
        .led(led)
    );

    top_module u_uart(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data(data),
        .tx(tx),
        .empty(w_tig)
    );
    
    uart_cu u_uart_cu(
        .i_data(data),
        .o_data(ctl)
    );
    
    trigger u_tig(
        .empty(w_tig),
        .data(ctl),
        .tig(w_ctl)
);
endmodule

module trigger (
    input empty,
    input [4:0] data,
    output [4:0] tig
);
    assign tig = empty? 0: data;
endmodule