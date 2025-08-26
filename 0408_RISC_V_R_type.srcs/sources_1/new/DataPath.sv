`timescale 1ns / 1ps

module DataPath(
    input logic clk,
    input logic reset,
    input logic [31:0] instrCode,
    output logic [31:0] instrMemAddr,
    input logic regFileWe,
    input logic [3:0] aluControl
    );
    
    logic [31:0] aluResult, RFData1, RFData2;
    logic [31:0] PCSrcData, PCOutData;
    
    assign instrMemAddr = PCOutData;

    RegisterFile u_registerfile(
        .clk(clk),
        .we(regFileWe),
        .RAddr1(instrCode[19:15]),
        .RAddr2(instrCode[24:20]),
        .WAddr(instrCode[11:7]),
        .WData(aluResult),
        .RData1(RFData1),
        .RData2(RFData2)
    );

    alu u_alu(
        .aluControl(aluControl),
        .a(RFData1),
        .b(RFData2),
        .result(aluResult)
    );

    register u_pc(
        .clk(clk),
        .reset(reset),
        .d(PCSrcData),
        .q(PCOutData)
    );

    adder u_pc_adder(
        .a(32'd4),
        .b(PCOutData),
        .y(PCSrcData)
    );


endmodule

module alu (
    input logic [3:0] aluControl,
    input logic [31:0] a,
    input logic [31:0] b,
    output logic [31:0] result
);
    always_comb begin 
        case (aluControl)
            4'b0000: result = a + b;
            4'b0001: result = a - b;
            4'b0010: result = a << b;
            4'b0011: result = a >> b;
            4'b0100: result = a >>> b;
            4'b0101: begin
                if (a[31] == 0  & b[31] == 0) result = (a < b);
                else if (a[31] == 0  & b[31] == 1) result = 32'b0;
                else if (a[31] == 1  & b[31] == 0) result = 32'b1;
                else result = (a > b);
            end
            4'b0110: result = (a < b);
            4'b0111: result = a ^ b;
            4'b1000: result = a | b;
            4'b1001: result = a & b;
            default: result = 32'bx;
        endcase
    end
endmodule

module register (
    input logic clk,
    input logic reset,
    input logic [31:0] d,
    output logic [31:0] q
);
    always_ff @( posedge clk, posedge reset ) begin : blockName
        if (reset) begin
            q <= 0;
        end
        else begin
            q <= d;
        end
    end
endmodule

module adder (
    input logic [31:0] a,
    input logic [31:0] b,
    output logic [31:0] y
);
    assign y = a + b;
endmodule

module RegisterFile (
    input logic clk,
    input logic we,
    input logic [4:0] RAddr1,
    input logic [4:0] RAddr2,
    input logic [4:0] WAddr,
    input logic [31:0] WData,
    output logic [31:0] RData1,
    output logic [31:0] RData2
);
    logic [31:0] Regfile[0:2**5-1];

    initial begin
        for (int i = 0; i <32; i++) begin
            Regfile[i] = 10 + i;
        end    
    end

    always_ff @( posedge clk ) begin : blockName
        if(we) begin
            Regfile[WAddr] <= WData;
        end
    end

    assign RData1 = (RAddr1 != 0) ? Regfile[RAddr1] : 32'b0;
    assign RData2 = (RAddr2 != 0) ? Regfile[RAddr2] : 32'b0;
endmodule