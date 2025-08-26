`timescale 1ns / 1ps

module ram(
    input logic clk,
    input logic we,
    input logic [31:0] addr,
    input logic [31:0] WData,
    output logic [31:0] rData
    );

    logic [31:0] mem[0:9];

    always_ff @( posedge clk ) begin : blockName
        if (we) begin
            mem[addr[31:2]] <= WData;
        end
    end

    assign rData = mem[addr[31:2]];

endmodule
