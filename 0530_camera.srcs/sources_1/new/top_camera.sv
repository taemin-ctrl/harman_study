`timescale 1ns / 1ps

module top_camera(
    input logic clk,
    input logic reset
    );
endmodule

module mem_controller (
    input logic clk,
    input logic reset,
    input logic PCLK,
    input logic HREF,
    input logic VSYNC,
    input logic [7:0] data,
    output logic bclk,
    output logic [9:0] waddr,
    output logic [15:0] wdata,
    output logic we
);
    logic [9:0] addr_cnt;
    logic [15:0] temp_data;
    logic cnt;
    always_ff @( posedge PCLK, posedge reset ) begin 
        if (reset) begin
            cnt <= 0;
        end
        else begin
            if (HREF) begin
                if (cnt) begin
                    temp_data[15:0] <= data;
                end
                else begin
                    temp_data[7:0] <= data;
                end
            end
        end
    end

    always_ff @(negedge PCLK, posedge reset)
endmodule