`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2025 10:09:44 PM
// Design Name: 
// Module Name: tb
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

`timescale 1ns / 1ps

module final_tb ();
    reg clk, rst;
    reg rx;
    wire tx;
    
    reg btn_start;
    
    wire [7:0] seg;
    wire [3:0] seg_comm;
    
    reg en;
    wire dht_io;
    reg dht;
    wire check;
    // 3 state buffer
    assign dht_io = en ? dht : 1'bz;
    
    // instance
    top_sensor uut(
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .tx(tx),
    .dht_io(dht_io),
    .btn_start(btn_start),
    .seg(seg),
    .seg_comm(seg_comm),
    .check(check)
    );
    
    // delay
    localparam DELAY     = 104170;
    localparam DEL_START = (10 * 18_000 * 100);
    localparam DEL_WAIT  = (10 * 30_000);
    localparam DEL_SYNC  = (80_000 * 10);
    localparam DEL_DATAs = (50_000*10);
    localparam DEL_1     = (70_000);
    localparam DEL_0     = (27_000);
    
    localparam RUN = 8'h72;
    
    task send_data(input [7:0] data);
        integer i;
        begin
            rx = 0;
            # DELAY;
            
            for (i = 0; i <8; i = i +1) begin
                rx = data[i];
                # DELAY;
            end
            
            rx = 1;
            # DELAY;
        end
        
    endtask
    
    task sensor(input [39:0] data);
        integer i;
        begin
            for (i = 0; i<40;i = i+1) begin
                dht = 1;
                if (data[39-i]) begin
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
        clk = 0;
        rst = 1;
        rx  = 1;
        btn_start = 0;
        
        #10;
        rst = 0;
        
        send_data(RUN);
        # DEL_START;
        
        // WAIT
        #DEL_WAIT;
        
        // SYNC_LOW
        dht = 0;
        en  = 1;
        #DEL_SYNC;
        
        // SYNC_HIGH
        dht = 1;
        #DEL_SYNC;
        
        // DATA_SYNC
        dht = 0;
        # DEL_DATAs
        sensor(40'hafffffffff);
        
        //IDLE
        en = 0;
        #1000;

        #DELAY;
        #DELAY;
        #DELAY;
        #DELAY;
        #DELAY;
        #DELAY;
        #DELAY;
        #DELAY;
        #DELAY;
        #DELAY;
        #DELAY;

        btn_start = 1;
        $stop;
    end
endmodule

