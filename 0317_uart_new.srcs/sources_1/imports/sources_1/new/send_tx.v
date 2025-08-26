`timescale 1ns / 1ps

module send_tx(
    input clk,
    input rst,
    input btn_start,
    input [7:0] tx_data_in,
    //input tx_done,
    output tx
    );

 wire w_btn_start;
 reg [7:0] send_tx_data_reg, send_tx_data_next;
 wire w_tx_done;
reg send_reg, send_next; // start trigger 출력

    uart U_Uart_Top(
    .clk(clk),
    .rst(rst),
    .btn_start(send_reg),
    .data_in(send_tx_data_reg),
    .tx(tx),
    .tx_done(w_tx_done)
    );

    btn_debounce U_Btn_Debounce(
    .clk(clk),
    .reset(rst),
    .i_btn(btn_start),
    .o_btn(w_btn_start)
    );

    //send tx ascii to PC
    parameter IDLE = 0, START = 1, SEND =2;
    reg [1:0] state, next; // send char fsm state
    reg [3:0] send_count_reg, send_count_next; //send data count

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            send_tx_data_reg <=8'h30; // "0" 둘다 가능
            state <= IDLE;
            send_reg <= 0;
            send_count_reg <= 0;
        end
        else begin
            send_tx_data_reg <= send_tx_data_next;
            state <= next ;
            send_reg <= send_next;
            send_count_reg <= send_count_next;
        end
    end

    always @(*) begin
        send_tx_data_next = send_tx_data_reg;
        next = state;
        send_next = 1'b0; // not using send_reg -> for 1 tick
        send_count_next = send_count_reg;
        case (state)
            IDLE: begin
                send_next = 1'b0;
                send_count_next = 0;
                if (w_btn_start == 1) begin
                    next = START;
                    send_next = 1'b1;
                end
            end
            START:begin
                send_next = 1'b0;
                if (w_tx_done == 1) begin
                    if (tx) begin
                        next = SEND;
                    end
                end
            end
            SEND: begin
                if(w_tx_done==1'b0)begin
                    send_next= 1'b1; // send 1 tick
                    send_count_next = send_count_reg + 1;
                    if (send_count_reg==15) begin
                        next = IDLE;
                    end
                    else begin
                        next = START;
                    end
                    // w_tx_done이 low로 떨어진다음에 1번만 증가 시키기 위함함
                     if (send_tx_data_reg == "z") begin
                         send_tx_data_next = "0";
                     end 
                     else if (w_tx_done==0) begin
                      send_tx_data_next = send_tx_data_reg +1; // ascii code value increasing
                     end
                end
            end     
        endcase
    
        end
            

endmodule