`timescale 1ns / 1ps

module ControlUnit(
    input logic clk,
    input logic reset,
    output logic ASrMuxSel,
    output logic AEn,
    input logic ALt10,
    output logic OutBuf
    );

    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;
    logic [2:0] state, state_next;

    always_ff @( posedge clk, posedge reset ) begin : blockName
        if (reset) begin
            state <= S0;
        end
        else begin
            state <= state_next;
        end
    end

    always_comb begin 
        state_next = state;
        ASrMuxSel = 0;
        AEn = 0;
        OutBuf = 0;
        case (state)
            S0: begin
                ASrMuxSel = 0;
                AEn = 1;
                OutBuf = 0;
                state_next = S1;
            end 
            S1: begin
                ASrMuxSel = 0;
                AEn = 0;
                OutBuf = 0;
                if (ALt10) state_next = S2;
                else state_next = S4;
            end
            S2: begin
                ASrMuxSel = 0;
                AEn = 0;
                OutBuf = 1;
                state_next = S3;
            end
            S3: begin
                ASrMuxSel = 1;
                AEn = 1;
                OutBuf = 0;
                state_next = S1;
            end
            S4: begin
                ASrMuxSel = 0;
                AEn = 0;
                OutBuf = 0;
                state_next = S4;
            end
        endcase
    end

endmodule

/*
a = 0
s = 0
while (a >11){
s = s + a; 
a ++;
}
*/