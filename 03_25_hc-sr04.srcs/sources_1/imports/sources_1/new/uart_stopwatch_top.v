`timescale 1ns / 1ps

module uart_sensor_top(
    input clk,
    input reset,
    output [3:0] seg_comm,
    output [7:0] seg,
    input rx,
    output tx,

    output trigger,
    input echo 
    );

    wire [7:0] data;
    wire [6:0] ctl, w_ctl;
    wire tig;
    wire w_sig;
    wire [7:0] w_data;
    wire [7:0] b_data;

    top_module u_uart(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .rx_data(data),
        .tx_data(w_data),
        .tx(tx),
        .empty(w_tig)
    );
    
    uart_cu u_uart_cu(
        .i_data(data),
        .o_data(ctl)
    );
    
    trigger u_tig(
        .empty(w_tig),
        .data(ctl),
        .tig(w_ctl)
    );

    top_ultrasonic_sensor u_sensor(
        .clk(clk),
        .rst(reset),
        .start(w_sig),
        .trigger(trigger),
        .echo(echo),
        .data(b_data)
    );

    fnd_controller u_fnd(
        .clk(clk), 
        .reset(reset),
        .bcd(b_data),
        .data(w_data),
        .seg(seg),
        .seg_comm(seg_comm)
    );

    k k1(
        .clk(clk),
        .rst(reset),
        .i_sig(w_ctl[5]),
        .o_sig(w_sig)
);
endmodule

module trigger (
    input empty,
    input [6:0] data,
    output [6:0] tig
);
    assign tig = empty? 0: data;
endmodule

module k (
    input clk,
    input rst,
    input i_sig,
    output o_sig
);
    reg [6:0] cnt_reg, cnt_next;

    reg state, next;
    localparam IDLE = 0, DATA = 1;

    assign o_sig = (state == DATA);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
            cnt_reg <= 0;
        end
        else begin
            state <= next;
            cnt_reg <= cnt_next;
        end
    end

    always @(*) begin
        next = state;
        cnt_next = cnt_reg;
        case (state)
            IDLE: begin
                if (i_sig) begin
                    next = DATA;
                end
            end 
            DATA: begin
                if (cnt_reg == 99) begin
                    next = IDLE;
                end
                else begin
                    cnt_next = cnt_reg + 1;
                end
            end 
        endcase
    end
endmodule