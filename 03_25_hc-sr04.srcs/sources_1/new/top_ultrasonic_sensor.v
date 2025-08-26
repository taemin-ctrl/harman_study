`timescale 1ns / 1ps

module top_ultrasonic_sensor(
    input clk,
    input rst,
    input start,
    output trigger,
    input echo,
    output [7:0] data
    /*output [7:0] seg,
    output [3:0] seg_comm*/
    );

    wire w_tick;
    //wire [9:0] data;
    wire w_start;


    tick_generator u_tik(
        .clk(clk),
        .rst(rst),
        .tick(w_tick)
    );

    sensor_cu u_cu(
        .clk(w_tick),
        .rst(rst),
    
        .start(start),
        .trigger(trigger),
    
        .echo(echo),
        .o_result(data)
    );

    /*/fnd_controller u_fnd(
        .clk(clk), 
        .reset(rst),
        .bcd(data),
        .seg(seg),
        .seg_comm(seg_comm)
    );*/
endmodule

module tick_generator #(
    CNT = 100 // 1us
)(
    input clk,
    input rst,
    output tick
);
    reg r_tick;
    assign tick = r_tick; 

    reg [$clog2(CNT)-1:0] cnt;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_tick <= 0;
            cnt <= 0;
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

module sensor_cu #(
    NUM = 23200
)(
    input clk,
    input rst,
    
    input start,
    output trigger,
    
    input echo,
    output [8:0] o_result
);
    localparam IDLE = 0, START = 1, DATA = 2;
    reg [1:0] state, next;
    
    assign trigger = (state == START) ? 1:0;

    reg [3:0] cnt_state, cnt_next;
    reg [$clog2(NUM)-1:0] echo_cs, echo_cn;

    assign o_result = (state == IDLE) ? (echo_cs/58) : 0;

    reg [9:0] cnt;
    reg flag;

    always @(posedge clk, posedge rst) begin
        if (rst)begin
           state <= 0;  
           cnt_state <= 0;
           echo_cs <= 0;
        end
        else begin
            state <= next;
            cnt_state <= cnt_next;
            echo_cs <= echo_cn;
        end
    end

    always @(*) begin
        next = state;
        cnt_next = cnt_state;
        echo_cn = echo_cs;
        case (state)
            IDLE: begin
                cnt_next = 0;
                if (start) begin
                    next = START; 
                end    
            end
            START: begin
                echo_cn = 0;
                if (cnt_state == 9) begin
                    next = DATA;
                end
                else begin
                    cnt_next = cnt_state + 1;
                end
            end 
            DATA: begin
                if(echo) begin
                    echo_cn = echo_cs + 1'b1;
                end
                else if ((~echo) & (|echo_cn))begin
                    next = IDLE;
                end
                else if (flag) begin
                    next = IDLE;
                end
            end 
        endcase
    end

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            cnt <= 0;
        end
        else begin
            if (cnt == 1_000) begin
                flag <= 1;
                cnt <= 0;
            end
            else begin
                flag <= 0;
                cnt <= cnt + 1;
            end
        end
    end
endmodule


