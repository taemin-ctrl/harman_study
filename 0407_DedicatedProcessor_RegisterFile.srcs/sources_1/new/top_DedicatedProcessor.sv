`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/07 12:38:50
// Design Name: 
// Module Name: top_DedicatedProcessor
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


module top_DedicatedProcessor1(
    input logic clk,
    input logic reset,
    output logic [7:0] outPort
    );

    logic RFSrcMuxSel;
    logic [2:0] readAddr1;
    logic [2:0] readAddr2;
    logic [2:0] writeAddr;
    logic  writeEn;
    logic iLe10;
    logic outBuf;

    Datapath1 u_dp(
        .*
    );

    ControlUnit1 u_cu(
        .*
    );
endmodule
