module tb_blk();
    reg clk, a, b;

    initial begin
        a = 0;
        b = 1;
        clk = 0;
    end

    always @(posedge clk) begin
        a = b;
        b = a;
    end
endmodule

module non_blk ();
    reg clk, a, b;
    initial begin
        a = 0;
        b = 1;
        clk = 0;
    end

    always @(posedge clk) begin
        a <= b;
        b <= a;
    end
endmodule