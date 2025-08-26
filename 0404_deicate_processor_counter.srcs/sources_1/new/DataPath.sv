`timescale 1ns / 1ps

module DataPath(
    input logic clk,
    input logic reset,
    input logic ASrMuxSel,
    input logic AEn,
    output logic ALt10,
    input logic OutBuf,
    output logic [7:0] outPort
    );
    
    register u_reg(
        .clk(clk),
        .reset(reset),
        .en(),
        .d(),
        .q()
    );

    

endmodule

module register (
    input logic clk,
    input logic reset,
    input logic en,
    input logic [7:0] d,
    output logic [7:0] q
);
    always_ff @(posedge clk, posedge reset) begin
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

module adder (
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] sum
);
    assign sum = a + b;
endmodule

module comparator (
    input logic [7:0] a,
    input logic [7:0] b,
    output logic lt
);
    assign lt = a < b;
endmodule