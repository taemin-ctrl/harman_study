`timescale 1ns / 1ps

module send_tx(
    input clk,
    input rst,
    input btn_start,
    input [7:0] tx_data_in,
    output tx
    );

    wire w_start, w_tx_done;
    wire [7:0] w_tx_data;

    reg [7:0] send_tx_data_reg, send_tx_data_next;
    //assign tx_data_in = send_tx_data_reg;

    uart u_uart(
        .clk(clk),
        .rst(rst),
        .btn_start(w_start),
        .data_in(send_tx_data_reg),
        .tx(tx),
        .tx_done(w_tx_done)
    );

    btn_debounce u_btn_db(
        .clk(clk),
        .reset(rst),
        .i_btn(btn_start),
        .o_btn(w_start)
    );

    // send tx ascii to pc
    
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            send_tx_data_reg <= "0";
        end
        else begin
            send_tx_data_reg <= send_tx_data_next;
        end
    end

    always @(*) begin
        send_tx_data_next = send_tx_data_reg;
        if (w_start) begin
            if (send_tx_data_reg == "z") begin
                send_tx_data_next = "0";
            end
            else 
                send_tx_data_next = send_tx_data_reg + 1'b1;
        end
    end
endmodule
