`timescale 1ns / 1ps

module tb_sys;

    logic        clk;
    logic        reset;
    logic        cpol;
    logic        cpha;
    logic        start;
    logic   [7:0] tx_data;
    logic [7:0] rx_data;
    logic   done;
    logic   ready;
    logic   SCLK;
    logic       MOSI;
    logic        MISO;
    logic       SS;

    SPI_Master dut(.*);
    SPI_Slave slave_dut(.*);

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        #10 reset = 0;


        repeat (5) @(posedge clk);

        // address
        @(posedge clk);
        tx_data = 8'b10000001; start = 1; cpol = 0; cpha = 0;
        @(posedge clk);
        start = 0;
        wait (done == 1);
        @(posedge clk);

        

        // write data
        @(posedge clk);
        tx_data = 8'h11; start = 1; cpol = 0; cpha = 0;
        @(posedge clk);
        start = 0;
        wait (done == 1);
        @(posedge clk);

        //#1000_00;
/*
        // write address
        @(posedge clk);
        tx_data = 8'b10000001; start = 1; cpol = 0; cpha = 0;
        @(posedge clk);
        start = 0;
        wait (done == 1);
        @(posedge clk);

        //#1000_00;

        // write data
        @(posedge clk);
        tx_data = 8'h33; start = 1; cpol = 0; cpha = 0;
        @(posedge clk);
        start = 0;
        wait (done == 1);
        @(posedge clk);
*/
        //#1000_00;

        // read address
        @(posedge clk);
        tx_data = 8'b00000001; start = 1; cpol = 0; cpha = 0;
        @(posedge clk);
        start = 0;
        wait (done == 1);
        @(posedge clk);

        //#1000_00;


        //repeat (5) @(posedge clk);

        // read data
        @(posedge clk);
        tx_data = 8'hff; start = 1; cpol = 0; cpha = 0;
        @(posedge clk);
        start = 0;
        wait (done == 1);

        //#1000_00;

        // read address
/*        @(posedge clk);
        tx_data = 8'b00000001; start = 1; cpol = 0; cpha = 0;
        @(posedge clk);
        start = 0;
        wait (done == 1);
        @(posedge clk);

        //#1000_00;


        repeat (5) @(posedge clk);

        // read data
        @(posedge clk);
        tx_data = 8'hff; start = 1; cpol = 0; cpha = 0;
        @(posedge clk);
        start = 0;
        wait (done == 1);
*/
        //#1000_00;
/*
        for(int i=0;i<4;i++)begin
            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;
            wait (done == 1);
            @(posedge clk);
        end
*/

        #2000 $finish;

    end

endmodule
