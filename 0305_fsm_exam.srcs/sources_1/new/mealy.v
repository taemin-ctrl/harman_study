`timescale 1ns / 1ps
`timescale 1ns / 1ps

module fsm_m(
    input clk,
    input reset,
    input [2:0] sw,
    output [2:0] led
    );
    
    reg [2:0] r_led;

    localparam IDLE = 3'b000, ST1 = 3'b001, ST2 = 3'b010, ST3 = 3'b011, ST4 = 3'b100;

    reg [2:0] state, next;

    assign led = r_led;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= 0;
        end
        else begin
            state <= next;
        end
    end

    always @(*) begin
        next = state;
        case (state)
            IDLE: begin
                if (sw == 3'b001) begin
                    next = ST1;
                end
                else if (sw == 3'b010) begin
                    next = ST2;
                end
                else begin
                    next = IDLE;
                end 
            end 
            ST1: begin
                if (sw == 3'b010) begin
                    next = ST2;
                end
                else begin
                    next = ST1;
                end
            end
            ST2: begin
                if (sw == 3'b100) begin
                    next = ST3;
                end
                else begin
                    next = ST2;
                end
            end
            ST3: begin
                if (sw == 3'b001) begin
                    next = ST1;
                end
                else if (sw == 3'b111) begin
                    next = ST4;
                end
                else if (sw == 3'b000) begin
                    next = IDLE;
                end
                else begin
                    next = ST3;
                end
            end
            ST4: begin
                if (sw == 3'b100) begin
                    next = ST3;
                end
                else begin
                    next = ST4;
                end
            end
        endcase
    end

    always @(*) begin
        case (sw)
            3'b000: r_led = 3'b000;
            3'b001: r_led = 3'b001;
            3'b010: r_led = 3'b010;
            3'b100: r_led = 3'b100;
            3'b111: r_led = 3'b111;
        endcase
    end
endmodule

