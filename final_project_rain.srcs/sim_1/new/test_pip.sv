`timescale 1ns / 1ps

module tb_total_background();

    logic clk;
    logic rst;
    logic [7:0] pixel;
    logic out_pixel;

    total_background dut (
        .clk(clk),
        .rst(rst),
        .pixel(pixel),
        .out_pixel(out_pixel)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst = 1;
        pixel = 0;
        #20;
        rst = 0;

        // 배경으로 추정되는 값(예: 50 ~ 60) 20클럭 입력
        repeat (20) begin
            @(posedge clk);
            pixel <= 8'd55;
        end

        // 전경으로 추정되는 값(예: 200 ~ 220) 10클럭 입력
        repeat (10) begin
            @(posedge clk);
            pixel <= 8'd210;
        end

        // 다시 배경으로 추정되는 값 20클럭 입력
        repeat (20) begin
            @(posedge clk);
            pixel <= 8'd58;
        end

        #50;
        $finish;
    end

    initial begin
        $display("Time\tclk\trst\tpixel\tout_pixel\tbackground/foreground");
        forever @(posedge clk) begin
            $write("%0t\t%b\t%b\t%3d\t%b\t\t", $time, clk, rst, pixel, out_pixel);
            if (out_pixel == 0)
                $display("Background");
            else
                $display("Foreground");
        end
    end

endmodule
