`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/20 09:35:03
// Design Name: 
// Module Name: tb_fifo_2
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


module tb_fifo_2();

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

    integer i;
    reg rand_rd;
    reg rand_wr;
    reg [7:0] compare_data[2**4-1:0];
    integer write_count;
    integer read_count;

    initial begin
        clk = 0;
        reset = 1;
        wr = 0;
        rd = 0;
        wdata = 0;
        read_count = 0;
        write_count = 0;
        #10;

        reset = 0;
        #10;

        wr = 1;
        for (i = 0; i<17; i= i+1) begin
            wdata = i;
            #10;    
        end

        wr = 0;
        rd = 1;
        
        for (i = 0; i<17; i= i+1) begin
            #10;    
        end


        wr = 0;
        rd = 0;
        #10;

        wr = 1;
        rd = 1;
        for (i = 0; i<17; i= i+1) begin
            wdata = i*2 +1;
            #10;    
        end
        
        wr = 0;
        #10;
        rd = 0;
        #20;

        for (i = 0; i<50; i= i+1) begin
            @(negedge clk);
            rand_wr = $random %2;
            if (~full & rand_wr) begin
                wdata = $random % 256;
                compare_data[write_count % 16] = wdata;
                write_count = write_count + 1;
                wr = 1;
            end
            else begin
                wr = 0;
            end

            rand_rd = $random %2;
            if (~empty & rand_rd) begin
                #2;
                rd = 1;
                
                if (rdata == compare_data[read_count%16]) begin
                    $display("pass");
                end
                else begin
                    $display("fail: rdata=%h, compare_data=%h", rdata, compare_data[read_count]);
                end
                read_count = read_count + 1;
            end
            else begin
                rd = 0;
            end
        end
    end

endmodule
