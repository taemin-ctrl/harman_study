`timescale 1ns / 1ps

module Datapath1(
    input clk,
    input reset,
    input logic RFSrcMuxSel,
    input logic [2:0] readAddr1,
    input logic [2:0] readAddr2,
    input logic [2:0] writeAddr,
    input logic  writeEn,
    output logic iLe10,
    output logic outBuf,
    output logic [7:0] outPort
    );

    logic [7:0] adder_sum;
    logic [7:0] mux_data;
    logic [7:0] rdata1; // i
    logic [7:0] rdata2; // sum

    RegFile u_reg(
        .clk(clk),
        .readAddr1(readAddr1),
        .readAddr2(readAddr2),
        .writeAddr(writeAddr),
        .writeEn(writeEn),
        .wData(mux_data),
        .rData1(rdata1), // r1
        .rData2(rdata2) // 1, sum
    );
    
    mux_2x1 u_mux(
        .sel(RFSrcMuxSel),
        .x0(adder_sum),
        .x1(8'b1),
        .y(mux_data)
    );

    comparator u_com(
        .a(rdata1),
        .b(8'd10),
        .le(iLe10)
    );

    adder u_Adder(
        .a(rdata1),
        .b(rdata2),
        .sum(adder_sum)
    );

    register u_register(
        .clk(clk),
        .reset(reset),
        .en(outBuf),
        .d(rdata2),
        .q(outPort)
    );

endmodule

module RegFile (
    input logic clk,
    input logic [2:0] readAddr1,
    input logic [2:0] readAddr2,
    input logic [2:0] writeAddr,
    input logic  writeEn,
    input logic [7:0] wData,
    output logic [7:0] rData1,
    output logic [7:0] rData2
);
    logic [7:0] mem[0:7];

    always_ff @( posedge clk ) begin : write
        if (writeEn) begin
            mem[writeAddr] <= wData;
        end
    end

    assign rData1 = (readAddr1 == 3'b0) ? 8'b0 : mem[readAddr1];
    assign rData2 = (readAddr2 == 3'b0) ? 8'b0 : mem[readAddr2];
endmodule

module mux_2x1 (
    input logic sel,
    input logic [7:0] x0,
    input logic [7:0] x1,
    output logic [7:0] y
    );
    
    always_comb begin : mux
        y = 8'b0;
        case (sel)
            1'b0: y = x0;
            2'b1: y = x1; 
        endcase
    end

endmodule

module comparator (
    input logic [7:0] a,
    input logic [7:0] b,
    output logic le
    );
    assign le = (a <= b);
endmodule

module adder (
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] sum
    );
    assign sum = a + b;
endmodule

module register (
    input logic clk,
    input logic reset,
    input logic en,
    input logic [7:0] d,
    output logic [7:0] q
    );
    always_ff @( posedge clk, posedge reset ) begin : blockName
        if (reset) begin
            q <= 0;
        end
        else begin
            if (en) begin
                q <= d;    
            end
        end
    end
endmodule