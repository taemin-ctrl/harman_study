`timescale 1ns / 1ps

module fsm_led(
    input clk,
    input reset,
    input [2:0] sw,
    output [1:0] led
    );

    localparam  IDLE= 2'b00, LED01 = 2'b01, LED02 = 2'b10;
    reg [1:0] state, next;
    reg [1:0] r_led;

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
                    next = 2'b01;
                end
            end
            LED01: begin
                if (sw == 3'b011) begin
                    next = LED02;
                end
            end
            LED02: begin
                if (sw == 3'b110) begin
                    next = LED01;
                end
                else if (sw == 3'b111) begin
                    next = IDLE;
                end
                else begin
                    next = state;
                end
            end
            default: next = state;
        endcase
    end

    always @(*) begin
        case (state)
            IDLE: begin
                r_led = 2'b00;
            end 
            LED01: begin
                r_led = 2'b10;
            end
            LED02: begin
                r_led = 2'b01;
            end
            default: r_led = 2'b11;
        endcase
    end
endmodule
