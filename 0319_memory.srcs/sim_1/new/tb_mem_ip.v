`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/19 11:54:47
// Design Name: 
// Module Name: tb_mem_ip
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


module tb_mem_ip();
    
    parameter ADDR_WIDTH = 4, DATA_WIDTH = 8;

    reg clk;
    reg [ADDR_WIDTH-1:0] waddr;
    reg [DATA_WIDTH-1:0] wdata;
    reg wr;
    wire [DATA_WIDTH-1:0] rdata; 

    ram_ip dut(
        .clk(clk),
        .waddr(waddr),
        .wdata(wdata),
        .wr(wr),
        .rdata(rdata)
    );

    always #5 clk = ~clk;

    integer i;
    
    reg [DATA_WIDTH-1:0] rand_data;
    reg [ADDR_WIDTH-1:0] rand_addr;
    
    initial begin
        clk = 0;
        waddr = 0;
        wdata = 0;
        wr = 0;
        #10;

        for (i=0; i<50; i = i+1) begin
            @(posedge clk);
            // random generator
            rand_addr = $random % 16; // 난수 16
            rand_data = $random % 256;
            // write
            wr = 1;
            waddr = rand_addr;
            wdata = rand_data;
            
            //@(posedge clk);
            // read
            #10;
            wr = 0;
            waddr = rand_addr;
            #10;
            // == (0,1 compare), ===  (0,1,x,z compare)
            if (rdata === wdata) begin
                $display("pass");
            end
            else begin
                $display("fail addr = %d, data = %h",waddr,rdata);
            end
        end

        #100;
        $stop;
    end
endmodule
