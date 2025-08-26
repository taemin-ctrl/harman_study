`timescale 1ns / 1ps

module tb_fifo();

    reg clk, reset;
    reg wr, rd;
    reg [7:0] wdata;
    wire [7:0] rdata;
    wire full, empty;
    
    fifo dut(
        .clk(clk),
        .reset(reset),
        .wr(wr),
        .rd(rd),
        .wdata(wdata),
        .rdata(rdata),
        .full(full),
        .empty(empty)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        wr = 0;
        rd = 0;
        wdata = 0;

        #10;
        reset = 0;
        
        #10;
        wr = 1;
        wdata = 8'haa;
        
        #10;
        wdata = 8'h55;

        #10;
        wr = 0;
        rd = 1;
        
        #10;
        #10;

        #10;
        $stop;
    end
endmodule
