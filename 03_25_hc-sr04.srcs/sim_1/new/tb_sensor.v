`timescale 1ns / 1ps

module tb_sensor1 ();
    reg clk, rst;
    reg rx;
    reg echo;
    wire trigger;
    wire tx;
    wire [7:0] seg;
    wire [3:0] seg_comm;

    always #5 clk = ~clk;

    uart_sensor_top uut(
        .clk(clk),
        .reset(rst),
        .rx(rx),
        .tx(tx),
        .trigger(trigger),
        .echo(echo),
        .seg(seg),
        .seg_comm(seg_comm) 
    );
    
    localparam DELAY = 104170;
    localparam D = 104170*10;
    localparam DEL = 20_000_000;

    task send_data(input [7:0] data);
        integer i;
        begin

            rx = 0;
            # DELAY;

            for (i =0; i <8; i = i +1) begin
                rx =data[i];
                # DELAY;
            end

            rx = 1;
            # DELAY;
        end

    endtask

    initial begin
        clk = 0;
        rst = 1;
        echo = 0;
        rx = 1;
        #10

        rst = 0;
        send_data(8'h75);

    end
endmodule