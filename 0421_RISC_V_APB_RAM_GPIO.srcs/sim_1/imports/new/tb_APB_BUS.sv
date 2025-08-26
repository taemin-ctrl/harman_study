`timescale 1ns / 1ps

module tb_RV32I ();

    logic clk;
    logic reset;
    wire [7:0] GPOA;
    wire [7:0] GPIB;
    reg k;
    reg [7:0] GPIBK;

    MCU dut (.*);

    assign GPIB = k ? GPIBK : 8'bz;

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1;
        k = 0;
        GPIBK = 8'b0;
        #10 reset = 0;
        k = 0;
        GPIBK = 8'b0000_0010;
        #100;
        #100 $finish;
    end
endmodule