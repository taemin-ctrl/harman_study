`timescale 1ns / 1ps
/*
module tb_sensor();
    reg clk, rst;
    reg btn_start;
    wire [6:0] led;
    
    reg en;
    wire dht_io;
    reg dht;
    
    wire [39:0] data;

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

    task sensor(input [39:0] data);
        integer i;
        begin
            for (i = 0; i<40;i=i+1) begin
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
        sensor(40'hfffffffff);
        
        //IDLE
        en = 0; 
        #5_000;
        $stop;
    end
endmodule*/

module tb ();
    reg clk, rst;
    reg [39:0] data;
    wire en;
    wire [7:0] split_data;
    
    conti_data uut(
        .clk(clk),
        .rst(rst),
        .data(data),
        .en(en),
        .split_data(split_data)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #10;
        rst = 0;
        #10;
        data = 40'h1234_5678_9a;
        #100;
        $stop;
    end
endmodule





