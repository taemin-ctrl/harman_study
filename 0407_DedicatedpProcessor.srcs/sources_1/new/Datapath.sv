module Datapath (
    input logic clk,
    input logic reset,
    input logic sumSrcMuxSel,
    input logic iSrcMuxSel,
    input logic sumEn,
    input logic iEn,
    input logic adderSrcMuxSel,
    input logic outBuf,
    output logic iLe10,
    output logic [7:0] outPort
    );
    
    logic [7:0] adderResult, sumSrcMuxData, iSrcMuxData; 
    logic [7:0] sumRegData, iRegData, adderSrcMuxData;

    mux_2x1 u_sumsrcmux(
        .sel(sumSrcMuxSel),
        .x0(8'b0),
        .x1(adderResult),
        .y(sumSrcMuxData)
    );

    mux_2x1 u_iSrcmux(
        .sel(iSrcMuxSel),
        .x0(8'b0),
        .x1(adderResult),
        .y(iSrcMuxData)
    );

    register u_SumReg(
        .clk(clk),
        .reset(reset),
        .en(sumEn),
        .d(sumSrcMuxData),
        .q(sumRegData)
    );

    register u_iReg(
        .clk(clk),
        .reset(reset),
        .en(iEn),
        .d(iSrcMuxData),
        .q(iRegData)
    );

    mux_2x1 u_adderSrcmux(
        .sel(adderSrcMuxSel),
        .x0(sumRegData),
        .x1(8'b1),
        .y(adderSrcMuxData)
    );

    comparator u_com(
        .a(iRegData),
        .b(8'd10),
        .le(iLe10)
    );

    adder u_adder(
        .a(adderSrcMuxData),
        .b(iRegData),
        .sum(adderResult)
    );

    //assign outPort = outBuf ? sumRegData : 8'bz;

    register u_outBufReg(
        .clk(clk),
        .reset(reset),
        .en(outBuf),
        .d(sumRegData),
        .q(outPort)
    );
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

