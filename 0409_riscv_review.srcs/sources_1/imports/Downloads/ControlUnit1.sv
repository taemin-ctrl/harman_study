`timescale 1ns / 1ps

`include "define.sv"

module ControlUnit (
    input  logic [31:0] instrCode,
    output logic        regFileWe,
    output logic [ 3:0] aluControl,
    output logic        aluSrcMuxSel,
    output logic        dataWe,
    output logic        RFWDSrcMuxSel,
    output logic        ISrcMuxSel,

    output logic  [2:0]   LDMuxSel,
    output logic   [2:0]  SDMuxSel
);
    wire [6:0] opcode = instrCode[6:0];
    wire [3:0] operators = {instrCode[30], instrCode[14:12]};  // {func7[5], func3}
    wire [2:0] ctl = instrCode[14:12];

    logic [3:0] signals;
    assign {regFileWe, aluSrcMuxSel, dataWe, RFWDSrcMuxSel} = signals;
    
    always_comb begin
        signals = 4'b0;
        case (opcode)
            `OP_TYPE_R: begin
                signals = 4'b1_0_0_0;  // R-Type
            end
            `OP_TYPE_S: begin
                signals = 4'b0_1_1_0;
            end
            `OP_TYPE_L: begin
                signals = 4'b1_1_0_1;
            end
            `OP_TYPE_I: begin
                signals = 4'b1_1_0_0;
            end
        endcase
    end

    always_comb begin
        aluControl = 4'bx;
        ISrcMuxSel = 0;
        LDMuxSel = 3'b0;
        SDMuxSel = 3'b0;
        case (opcode)
            `OP_TYPE_R: begin  // R-Type
                aluControl = operators;
            end
            `OP_TYPE_S: begin
                aluControl = `ADD;
                SDMuxSel = ctl;
            end
            `OP_TYPE_L: begin
                aluControl = `ADD;
                LDMuxSel = ctl;
            end
            `OP_TYPE_I: begin
                if (ctl == 3'b001 | ctl == 3'b101) begin
                    aluControl = {1'b0, ctl};
                    ISrcMuxSel = 1'b1;
                end
                else begin
                    aluControl = operators;
                    ISrcMuxSel = 1'b0;
                end
            end
        endcase
    end
endmodule
