`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/07 12:38:50
// Design Name: 
// Module Name: ControlUnit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ControlUnit1(
    input logic clk,
    input logic reset,
    output logic RFSrcMuxSel,
    output logic [2:0] readAddr1,
    output logic [2:0] readAddr2,
    output logic [2:0] writeAddr,
    output logic  writeEn,
    input logic iLe10,
    output logic outBuf
    );

    //localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5;
    typedef enum { S0=0, S1, S2, S3, S4, S5, S6, S7 } state_e;
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
        RFSrcMuxSel = 0;
        readAddr1 = 0;
        readAddr2 = 0;
        writeAddr = 0;
        writeEn = 0;
        outBuf = 0;
        case (state)
            S0: begin // 1
                RFSrcMuxSel = 1;
                readAddr1 = 0;
                readAddr2 = 0;
                writeAddr = 3'd7;
                writeEn = 1;
                outBuf = 0;
                state_next = S1;
            end
            S1: begin // r1 = 0;
                RFSrcMuxSel = 0;
                readAddr1 = 0;
                readAddr2 = 0;
                writeAddr = 3'd1;
                writeEn = 1;
                outBuf = 0;
                state_next = S2;
            end
            S2: begin // r2 = 0;
                RFSrcMuxSel = 0;
                readAddr1 = 0;
                readAddr2 = 0;
                writeAddr = 3'd2;
                writeEn = 1;
                outBuf = 0;
                state_next = S3;
            end  
            S3: begin // r1 <= 10;
                RFSrcMuxSel = 1'bx;
                readAddr1 = 3'd1;
                readAddr2 = 3'd2;
                writeAddr = 0;
                writeEn = 0;
                outBuf = 0;
                if (iLe10) begin
                    state_next = S4;
                end
                else begin
                    state_next = S7;
                end
            end
            S4: begin // r2 = r2 + r1;
                RFSrcMuxSel = 0;
                readAddr1 = 3'd1;
                readAddr2 = 3'd2;
                writeAddr = 3'd2;
                writeEn = 1;
                outBuf = 0;
                state_next = S5;
            end
            S5: begin // r = r1 + 1;
                RFSrcMuxSel = 0;
                readAddr1 = 3'd1;
                readAddr2 = 3'd7;
                writeAddr = 3'd1;
                writeEn = 1;
                outBuf = 0;
                state_next = S6;
            end
            S6: begin // output = r2;
                RFSrcMuxSel = 0;
                readAddr1 = 0;
                readAddr2 = 3'd2;
                writeAddr = 0;
                writeEn = 0;
                outBuf = 1;
                state_next = S3;
            end
            S7: begin // halt
                RFSrcMuxSel = 0;
                readAddr1 = 0;
                readAddr2 = 0;
                writeAddr = 0;
                writeEn = 0;
                outBuf = 0;
                state_next = S7;
            end
        endcase
    end
endmodule
