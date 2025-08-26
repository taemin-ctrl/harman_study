`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/14 16:36:47
// Design Name: 
// Module Name: tb_uart_check
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


`timescale 1ns / 1ps

module tb_uart_check();

    // Testbench signals
    reg clk;
    reg rst;
    reg tick;
    reg start_trigger;
    reg [7:0] data_in;
    wire o_tx;
    wire o_tx_done;

    // Instantiate the uart_h and uart_tx modules
    uart_h u_h (
        .clk(clk),
        .rst(rst),
        .tick(tick),
        .start_trigger(start_trigger),
        .data_in(data_in),
        .o_tx(o_tx),
        .o_tx_done(o_tx_done)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // 100MHz clock period (10ns period)
    end

    // Test stimulus
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        tick = 0;
        start_trigger = 0;
        data_in = 8'b10101010;

        #10;
        
    end

    // Monitor the outputs (optional)
    initial begin
        $monitor("Time: %t, o_tx: %b, o_tx_done: %b", $time, o_tx, o_tx_done);
    end

endmodule

