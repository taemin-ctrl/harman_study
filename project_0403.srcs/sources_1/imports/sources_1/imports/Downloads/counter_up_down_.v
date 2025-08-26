`timescale 1ns / 1ps

module top_counter_up_down (
    input        clk,
    input        reset,
    input [3:0] btn,
    output [3:0] fndCom,
    output [7:0] fndFont,
    input rx,
    output tx
);  
    wire [13:0] fndData;
    wire [ 3:0] fndDot;
    wire [13:0] count;
    wire [13:0] stopwatch;
    wire [3:0] dot_data;
    wire [3:0] stopdot;

    wire en, clear, mode, watch;
    wire b_en, b_clear, b_mode, b_watch;
    wire w_en, w_clear, w_mode, w_watch;

    assign w_en = b_en | en;
    assign w_clear = b_clear | clear;
    assign w_mode = b_mode | mode;
    assign w_watch = b_watch | watch;

    assign fndData = w_watch ? stopwatch : count;
    assign fndDot = w_watch ? stopdot : dot_data; 

    wire [7:0] rx_data;
    wire rx_done;

    wire [7:0] tx_data;
    wire tx_start;
    wire tx_busy;
    wire tx_done;

    btn btn_c(
        .clk(clk),
        .reset(reset),
        .sw(btn[3]), // down
        .o_sw(b_clear)
    );

    btn btn_r_s(
        .clk(clk),
        .reset(reset),
        .sw(btn[2]), // right
        .o_sw(b_en)
    );

    btn btn_m(
        .clk(clk),
        .reset(reset),
        .sw(btn[0]), // up
        .o_sw(b_mode)
    );

    btn btn_w(
        .clk(clk),
        .reset(reset),
        .sw(btn[1]), // left
        .o_sw(b_watch)
    );

    control_unit U_ControlUnit (
        .clk        (clk),
        .reset      (reset),

        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .tx_done(tx_done),

        .rx_data(rx_data),
        .rx_done(rx_done),

        .en         (en),
        .clear      (clear),
        .mode       (mode),
        .watch (watch)
    );

    counter_up_down U_Counter (
        .clk     (clk),
        .reset   (reset),
        .en      (w_en),
        .clear   (w_clear),
        .mode    (w_mode),
        .count   (count),
        .stopwatch (stopwatch),
        .dot_data(dot_data),
        .stopdot(stopdot)
    );

    fndController U_FndController (
        .clk    (clk),
        .reset  (reset),
        .fndData(fndData),
        .fndDot (fndDot),
        .stopdot(stopdot),
        .fndCom (fndCom),
        .fndFont(fndFont)
    );

    uart u_uart(
        .clk(clk),
        .reset(reset),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx(tx),

        .rx_data(rx_data),
        .rx_done(rx_done),
        .rx(rx)
    );
endmodule

module control_unit (
    input      clk,
    input      reset,
    
    output reg [7:0] tx_data,
    output reg tx_start,
    input tx_busy,
    input tx_done,

    input [7:0] rx_data,
    input rx_done,
    output reg en,
    output reg clear,
    output reg mode,
    output reg watch
);
    localparam STOP = 0, RUN = 1, CLEAR = 2;
    localparam UP = 0, DOWN = 1;
    localparam IDLE = 0, ECHO = 1;
    localparam CNT = 0, WCH = 1;

    reg [1:0] state, state_next;
    reg mode_state, mode_state_next;
    reg echo_state, echo_state_next;
    reg cstate, nstate;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= STOP;
            mode_state <= UP;
            echo_state <= IDLE;
            cstate <= CNT;
        end else begin
            state <= state_next;
            mode_state <= mode_state_next;
            echo_state <= echo_state_next;
            cstate <= nstate;
        end
    end

    always @(*) begin
        case (cstate)
            CNT: begin
                watch = 0;
                if (rx_done) begin
                    if (rx_data == 8'h57 | rx_data == 8'h77) begin
                        nstate = WCH;
                    end 
                end
            end 
            WCH: begin
                watch = 1;
                if (rx_done) begin
                    if (rx_data == 8'h57 | rx_data == 8'h77) begin
                        nstate = CNT;
                    end 
                end
            end 
        endcase
    end

    always @(*) begin
        echo_state_next = echo_state;
        tx_start = 1'b0;
        case (echo_state)
            IDLE: begin
                tx_start = 1'b0;
                tx_data = 0;
                if (rx_done) begin
                    echo_state_next = ECHO;
                end
            end 
            ECHO: begin
                if (tx_done) begin
                    echo_state_next = IDLE;
                    tx_start = 0;
                    tx_data = 0;
                end
                else begin
                    tx_start = 1'b1;
                    tx_data = rx_data;
                end
            end 
        endcase
    end

    always @(*) begin
        mode_state_next = mode_state;
        mode = 1'b0;
        case (mode_state)
            UP: begin
               mode = 1'b0; 
               if (rx_done) begin
                    if (rx_data == 8'h4d | rx_data == 8'h6d) begin
                        mode_state_next = DOWN;
                    end 
                end
            end 
            DOWN: begin
                mode = 1'b1;
                if (rx_done) begin
                    if (rx_data == 8'h4d | rx_data == 8'h6d) begin
                        mode_state_next = UP;
                    end 
                end
            end 
        endcase
    end

    always @(*) begin
        state_next = state;
        en         = 1'b0;
        clear      = 1'b0;
        case (state)
            STOP: begin
                en = 1'b0;
                clear = 1'b0;
                if (rx_done) begin
                    if (rx_data == 8'h52 | rx_data == 8'h72) begin
                        state_next = RUN;
                    end 
                    else if (rx_data == 8'h43 | rx_data == 8'h63) begin
                        state_next = CLEAR;
                    end
                end
            end
            RUN: begin
                en = 1'b1;
                clear = 1'b0;
                if (rx_done) begin
                    if (rx_data == 8'h53 | rx_data == 8'h73) begin
                        state_next = STOP;
                    end 
                end
            end
            CLEAR: begin
                en = 1'b0;
                clear = 1'b1;
                state_next = STOP;
            end
        endcase
    end
endmodule




module comp_dot (
    input  [13:0] count,
    output [ 3:0] dot_data,
    output [3:0] stopdot
);
    assign dot_data = ((count % 10) < 5) ? 4'b1101 : 4'b1111;
    assign stopdot = ((count % 10) < 5) ? 4'b0101 : 4'b1111;
endmodule

module counter_up_down (
    input         clk,
    input         reset,
    input         en,
    input         clear,
    input         mode,
    output [13:0] count,
    output [13:0] stopwatch,
    output [ 3:0] dot_data,
    output [3:0] stopdot
);
    wire tick;

    clk_div_10hz U_Clk_Div_10Hz (
        .clk  (clk),
        .reset(reset),
        .tick (tick),
        .en   (en),
        .clear(clear)
    );

    counter U_Counter_Up_Down (
        .clk  (clk),
        .reset(reset),
        .tick (tick),
        .mode (mode),
        .en   (en),
        .clear(clear),
        .count(count)
    );

    stopwatch u_stopwatch(
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .en(en),
        .clear(clear),
        .count(stopwatch)
    );

    comp_dot U_Comp_Dot (
        .count(count),
        .dot_data(dot_data),
        .stopdot(stopdot)
    );
endmodule


module counter (
    input         clk,
    input         reset,
    input         tick,
    input         mode,
    input         en,
    input         clear,
    output [13:0] count
);
    reg [$clog2(10000)-1:0] counter;

    assign count = counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else begin
            if (clear) begin
                counter <= 0;
            end else begin
                if (en) begin
                    if (mode == 1'b0) begin
                        if (tick) begin
                            if (counter == 9999) begin
                                counter <= 0;
                            end else begin
                                counter <= counter + 1;
                            end
                        end
                    end else begin
                        if (tick) begin
                            if (counter == 0) begin
                                counter <= 9999;
                            end else begin
                                counter <= counter - 1;
                            end
                        end
                    end
                end
            end
        end
    end
endmodule

module stopwatch (
    input         clk,
    input         reset,
    input         tick,
    input         en,
    input         clear,
    output [13:0] count
);
    reg [$clog2(1000)-1:0] counter;
    reg [3:0] m_counter;

    assign count = {m_counter, counter};

    always @(posedge clk, posedge reset) begin
        if (reset ) begin
            counter <= 0;
            m_counter <= 0;
        end else begin
            if (clear) begin
                counter <= 0;
                m_counter <= 0;
            end else begin
                if (en) begin
                        if (tick) begin
                            if (counter == 599) begin
                                counter <= 0;
                                if (m_counter == 9) begin
                                    m_counter <= 0;
                                end
                                else begin
                                    m_counter <= m_counter + 1;
                                end
                            end else begin
                                counter <= counter + 1;
                            end
                        end
                    end 
            end
        end
    end
endmodule

module clk_div_10hz (
    input  wire clk,
    input  wire reset,
    input  wire en,
    input  wire clear,
    output reg  tick
);
    reg [$clog2(10_000_000)-1:0] div_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end else begin
            if (en) begin
                if (div_counter == 10_000_000 - 1) begin
                    div_counter <= 0;
                    tick <= 1'b1;
                end else begin
                    div_counter <= div_counter + 1;
                    tick <= 1'b0;
                end
            end
            if (clear) begin
                div_counter <= 0;
                tick <= 1'b0;
            end
        end
    end
endmodule

module btn(
    input clk,
    input reset,
    input sw,
    output o_sw
);
    reg pre;
    reg r_sw = 0;
    assign o_sw = r_sw; 
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            pre <= 0;
            r_sw <= 0;
        end
        else begin
            if (sw == 1 & pre == 0) begin
                pre <= 1;
                r_sw <= ~r_sw;
            end
            else if (sw == 0) begin
                pre <= 0;
            end
        end
    end
endmodule