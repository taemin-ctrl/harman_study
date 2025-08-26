`timescale 1ns / 1ps

`include "defines.sv"

module ControlUnit (
    input logic clk,
    input logic reset,
    input  logic [31:0] instrCode,
    output logic        regFileWe,
    output logic [ 3:0] aluControl,
    output logic        aluSrcMuxSel,
    output logic        dataWe,
    output logic [ 2:0] RFWDSrcMuxSel,
    output logic        branch,
    output logic        jal,
    output logic        jalr,
    output logic        PCEn
);
    wire [6:0] opcode = instrCode[6:0];
    wire [3:0] operators = {
        instrCode[30], instrCode[14:12]
    };  // {func7[5], func3}

    typedef enum logic [3:0] { FETCH = 0, DECODE, REXE, IEXE, LEXE, SEXE, BEXE, 
                                LMA, LWB, SME, LUEXE, AUEXE, JEXE, JLEXE } state_t;
    state_t state, next;

    logic [9:0] signals;
    assign {regFileWe, aluSrcMuxSel, dataWe, RFWDSrcMuxSel, branch, jal, jalr} = signals;



    always_ff @( posedge clk, posedge reset ) begin 
        if (reset) begin
            state <= FETCH;
        end
        else begin
            state <= next;
        end
    end

    always_comb begin
        next = state; 
        PCEn = 0;
        signals = 9'b0;
        case (state)
            FETCH: begin
                PCEn = 1'b1;
                next = DECODE;
                signals = 9'b0;
            end
            DECODE: begin
                case (opcode)
                    `OP_TYPE_R:  next = REXE;
                    `OP_TYPE_S:  next = SEXE;
                    `OP_TYPE_L:  next = LEXE;
                    `OP_TYPE_I:  next = IEXE;
                    `OP_TYPE_B:  next = BEXE;
                    `OP_TYPE_LU: next = LUEXE;
                    `OP_TYPE_AU: next = AUEXE;
                    `OP_TYPE_J:  next = JEXE;
                    `OP_TYPE_JL: next = JLEXE;
                    default:    next = DECODE;
                endcase
            end
            REXE: begin
                signals = 9'b1_0_0_000_0_0_0;
                next  = FETCH;
            end
            IEXE: begin
                signals = 9'b1_1_0_000_0_0_0;
                next  = FETCH;
            end
            LEXE: begin
                signals = 9'b0_1_0_000_0_0_0;
                next = LMA;
            end
            SEXE: begin
                signals = 9'b0_1_0_000_0_0_0;
                next = SME;
            end
            BEXE: begin
                signals = 9'b0_0_0_000_1_0_0;
                next  = FETCH;
            end
            LMA: begin
                signals = 9'b0_0_0_001_0_0_0;
                next = LWB;
            end
            LWB: begin
                signals = 9'b1_0_0_001_0_0_0;
                next = FETCH;
            end
            SME: begin
                signals = 9'b0_0_1_000_0_0_0;
                next = FETCH;
            end
            LUEXE: begin
                signals = 9'b1_0_0_010_0_0_0;
                next = FETCH;
            end
            AUEXE: begin
                signals = 9'b1_0_0_011_0_0_0;
                next = FETCH;
            end
            JEXE: begin
                signals = 9'b1_0_0_100_0_1_0;
                next = FETCH;
            end
            JLEXE: begin
                signals = 9'b1_0_0_100_0_1_1;
                next = FETCH;
            end
            default: begin
                signals = 9'b0;
            end 
        endcase
    end


    

    /*always_comb begin
        signals = 9'b0;
        case (opcode)
            // {regFileWe, aluSrcMuxSel, dataWe, RFWDSrcMuxSel(3), branch, jal, jalr} = signals
            `OP_TYPE_R:  signals = 9'b1_0_0_000_0_0_0;
            `OP_TYPE_S:  signals = 9'b0_1_1_000_0_0_0;
            `OP_TYPE_L:  signals = 9'b1_1_0_001_0_0_0;
            `OP_TYPE_I:  signals = 9'b1_1_0_000_0_0_0;
            `OP_TYPE_B:  signals = 9'b0_0_0_000_1_0_0;
            `OP_TYPE_LU: signals = 9'b1_0_0_010_0_0_0;
            `OP_TYPE_AU: signals = 9'b1_0_0_011_0_0_0;
            `OP_TYPE_J:  signals = 9'b1_0_0_100_0_1_0;
            `OP_TYPE_JL: signals = 9'b1_0_0_100_0_1_1;
        endcase
    end*/

    always_comb begin
        aluControl = 4'bx;
        case (opcode)
            `OP_TYPE_S:  aluControl = `ADD;
            `OP_TYPE_L:  aluControl = `ADD;
            `OP_TYPE_JL: aluControl = `ADD;  // {func7[5], func3}
            `OP_TYPE_I: begin
                if (operators == 4'b1101)
                    aluControl = operators;  // {1'b1, func3}
                else aluControl = {1'b0, operators[2:0]};  // {1'b0, func3}
            end
            default : aluControl = operators;  // {func7[5], func3}
            // `OP_TYPE_R:  aluControl = operators;  // {func7[5], func3}
            // `OP_TYPE_B:  aluControl = operators;  // {func7[5], func3}
            // `OP_TYPE_LU: aluControl = operators;  // {func7[5], func3}
            // `OP_TYPE_AU: aluControl = operators;  // {func7[5], func3}
            // `OP_TYPE_J:  aluControl = operators;  // {func7[5], func3}
        endcase
    end
endmodule
