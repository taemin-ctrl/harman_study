`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/20 11:54:41
// Design Name: 
// Module Name: tb_fifo_uart
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


module tb_fifo_uart();
    reg clk, reset, rx;
    wire tx;

    top_module uut(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tx(tx)
    );

    always #5 clk = ~clk;

    localparam DELAY = 104170;

    task send_data(input [7:0] data);
        integer i;
        begin
            $display("sending data: %h", data);

            rx = 0;
            # DELAY;

            for (i =0; i <8; i = i +1) begin
                rx =data[i];
                # DELAY;
            end

            rx = 1;
            # DELAY;
            $display("data sent: %h", data);
        end

    endtask
    initial begin
        clk = 0;
        reset = 1;
        rx = 1;
        #10;

        reset = 0;
        send_data(8'h33);
        # DELAY;
        # DELAY;
        send_data(8'h11);
        /*# DELAY;
        rx = 0; // start
        # DELAY;
        rx = 1; // data 0
        # DELAY;
        rx = 0; // data 1
        # DELAY;
        rx = 1; // data 2
        # DELAY;
        rx = 0; // data 3
        # DELAY;
        rx = 1; // data 4
        # DELAY;
        rx = 0; // data 5
        # DELAY;
        rx = 1; // data 6
        # DELAY;
        rx = 0; // data 7
        # DELAY;
        rx = 1; // stop
        # DELAY;*/
        
    end
endmodule
