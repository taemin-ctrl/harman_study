`timescale 1ns / 1ps

module ControlUnit(
    input logic clk,
    input logic reset,
    output logic sumSrcMuxSel,
    output logic iSrcMuxSel,
    output logic sumEn,
    output logic iEn,
    output logic adderSrcMuxSel,
    output logic outBuf,
    input logic iLe10
    );
    
    //localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5;
    typedef enum { S0=0, S1, S2, S3, S4, S5 } state_e;
    state_e state, state_next;

    always_ff @(posedge clk, posedge reset) begin : state_reg
        if (reset) begin
            state <= S0;
        end
        else begin
            state <= state_next;            
        end
    end

    always_comb begin : state_next_machine
        state_next = state;
        sumSrcMuxSel = 0;
        iSrcMuxSel = 0;
        sumEn = 0;
        iEn = 0;
        adderSrcMuxSel = 0;
        outBuf = 0;
        case (state)
            S0: begin
                sumSrcMuxSel = 0;
                iSrcMuxSel = 0;
                sumEn = 1;
                iEn = 1;
                adderSrcMuxSel = 1'bx;
                outBuf = 0;
                state_next = S1;
            end 
            S1: begin
                sumSrcMuxSel = 1'bx;
                iSrcMuxSel = 1'bx;
                sumEn = 0;
                iEn = 0;
                adderSrcMuxSel = 1'bx;
                outBuf = 0;
                if (iLe10) begin
                    state_next = S2;
                end
                else begin
                    state_next = S5;
                end
            end
            S2: begin
                sumSrcMuxSel = 1;
                iSrcMuxSel = 1'bx;
                sumEn = 1;
                iEn = 0;
                adderSrcMuxSel = 0;
                outBuf = 0;
                state_next = S3;
            end
            S3: begin
                sumSrcMuxSel = 1'bx;
                iSrcMuxSel = 1;
                sumEn = 0;
                iEn = 1;
                adderSrcMuxSel = 1;
                outBuf = 0;
                state_next = S4;
            end
            S4: begin
                sumSrcMuxSel = 1'bx;
                iSrcMuxSel = 1'bx;
                sumEn = 0;
                iEn = 0;
                adderSrcMuxSel = 1'bx;
                outBuf = 1;
                state_next = S1;
            end
            S5: begin
                sumSrcMuxSel = 1'bx;
                iSrcMuxSel = 1'bx;
                sumEn = 0;
                iEn = 0;
                adderSrcMuxSel = 1'bx;
                outBuf = 0;
                state_next = S5;
            end
        endcase
    end
endmodule
