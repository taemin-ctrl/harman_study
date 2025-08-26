`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/27 16:10:39
// Design Name: 
// Module Name: tb_1
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


module tb_sensor1();
    reg clk, rst;
    reg btn_start;
    wire [7:0] led;
    
    reg en;
    wire dht_io;
    reg dht;
    
    wire [39:0] data;
    wire wen;
    wire [7:0] odata;

    // delay
    localparam DEL_START = 10 * 18_000 * 100;
    localparam DEL_WAIT = 10 * 30_000;
    localparam DEL_SYNC = 80_000 * 10;
    localparam DEL_DATAs = 50_000*10;
    localparam DEL_1 = 70_000*10;
    localparam DEL_0 = 27_000*10;
    
    // 3 state buffer
    assign dht_io = en ? dht : 1'bz; 

    humity_sensor_top uut(
        .clk(clk),
        .rst(rst),
    
        .btn_start(btn_start),
        .led(led),
    
        .dht_io(dht_io),
        .data(data)
    );

    conti_data u_send(
        .clk(clk),
        .rst(rst),
        .data(data),
        .en(wen),
        .split_data(odata)
    );

    task sensor(input [39:0] data);
        integer i;
        integer k;
        begin
            k = data;
            for (i = 0; i<40;i=i+1) begin
                dht = 1;
                if (data[39-i] == 1'b1) begin
                    # DEL_1;
                end
                else begin
                    # DEL_0;
                end
                dht = 0;
                # DEL_DATAs;
            end
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        // IDLE
        clk = 0;
        rst = 1;
        en = 0;
        dht = 1;
        btn_start = 0;
        #10;
        
        // START
        rst = 0;
        btn_start = 1;
        # DEL_START;

        // WAIT
        btn_start = 0;
        #DEL_WAIT;

        // SYNC_LOW
        dht = 0;
        en = 1;
        #DEL_SYNC;

        // SYNC_HIGH
        dht = 1;
        #DEL_SYNC;

        // DATA_SYNC
        dht = 0;
        # DEL_DATAs
        sensor(40'h123456789a);
        
        //IDLE
        en = 0; 
        #50_000;
        $stop;
    end
endmodule
