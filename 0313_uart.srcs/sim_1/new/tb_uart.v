`timescale 1ns / 1ps

module tb_uart();
    reg clk, rst;
    reg tx_start_tring;
    wire tx_dout;

    send_tx u_send_tx(
        .clk(clk),
        .rst(rst),
        .btn_start(tx_start_tring),
        .tx_data_in(0),
        .tx(tx_dout)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        rst = 1'b1;
        tx_start_tring = 1'b0;

        #20; rst = 1'b0;
        #20; tx_start_tring = 1'b1;
        #6000000; 
        tx_start_tring = 1'b0;
        #6000000; 
        tx_start_tring = 1'b1;
        #6000000; 
        tx_start_tring = 1'b0;
        #6000000; 
        tx_start_tring = 1'b1;

        #6000000; 
        tx_start_tring = 1'b0;
        #6000000; 
        tx_start_tring = 1'b1;


    end
endmodule
