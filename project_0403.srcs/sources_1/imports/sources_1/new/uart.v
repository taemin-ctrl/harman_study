`timescale 1ns / 1ps

module uart(
    input clk,
    input reset,
    input [7:0] tx_data,
    input tx_start,
    output tx_busy,
    output tx_done,
    output tx,

    output [7:0] rx_data,
    output rx_done,
    input rx
    );

    wire br_tick;

    baudrate_gen u_baudrate_gen(
        .clk(clk),
        .reset(reset),
        .br_tick(br_tick)
    );
    
    transmitter u_transmitter(
        .clk(clk),
        .reset(reset),
        .br_tick(br_tick),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx(tx)
    );

    receiver u_receiver(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .br_tick(br_tick),
        .rx_data(rx_data),
        .rx_done(rx_done)    
    );
endmodule

module baudrate_gen (
    input clk,
    input reset,
    output reg br_tick
);
    reg [9:0] br_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            br_counter <= 0;
            br_tick <= 1'b0;
        end
        else begin
            if (br_counter == 100_000_000/9600/16 - 1) begin
                br_counter <= 0;
                br_tick <= 1'b1;
            end
            else begin
                br_counter <= br_counter + 1;
                br_tick <= 1'b0;
            end
        end
    end
endmodule

module transmitter (
    input clk,
    input reset,
    input br_tick,
    input [7:0] tx_data,
    input tx_start,
    output tx_busy,
    output tx_done,
    output reg tx
);
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
    reg [1:0] state, state_next;

    reg [7:0] temp_data_reg, temp_data_next;
    reg [2:0] bit_counter_reg, bit_counter_next;
    reg [3:0] tick_counter_reg, tick_counter_next;
    reg tx_busy_reg, tx_busy_next, tx_done_reg, tx_done_next;

    assign tx_busy = tx_busy_reg;
    assign tx_done = tx_done_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            temp_data_reg <= 0;
            bit_counter_reg <= 0;
            tick_counter_reg <= 0;
            tx_busy_reg <= 0;
            tx_done_reg <= 0;
        end
        else begin
            state <= state_next;
            temp_data_reg <= temp_data_next;
            bit_counter_reg <= bit_counter_next;
            tick_counter_reg <= tick_counter_next;
            tx_busy_reg <= tx_busy_next;
            tx_done_reg <= tx_done_next;
        end
    end

    always @(*) begin
        state_next = state;
        temp_data_next = temp_data_reg;
        bit_counter_next = bit_counter_reg;
        tick_counter_next = tick_counter_reg;
        tx_busy_next = tx_busy_reg;
        tx_done_next = tx_done_reg;
        case (state)
            IDLE: begin
                tx = 1'b1;
                tx_busy_next = 0;
                tx_done_next = 0;
                if (tx_start) begin
                    temp_data_next = tx_data;
                    state_next = START;
                    tx_busy_next = 1'b1;
                end
            end
            START: begin
                tx = 1'b0;
                if (br_tick) begin
                    if (tick_counter_reg == 15) begin
                        tick_counter_next = 0;
                        state_next = DATA;
                        bit_counter_next = 0;
                    end
                    else begin
                        tick_counter_next = tick_counter_reg + 1;
                    end
                end
            end 
            DATA: begin
                tx = temp_data_reg[0];
                if (br_tick) begin
                    if (tick_counter_reg == 15) begin
                        tick_counter_next = 0;
                        if (bit_counter_reg == 7) begin
                            state_next = STOP;
                        end
                        else begin
                            bit_counter_next = bit_counter_reg + 1;
                            temp_data_next = {1'b0, temp_data_reg[7:1]};
                        end
                    end
                    else begin
                        tick_counter_next = tick_counter_reg + 1;
                    end
                end
            end 
            STOP: begin
                tx = 1'b1;
                if (br_tick) begin
                    if (tick_counter_reg == 15) begin
                        state_next = IDLE;
                        tick_counter_next = 0;
                        tx_done_next = 1'b1;
                    end
                    else begin
                        tick_counter_next = tick_counter_reg + 1;
                    end
                end 
            end  
        endcase
    end
endmodule

module receiver (
    input clk,
    input reset,
    input rx,
    input br_tick,
    output [7:0] rx_data,
    output rx_done    
);
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
    reg [1:0] state, state_next;
    reg rx_done_next, rx_done_reg;
    reg [2:0] bit_counter_reg, bit_counter_next;
    reg [3:0] tick_counter_reg, tick_counter_next;
    reg [7:0] temp_data_reg, temp_data_next;

    assign rx_data = temp_data_reg;
    assign rx_done = rx_done_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            rx_done_reg <= 1'b0;
            bit_counter_reg <= 0;
            tick_counter_reg <= 0;
            temp_data_reg <= 0;
        end
        else begin
            state <= state_next;
            rx_done_reg <= rx_done_next;
            bit_counter_reg <= bit_counter_next;
            tick_counter_reg <= tick_counter_next;
            temp_data_reg <= temp_data_next;
        end
    end

    always @(*) begin
        state_next = state;
        rx_done_next = rx_done_reg;
        bit_counter_next = bit_counter_reg;
        tick_counter_next = tick_counter_reg;
        temp_data_next = temp_data_reg;
        case (state)
            IDLE: begin
                rx_done_next = 1'b0;
                if (rx == 1'b0) begin
                    state_next = START;
                    bit_counter_next = 0;
                    tick_counter_next = 0;
                    temp_data_next = 0;
                end
            end 
            START: begin
                if (br_tick) begin
                    if (tick_counter_reg == 7) begin
                        state_next = DATA;
                        tick_counter_next = 0;
                    end
                    else begin
                        tick_counter_next = tick_counter_reg + 1;
                    end
                end
            end
            DATA: begin
                if (br_tick) begin
                    if (tick_counter_reg == 15) begin
                        tick_counter_next = 0;
                        temp_data_next = {rx,temp_data_reg[7:1]};
                        if (bit_counter_reg == 7) begin
                            state_next = STOP;
                            bit_counter_next = 0;
                        end
                        else begin
                            bit_counter_next = bit_counter_reg + 1;
                        end
                    end
                    else begin
                        tick_counter_next = tick_counter_reg + 1;
                    end
                end
            end
            STOP: begin
                if (br_tick) begin
                    if (tick_counter_reg == 15) begin
                        state_next = IDLE;
                        rx_done_next = 1'b1;
                    end
                    else begin
                        tick_counter_next = tick_counter_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule
