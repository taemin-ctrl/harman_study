`timescale 1ns / 1ps

module ControlUnit (
    input  logic       clk,
    input  logic       reset,
    output logic       RFSrcMuxSel,
    output logic [2:0] readAddr1,
    output logic [2:0] readAddr2,
    output logic [2:0] writeAddr,
    output logic       writeEn,
    output logic       outBuf,
    input  logic       iLe10,
    output logic aluOp
);
    typedef enum { S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11 } state_e;
    
    state_e state, state_next;
    logic [14:0] out_signals;

    assign {RFSrcMuxSel, readAddr1, readAddr2, writeAddr, writeEn, outBuf, aluOp} = out_signals;

    always_ff @(posedge clk, posedge reset) begin : state_reg
        if (reset) state <= S0;
        else state <= state_next;
    end

    always_comb begin : state_next_machine
        state_next     = state;
        out_signals = 0;
        case (state)
            //{RFSrcMuxSel, readAddr1, readAddr2, writeAddr, writeEn, outBuf, aluOp} = out_signals;
            S0: begin // R1 = 1;
                out_signals = 14'b0_000_000_001_1_0_000;
                state_next     = S1;
            end
            S1: begin // R2 = 0;
                out_signals = 14'b1_000_000_010_1_0_000;
                state_next     = S2;
            end
            S2: begin // R3 = 0;
                out_signals = 14'b1_000_000_011_1_0_000;
                state_next     = S3;
            end
            S3: begin // R4 = R1 + R1;
                out_signals = 14'b0_001_001_100_1_0_000;
                state_next = S4;
            end
            S4: begin // R5 = R4 + R4;
                out_signals = 14'b0_100_100_101_1_0_000;
                state_next     = S5;
            end
            S5: begin // R6 = R5 - R1 = 3
                out_signals = 14'b0_101_001_110_1_0_001;
                state_next     = S6;
            end
            S6: begin // R2 = R6 and R4 = 5
                out_signals = 14'b0_110_100_001_1_0_010;
                state_next     = S7;
            end 
            S7: begin // R3 = R2 or R5 = 6
                out_signals = 14'b0_001_101_011_1_0_011;
                state_next     = S8;
            end
            S8: begin // R7 = R3 xor R2 = 4
                out_signals = 14'b0_011_100_111_1_0_100;
                state_next     = S8;
            end
            S9: begin // not R7 = 3
                out_signals = 14'b0_111_000_111_1_0_101;
                state_next     = S8;
            end
            S10: begin // if (R7 > R4) goto S4 
                out_signals = 14'b0_111_100_000_0_0_000;
                if (iLe10) state_next = S11;
                else state_next = S3;
            end
            S11: begin // halt
                out_signals = 14'b0_000_000_000_0_1_000;
                state_next     = S8;
            end
        endcase
    end
endmodule
