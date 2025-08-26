`timescale 1ns / 1ps

module uart(
    input clk,
    input rst,
    input btn_start,
    input [7:0] data_in,
    output tx,
    output tx_done
    );

    wire w_tick; 

    baud_tick_gne u_baud_tick_gen(
        .clk(clk),
        .reset(rst), 
        .baud_tick(w_tick)
    );

    uart_h u_uart_tx(
        .clk(clk),
        .rst(rst),
        .tick(w_tick),
        .start_trigger(btn_start),
        .data_in(data_in),
        .o_tx(tx),
        .o_tx_done(tx_done)
);    
/*uart_tx u_uart_tx(
        .clk(clk),
        .rst(rst),
        .tick(w_tick),
        .start_trigger(btn_start),
        .data_in(data_in),
        .o_tx(tx),
        .o_tx_done(tx_done)
);  */
endmodule

module uart_tx (
    input clk,
    input rst,
    input tick,
    input start_trigger,
    input [7:0] data_in,
    output o_tx,
    output o_tx_done
);
    parameter IDLE = 4'h0, START = 4'h1, D0 = 4'h2, D1 = 4'h3, D2 = 4'h4, D3 = 4'h5, D4 = 4'h6, 
              D5 = 4'h7, D6 = 4'h8, D7 = 4'h9, STOP = 4'ha;
    
    reg [3:0] state, next;
    reg tx_reg, tx_next;

    assign o_tx = tx_reg;
    //assign tx_done = (state != IDLE);
    reg tx_done_reg, tx_done_next;
    assign o_tx_done = tx_done_reg;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            state <= IDLE;
            tx_reg <= 1'b1; // uart tx line high
            tx_done_reg <= 0;
        end
        else begin
            state <= next;
            tx_reg <= tx_next;
            tx_done_reg <= tx_done_next;        
        end
    end

    always @(*) begin
        next = state;
        tx_next = tx_reg;
        tx_done_next = tx_done_reg;
        case (state)
            IDLE: begin
                tx_next = 1'b1;
                //tx_done_next = 1'b1;
                if (start_trigger) begin
                    next = START;
                end
            end 
            START: begin
                if (tick) begin
                    tx_done_next = 1'b1;
                    tx_next = 1'b0;
                    next = D0;
                end
            end
            D0: begin
                if (tick) begin
                    tx_next = data_in[0];
                    next = D1;
                end
            end
            D1: begin
                if (tick) begin
                    tx_next = data_in[1];
                    next = D2;
                end
            end
            D2: begin
                if (tick) begin
                    tx_next = data_in[2];
                    next = D3;
                end
            end
            D3: begin
                if (tick) begin
                    tx_next = data_in[3];
                    next = D4;
                end
            end
            D4: begin
                if (tick) begin
                    tx_next = data_in[4];
                    next = D5;
                end
            end
            D5: begin
                if (tick) begin
                    tx_next = data_in[5];
                    next = D6;
                end
            end
            D6: begin
                if (tick) begin
                    tx_next = data_in[6];
                    next = D7;
                end
            end
            D7: begin
                if (tick) begin
                    tx_next = data_in[7];
                    next = STOP;
                end
            end
            STOP: begin
                
                if (tick) begin
                    tx_done_next = 1'b0;
                    tx_next = 1'b1;
                    next = IDLE;
                end
            end
            //default: 
        endcase
    end
endmodule


module baud_tick_gne (
    input clk,
    input reset, 
    output baud_tick
);
    parameter BAUD_RATE = 9600; //, BAUD_RATE_19200;
    localparam BAUD_COUNT = 100_000_000/BAUD_RATE;

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

module uart_h(
    input clk,
    input rst,
    input tick,
    input start_trigger,
    input [7:0] data_in,
    output o_tx,
    output o_tx_done
);
    parameter IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;
    
    reg [1:0] state, next;
    reg tx_reg, tx_next;

    reg [2:0] cnt;

    assign o_tx = tx_reg;
    //assign tx_done = (state != IDLE);
    reg tx_done_reg, tx_done_next;
    assign o_tx_done = tx_done_reg;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            state <= IDLE;
            tx_reg <= 1'b1; // uart tx line high
            tx_done_reg <= 0;
        end
        else begin
            state <= next;
            tx_reg <= tx_next;
            tx_done_reg <= tx_done_next;        
        end
    end

    always @(*) begin
        next = state;
        tx_next = tx_reg;
        tx_done_next = tx_done_reg;
        case (state)
            IDLE: begin
                tx_next = 1'b1;
                //tx_done_next = 1'b1;
                if (start_trigger) begin
                    next = START;
                    tx_next = 1'b0;
                end
            end 
            START: begin
                if (tick) begin
                    tx_done_next = 1'b1;
                    //tx_next = 1'b0;
                    next = DATA;
                end
            end
            DATA: begin
                if (tick & cnt == 7) begin
                    next = STOP;
                    tx_next = data_in[cnt];
                end
                else if (tick) begin
                    tx_next = data_in[cnt];
                end

            end
            STOP: begin
                if (tick) begin
                    tx_done_next = 1'b0;
                    tx_next = 1'b1;
                    next = IDLE;
                end
            end
            //default: 
        endcase
    end

    always @(posedge clk) begin
        if (state == DATA) begin
            if (tick) begin
                cnt <= cnt + 1'b1;
            end
        end
        else begin
            cnt <= 0;
        end
    end

    
endmodule