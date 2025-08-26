`timescale 1ns / 1ps

module TOP_UART (
    input clk,
    input rst,
    input rx,
    output tx,
    output [7:0] seg,
    output [3:0] ans
);
    wire w_rx_done;
    wire [7:0] w_rx_data;

    assign ans  = 4'b1110;
    
    uart u_uart(
        .clk(clk),
        .rst(rst),
    // tx
        .btn_start(w_rx_done),
        .data_in(w_rx_data),
        .tx(tx),
        .tx_done(),
    // rx
        .rx(rx),
        .rx_done(w_rx_done),
        .rx_data(w_rx_data)
    );
    fnd_controller u_fnd(
        .sig(w_rx_data),
        .fnd(seg)
    );
endmodule

module uart(
    input clk,
    input rst,
    // tx
    input btn_start,
    input [7:0] data_in,
    output tx,
    output tx_done,
    // rx
    input rx,
    output rx_done,
    output [7:0] rx_data
    );

    wire w_tick; 

    baud_tick_gne u_baud_tick_gen(
        .clk(clk),
        .reset(rst), 
        .baud_tick(w_tick)
    );

    uart_tx u_uart_tx(
        .clk(clk),
        .rst(rst),
        .tick(w_tick),
        .start_trigger(btn_start),
        .data_in(data_in),
        .o_tx(tx),
        .o_tx_done(tx_done)
    );

    uart_rx u_uart_rx(
        .clk(clk),
        .rst(rst),
        .tick(w_tick),
        .rx(rx),
        .rx_done(rx_done),
        .rx_data(rx_data)
    ); 
endmodule


module baud_tick_gne (
    input clk,
    input reset, 
    output baud_tick
);
    parameter BAUD_RATE = 9600; //, BAUD_RATE_19200;
    localparam BAUD_COUNT = (100_000_000 / BAUD_RATE)/16;

    reg [$clog2(BAUD_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    // output
    assign baud_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            tick_reg <= 0;
        end
        else begin
            count_reg <= count_next;
            tick_reg <= tick_next;
        end
    end

    // next
    always @(*) begin
        count_next = count_reg;
        tick_next = tick_reg;
        if (count_reg == BAUD_COUNT - 1) begin
            count_next = 0;
            tick_next = 1'b1;
        end
        else begin
            count_next = count_reg + 1'b1;
            tick_next = 1'b0;
        end
    end
endmodule

module uart_tx(
    input clk,
    input rst,
    input tick,
    input start_trigger,
    input [7:0] data_in,
    output o_tx,
    output o_tx_done
);
    localparam IDLE = 0, SEND = 1, START = 2, DATA = 3, STOP = 4;
    
    reg [3:0] state, next;
    reg tx_reg, tx_next;
    reg tx_done_reg, tx_done_next;
    reg [2:0] bit_count_reg, bit_count_next;
    reg [3:0] tick_count_reg, tick_count_next;

    assign o_tx = tx_reg;    
    assign o_tx_done = tx_done_reg;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            state <= IDLE;
            tx_reg <= 1'b1; // uart tx line high
            tx_done_reg <= 0;
            bit_count_reg <= 0;
            tick_count_reg <= 0;
        end
        else begin
            state <= next;
            tx_reg <= tx_next;
            tx_done_reg <= tx_done_next;  
            bit_count_reg <= bit_count_next; 
            tick_count_reg <= tick_count_next;     
        end
    end

    always @(*) begin
        next = state;
        tx_next = tx_reg;
        tx_done_next = tx_done_reg;
        bit_count_next = bit_count_reg;
        tick_count_next = tick_count_reg;
        case (state)
            IDLE: begin
                tx_next = 1'b1;
                tx_done_next = 1'b0;
                tick_count_next = 4'h0;
                if (start_trigger) begin
                    next = START;
                end
            end 
            SEND: begin // 1 tick consume -> multi data don't process 
                tx_next = 1'b1;
                if (tick) begin
                    next = START;
                end
            end
            START: begin
                tx_done_next = 1'b1;
                tx_next = 0;
                if (tick) begin
                    if (tick_count_reg == 15) begin
                        next = DATA;
                        bit_count_next = 1'b0;
                        tick_count_next = 1'b0;
                    end
                    else begin
                        tick_count_next = tick_count_reg + 1'b1;
                    end
                end
            end
            DATA: begin
                tx_next = data_in[bit_count_reg];
                
                if (tick) begin
                    if (tick_count_reg == 15) begin
                        tick_count_next = 1'b0;
                        if (bit_count_reg == 7) begin
                            next = STOP;
                        end
                        else begin
                            next = DATA;
                            bit_count_next = bit_count_reg + 1'b1;
                        end
                    end
                    else begin
                        tick_count_next = tick_count_reg + 1'b1;
                    end 
                end
            end
            STOP: begin
                tx_next = 1'b1;
                if (tick) begin
                    if (tick_count_reg == 15) begin
                        next = IDLE;
                        tick_count_next = 0;
                    end
                    else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            //default: 
        endcase
    end
    
endmodule

module uart_rx (
    input clk,
    input rst,
    input tick,
    input rx,
    output rx_done,
    output [7:0] rx_data
);
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [1:0] state, next;
    reg rx_done_reg, rx_done_next;
    reg [2:0] bit_count_reg, bit_count_next;
    reg [4:0] tick_count_reg, tick_count_next; 
    reg [7:0] rx_data_reg, rx_data_next;

    // output
    assign rx_done = rx_done_reg;
    assign rx_data = rx_data_reg; 

    // state
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
            rx_done_reg <= 0;
            rx_data_reg <= 0;
            bit_count_reg <= 0;
            tick_count_reg <= 0;
        end
        else begin
            state <= next;
            rx_done_reg <= rx_done_next;
            rx_data_reg <= rx_data_next;
            bit_count_reg <= bit_count_next;
            tick_count_reg <= tick_count_next;
        end
    end

    // next
    always @(*) begin
        next = state;
        tick_count_next = tick_count_reg;
        bit_count_next = bit_count_reg;
        rx_done_next = 1'b0;
        rx_data_next = rx_data_reg;
        case (state)
            IDLE: begin
                tick_count_next = 0;
                bit_count_next = 0;
                rx_done_next = 1'b0;
                if (rx == 1'b0) begin
                    next = START;
                end 
            end 
            START: begin
                if (tick) begin
                    if (tick_count_reg == 7) begin
                        next = DATA;
                        tick_count_next = 0;
                    end
                    else begin
                        tick_count_next = tick_count_reg + 1'b1;
                    end
                end
            end
            DATA: begin
                if (tick) begin
                    if (tick_count_reg == 15) begin
                        rx_data_next[bit_count_reg] = rx;
                        if (bit_count_reg == 7) begin
                            next = STOP;
                            tick_count_next = 0;
                        end
                        else begin
                            next = DATA;
                            bit_count_next = bit_count_reg + 1'b1;
                            tick_count_next = 0;
                        end
                    end
                    else begin
                        tick_count_next = tick_count_reg + 1'b1;
                    end
                end
            end
            STOP: begin
                if (tick) begin
                    if (tick_count_reg == 23) begin
                        rx_done_next = 1'b1;
                        next = IDLE;
                    end
                    else begin
                        tick_count_next = tick_count_reg + 1'b1;
                    end
                end
            end 
        endcase
    end
endmodule

module fnd_controller (
    input [7:0] sig,
    output reg [7:0] fnd
);
    always @(*) begin
        case(sig)
            8'h30: fnd = 8'hc0; // 0
            8'h31: fnd = 8'hF9; // 1
            8'h32: fnd = 8'hA4; // 2
            8'h33: fnd = 8'hB0; // 3
            8'h34: fnd = 8'h99; // 4
            8'h35: fnd = 8'h92; // 5
            8'h36: fnd = 8'h82; // 6
            8'h37: fnd = 8'hf8; // 7
            8'h38: fnd = 8'h80; // 8
            8'h39: fnd = 8'h90; // 9
            8'h41: fnd = 8'b1000_1000; // A -> dp 1, d 1
            8'h42: fnd = 8'h0; // 
            8'h43: fnd = 8'b1100_0110; // C -> dp 1, b, c ->1 modify
            8'h44: fnd = 8'b0100_0000; // D -> g 1
            8'h45: fnd = 8'b1000_0110; // E -> b,c , dp 1
            8'h46: fnd = 8'b1000_1110; // F b,c,d, dp 1
            default: fnd = 8'hff; 
        endcase
    end
endmodule