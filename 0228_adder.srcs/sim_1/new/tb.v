`timescale 1ns / 1ps


module tb_adder();
    reg  [3:0] a, b;
    wire [3:0] s;
    wire c;

    adder dut(
        .a(a), .b(b), .s(s), .c(c)
    );

    integer i,j;

    initial begin
        a =4'h0; b =4'h0;
        #10;
        for (i = 0; i<16; i = i + 1) begin
            for (i = 0; i<16; i = i + 1) begin
                a = i;
                #10;
        end
        end
        $finish();
    end
endmodule
