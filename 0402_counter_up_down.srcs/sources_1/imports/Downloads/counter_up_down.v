`timescale 1ns / 1ps

module top_counter_up_down (
    input        clk,
    input        reset,
    input rx,
    output tx,
    output [3:0] fndCom,
    output [7:0] fndFont
);
    wire [13:0] fndData;
    wire [3:0] fndDot;

    wire clear, en, mode;

    wire w_tick;
    wire [7:0] data;
    wire [7:0] rx_data;
    wire rx_done;
    wire tx_done;

    reg pre;
    
    reg start;
    wire w_start;
    assign w_start = start;
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            pre <= 1;
            start <= 0;
        end
        else begin
            if (rx_done == 1 & pre == 0) begin
                start <= 1;
                pre <= 1;
            end
            else if (!rx_done) begin
                pre <= 0;
                start <= 0;
            end
            else begin
                start <= 0;
            end
        end
    end

    counter_up_down U_Counter (
        .clk  (clk),
        .reset(reset),
        .en(en),
        .clear(clear),
        .mode (mode),
        .count(fndData),
        .dot_data(fndDot)
    );

    fndController U_FndController (
        .clk(clk),
        .reset(reset),
        .fndData(fndData),
        .fndDot(fndDot),
        .fndCom(fndCom),
        .fndFont(fndFont)
    );

    control_unit u_control_cu(
        .clk(clk),
        .reset(reset),
        .sw_mode(sw_mode),
        .sw_run_stop(sw_run_stop),
        .sw_clear(sw_clear),
        .mode(mode), 
        .en(en),
        .clear(clear)
    );

    uart_rx u_rx(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tick(w_tick),
        .data(data),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    tick_gen u_tick_gen(
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );

    ascii u_ascii(
        .data(data),
        .mode(sw_mode),
        .clear(sw_clear),
        .run_stop(sw_run_stop)
    );
    
    uart_tx u_tx(
        .clk(clk),
        .reset(reset),
        .tick(w_tick),
        .start(w_start),
        .tx_data(rx_data),
        .tx(tx),
        .tx_done(tx_done),
        .tx_busy()
    );

    
endmodule

module control_unit (
    input clk,
    input reset,
    input sw_mode,
    input sw_run_stop,
    input sw_clear,
    output mode, 
    output reg clear,
    output reg en
);
    reg [1:0] state, state_next;
    localparam STOP = 0, RUN = 1, CLEAR = 2;

    assign mode = sw_mode;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STOP;
        end
        else begin
            state <= state_next;
        end
    end

    always @(*) begin
        state_next = state;
        en = 1'b0;
        clear = 1'b0;
        case (state)
            STOP: begin
                en = 1'b0;
                clear = 1'b0;
                if (sw_run_stop) begin
                    state_next = RUN;
                end
                else if (sw_clear) begin
                    state_next = CLEAR;
                end
            end 
            RUN: begin
                en = 1'b1;
                clear = 1'b0;
                if (sw_run_stop == 1'b0) begin
                    state_next = STOP;
                end
            end
            CLEAR: begin
                en = 1'b0;
                clear = 1'b1;
                if (sw_clear == 0) begin
                    state_next = STOP;
                end 
            end
        endcase
    end
endmodule

module comp_dot (
    input [13:0] count,
    output [3:0] dot_data
);
    assign dot_data = ((count%10) < 5) ? 4'b1101 : 4'b1111;
endmodule

module counter_up_down (
    input         clk,
    input         reset,
    input         clear,
    input         en,
    input         mode,
    output [13:0] count,
    output [3:0] dot_data
);
    wire tick;

    clk_div_10hz U_Clk_Div_10Hz (
        .clk  (clk),
        .reset(reset),
        .en(en),
        .clear(clear),
        .tick (tick)
    );

    counter U_Counter_Up_Down (
        .clk  (clk),
        .reset(reset),
        .tick (tick),
        .mode (mode),
        .en(en),
        .clear(clear),
        .count(count)
    );

    comp_dot u_comp_dot(
        .count(count),
        .dot_data(dot_data)
    );

endmodule


module counter (
    input         clk,
    input         reset,
    input         tick,
    input         mode,
    input en,
    input         clear,
    output [13:0] count
);
    reg [$clog2(10000)-1:0] counter;

    assign count = counter;

    always @(posedge clk, posedge reset) begin
        if (reset ) begin
            counter <= 0;
        end else begin
            if (clear) begin
                counter <= 0;
            end
            else begin
                if (en) begin
                    if (tick) begin
                        if (mode == 1'b0) begin
                            if (counter == 9999) begin
                                counter <= 0;
                            end 
                            else begin
                                counter <= counter + 1;
                            end
                        end
                        else begin
                            if (counter == 0) begin
                                counter <= 9999;
                            end 
                            else begin
                                counter <= counter - 1;
                            end
                        end
                    end
                end
                else begin
                    counter <= counter;
                end
            end
        end
    end
endmodule

module clk_div_10hz (
    input  wire clk,
    input  wire reset,
    input en,
    input clear,
    output reg  tick
);
    localparam k = 10_000_000;
    reg [$clog2(k)-1:0] div_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end else begin
            if (clear) begin
                div_counter <= 0;
                tick <= 1'b0;
            end
            if (en) begin
                if (div_counter == k - 1) begin
                    div_counter <= 0;
                    tick <= 1'b1;
                end else begin
                    div_counter <= div_counter + 1;
                    tick <= 1'b0;
                end
            end
            
        end
    end
endmodule

module uart_rx (
    input clk,
    input reset,
    input rx,
    input tick,
    output [7:0] data,
    output [7:0] rx_data,
    output rx_done
);
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
    reg [2:0] state, next;

    reg [7:0] rdata, ndata;
    reg [3:0] icnt, inext;
    
    reg [15:0] tick_cnt, tick_next;

    assign data = (state == IDLE) ? rdata : 0;
    assign rx_done = (state == IDLE);
    assign rx_data = rdata;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tick_cnt <= 0;
            icnt <= 0;
            rdata <= 0;
        end
        else begin
            state <= next;
            rdata <= ndata;
            tick_cnt <= tick_next;
            icnt <= inext;
        end
    end
    
    always @(*) begin
        next = state;
        tick_next = tick_cnt;
        ndata = rdata;
        inext = icnt;
        case (state)
            IDLE: begin
                if (!rx) begin
                    next = START;
                end 
            end 
            START: begin
                if (tick) begin
                    if (tick_cnt == 15) begin
                        next = DATA;
                        tick_next = 0; 
                    end 
                    else begin
                        tick_next = tick_cnt + 1;
                    end
                end
            end
            DATA: begin
                if (tick) begin
                    if (tick_cnt == 15) begin
                        ndata[icnt] = rx;
                        tick_next = 0;
                        if (icnt == 7) begin
                            inext = 0;
                            next = STOP;
                        end
                        else begin
                            inext = icnt + 1;
                        end
                    end
                        
                    else begin
                        tick_next = tick_cnt + 1;
                    end
                end
            end
            STOP: begin
                if (tick) begin
                    if (tick_cnt == 23) begin
                        tick_next = 0;
                        inext = 0;
                        next = IDLE;
                    end
                    else begin
                        tick_next = tick_cnt + 1;
                    end
                end
            end
        endcase
    end
endmodule

module tick_gen (
    input clk,
    input reset,
    output tick
);

    localparam CNT = (100_000_000)/(9600*16);

    reg r_tick;
    assign tick = r_tick;

    reg [$clog2(CNT)-1:0] cnt;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            cnt <= 0;
            r_tick <= 0;
        end
        else begin
            if (cnt == CNT-1) begin
                cnt <= 0;
                r_tick <= 1;
            end
            else begin
                r_tick <= 0;
                cnt <= cnt + 1;
            end
        end
    end
endmodule

module ascii (
    input [7:0] data,
    output reg mode,
    output reg run_stop,
    output reg clear
);
    always @(*) begin
        mode = 0;
        run_stop = 0;
        clear = 0;
        case (data)
            8'h6d: begin
                mode = 1; // m
                run_stop = 1;
                clear = 0;
            end
            8'h72: begin // r
                run_stop = 1;
                clear = 0;
                mode = 0;
            end 
            8'h73: begin // s
                run_stop = 0;
                clear = 0;
                mode = 1;
            end
            8'h63: begin // c
                clear = 1;
                run_stop = 0;
                mode = 0;
            end  
        endcase
    end
endmodule

module uart_tx (
      input clk,
      input reset,
      input tick,
      input start,
      input [7:0] tx_data,
      output tx,
      output tx_done,
      output tx_busy
      );
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
    reg [1:0] state, next;
    
    assign tx_done = (state == IDLE);
    assign tx_busy = (state != IDLE);
    
    reg [7:0] temp_reg, temp_next;
    reg [3:0] rcnt, ncnt;
    reg [2:0] icntr, icntn;
    reg r_tx, n_tx;
    assign tx = r_tx;
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            rcnt  <= 0;
            icntr <= 0;
            r_tx  <= 1;
            temp_reg <= 0;
        end
        else begin
            state <= next;
            rcnt  <= ncnt;
            icntr <= icntn;
            r_tx  <= n_tx;
            temp_reg <= temp_next;
        end
    end
    
    always @(*) begin
        next  = state;
        ncnt  = rcnt;
        icntn = icntr;
        n_tx  = r_tx;
        temp_next = temp_reg;
        case (state)
            IDLE: begin
                n_tx = 1;
                if (start) begin
                    next = START;
                    temp_next = tx_data;
                end
            end
            START: begin
                n_tx = 0;
                if (tick) begin
                    if (rcnt == 15) begin
                        next = DATA;
                        ncnt = 0;
                    end
                    else begin
                        ncnt = rcnt + 1;
                    end
                end
            end
            DATA: begin
                n_tx = temp_next[icntr];
                if (tick) begin
                    if (rcnt == 15) begin
                        ncnt = 0;
                        if (icntr == 7) begin
                            next  = STOP;
                            icntn = 0;
                        end
                        else begin
                            icntn = icntr + 1;
                        end
                    end
                    else begin
                        ncnt = rcnt + 1;
                    end
                end
            end
            STOP: begin
                n_tx = 1;
                if (tick) begin
                    if (rcnt == 15) begin
                        next = IDLE;
                        ncnt = 0;
                    end
                    else begin
                        ncnt = rcnt + 1;
                    end
                end
            end
        endcase
    end
endmodule
