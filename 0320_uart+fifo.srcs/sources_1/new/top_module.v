`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/20 11:40:17
// Design Name: 
// Module Name: top_module
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


module top_module(
    input clk,
    input reset,
    input rx,
    output tx
    );

    reg [7:0] pipeline;

    wire [7:0] w_rx_data;
    wire [7:0] w_tx_data_1;
    wire [7:0] w_tx_data_2;
    wire [7:0] w_data;
    wire rx_done2wr;
    wire empty2wr;
    wire full2rd;
    wire empty2start;
    wire done2rd;

    //assign w_tx_data_2 = pipeline;
    assign w_tx_data_2 = w_tx_data_1;

    fifo tx_fifo(
        .clk(clk),
        .reset(reset),
        .wr(!empty2wr),
        .rd(!done2rd),
        .wdata(w_data),
        .rdata(w_tx_data_1),
        .full(full2rd),
        .empty(empty2start)
    );

    fifo rx_fifo(
        .clk(clk),
        .reset(reset),
        .wr(rx_done2wr),
        .rd(!full2rd),
        .wdata(w_rx_data),
        .rdata(w_data),
        //.full(),
        .empty(empty2wr)
    );

    uart u_uart(
        .clk(clk),
        .rst(reset),
    // tx
        .btn_start(!empty2start),
        .data_in(w_tx_data_2),
        .tx(tx),
        .tx_done(done2rd),
    // rx
        .rx(rx),
        .rx_done(rx_done2wr),
        .rx_data(w_rx_data)
    );

    /*always @(posedge clk, posedge reset) begin
        if (reset) begin
            pipeline <= 0;
        end
        else begin
            if (w_tx_data_1) pipeline <= w_tx_data_1;
            else pipeline <= pipeline;
        end
    end*/
endmodule
