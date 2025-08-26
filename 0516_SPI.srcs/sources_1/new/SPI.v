`timescale 1ns / 1ps

module SPI(
    input clk,
    input rst,
    input btn,
    input [15:0] sw,
    output [7:0] seg,
    output [3:0] seg_comm
    );

    wire start, done, ready;
    wire [7:0] data, rx_data;
    
    wire SCLK, CS, MOSI, MISO;

    wire [13:0] num;

    Interface intf(
        .clk(clk),
        .rst(rst),
        .btn(btn),
        .done(done),
        .sw(sw),
        .start(start),
        .data(data)
    );

    SPI_Master u_spi_m(
        .clk(clk),
        .rst(rst),
        .start(start),
        .tx_data(data),
        .rx_data(rx_data),
        .done(done),
        .ready(ready),
        .CS(CS),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO)
    );

    SPI_Slave u_spi_s(
        .clk(clk),
        .rst(rst),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .CS(CS),
        .MISO(MISO),
        .num(num)
    );

    fnd_controller u_fnd(
        .clk(clk),
        .reset(rst),
        .bcd(num),
        .seg(seg),
        .seg_comm(seg_comm)
    );
endmodule
    
module Interface (
    input clk,
    input rst,
    input btn,
    input done,
    input [15:0] sw,
    output reg start,
    output [7:0] data
);
    localparam IDLE = 0, LOW = 1, HIGH = 2;
    reg [1:0] state, next;

    assign data = (state == IDLE) ? 8'b0 : (state == LOW) ? sw[7:0]: sw[15:8];
    
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= IDLE;        
        end
        else begin
            state <= next;
        end
    end

    always @(*) begin
        next = state;
        start = 0;
        case (state)
            IDLE: begin
                start = 0;
                if (btn) begin
                    next = LOW;
 
                end
            end 
            LOW: begin
                start = 1;
                if (done) begin
                    next = HIGH;
                end
            end
            HIGH: begin
                start = 1;
                if (done) begin
                    next = IDLE;
                end
            end 
        endcase
    end
endmodule

module SPI_Master (
    input clk,
    input rst,
    input start,
    input [7:0] tx_data,
    output reg [7:0] rx_data,
    output reg done,
    output ready,
    output reg CS,
    output reg SCLK,
    output MOSI,
    input MISO
);
    localparam IDLE = 0, CP0 = 1, CP1 = 2;
    reg [1:0] state, next;

    reg [5:0] cnt_reg, cnt_next;
    reg [7:0] temp_tx_data_reg, temp_tx_data_next;
    reg [3:0] bit_cnt_reg, bit_cnt_next; 
    reg data_reg, data_next;
    //assign MOSI = temp_tx_data_reg[bit_cnt_reg];
    assign MOSI = data_reg;
    assign ready = ~done;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= IDLE;
            cnt_reg <= 0;
            temp_tx_data_reg <= 0;
            bit_cnt_reg <= 7;
            data_reg <= 0;
        end
        else begin
            state <= next;
            cnt_reg <= cnt_next;
            temp_tx_data_reg <= temp_tx_data_next;
            bit_cnt_reg <= bit_cnt_next;
            data_reg <= data_next;
        end
    end

    always @(*) begin
        temp_tx_data_next = temp_tx_data_reg;
        cnt_next = cnt_reg;
        next = state;
        bit_cnt_next = bit_cnt_reg;
        SCLK = 0;
        CS = 1;
        done = 0;
        data_next = data_reg;
        case (state)
            IDLE: begin
                if (start) begin
                    next = CP0;
                    temp_tx_data_next = tx_data;
                    CS = 0;
                end
                else begin
                    temp_tx_data_next = 8'bz;
                    done = 0;
                    CS = 1;
                end
            end
            CP0: begin
                CS = 0;
                SCLK = 0;
                if (bit_cnt_reg <8) begin
                    data_next = temp_tx_data_reg[bit_cnt_reg];
                end
                if (cnt_reg == 49) begin
                    next = CP1;
                    cnt_next = 0;
                end    
                else begin
                    cnt_next = cnt_reg + 1;
                end
            end
            CP1: begin
                CS = 0;
                SCLK = 1;
                
                if (bit_cnt_reg == 8) begin
                    SCLK = 0;
                    next = IDLE;
                    done = 1;
                    bit_cnt_next = 0;
                end
                else begin
                    if (cnt_reg == 49) begin
                        next = CP0;
                        cnt_next = 0;
                        bit_cnt_next = bit_cnt_reg - 1;
                    end    
                    else begin
                        cnt_next = cnt_reg + 1;
                    end
                end
            end

        endcase
    end
endmodule

module SPI_Slave (
    input clk,
    input rst,
    input SCLK,
    input MOSI,
    input CS,
    output reg MISO,
    output reg [13:0] num
);
    reg [15:0] data;
    reg [3:0] cnt_reg, cnt_next;
    reg [1:0] state, next;
    localparam IDLE = 0, LOW = 1, HIGH = 2, DONE = 3; 

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            num <= 0;
        end
        else begin
            if (cnt_next == 15) begin
                num <= data;
            end
            else begin
                num <= num;
            end
        end
    end
    
    always @(posedge SCLK, posedge rst) begin
        if (rst) begin
            cnt_reg <= 0;
            data <= 0;
            state <= IDLE;
        end
        else begin
            state <= next;
            cnt_reg <= cnt_next;
            data[cnt_next] <= MOSI;
        end
    end

    always @(*) begin
        next = state;
        cnt_next = cnt_reg;
        case (state)
            IDLE: begin
                cnt_next = 0;
                if (!CS) begin
                    next = LOW;    
                end
            end
            LOW: begin
                if (cnt_reg == 8) begin
                    next = HIGH;
                end
                else begin
                    cnt_next = cnt_reg + 1;
                end
            end
            HIGH: begin
                if (cnt_next == 15) begin
                    next = IDLE;
                end
                else begin
                    cnt_next = cnt_reg + 1;
                end
            end 
            DONE: begin
                next = IDLE;
            end 
        endcase
    end
endmodule