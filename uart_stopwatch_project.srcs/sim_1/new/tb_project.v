`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/21 11:48:43
// Design Name: 
// Module Name: tb_project
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


module tb_project();

    reg clk, reset;
    reg [1:0] sw_mode;
    reg [3:0] btn;
    wire [3:0] fnd_comm;
    wire [7:0] fnd_font;
    wire [3:0] led;
    reg rx;
    wire tx;

    uart_stopwatch_top uut(
        .clk(clk),
        .reset(reset),
        .sw_mode(sw_mode),
        .btn(btn),
        .fnd_comm(fnd_comm),
        .fnd_font(fnd_font),
        .led(led),
        .rx(rx),
        .tx(tx)
    );

    always #5 clk = ~clk;

    localparam DELAY = 104170;
    localparam D = 104170*10;
    localparam DEL = 20_000_000;

    localparam RUN = 8'h72;
    localparam CLEAR = 8'h63;
    localparam HOUR = 8'h68;
    localparam MIN = 8'h6d;
    localparam SEC = 8'h73;

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
    
    integer i;

    initial begin
        clk = 0;
        reset = 1;
        rx = 1;
        btn = 0;
        sw_mode = 2'b01;
        #10;

        reset = 0;
        #100;

        i = 0;
        send_data(RUN);
        # DEL;

        i = 1;
        send_data(RUN);
        # D;

        i = 2;
        send_data(CLEAR);
        # D;
        
        # DELAY;
        # DELAY;
        $stop;
    end
    /*initial begin
        clk = 0;
        reset = 1;
        rx = 1;
        btn = 0;
        sw_mode = 2'b10;
        #10;

        reset = 0;
        #100;

        i = 0;
        send_data(HOUR);
        # D;

        i = 1;
        send_data(MIN);
        # D;

        i = 2;
        send_data(SEC);
        # D;
        
        # DELAY;
        # DELAY;
        $stop;
    end*/

endmodule
