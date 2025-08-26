`timescale 1ns / 1ps

module uart_cu(
    input [7:0] i_data,
    output [6:0] o_data
    );
    
    reg [6:0] r_data;
    
    assign o_data = r_data;

    always @(*) begin
        case (i_data)
            8'h72: r_data = 7'b000_0001; // r -> 0x72
            8'h63: r_data = 7'b000_0010; // c -> 0x63
            8'h68: r_data = 7'b000_0100; // h -> 0x68
            8'h6d: r_data = 7'b000_1000;// m -> 0x6D
            8'h73: r_data = 7'b001_0000; // s -> 0x73
            8'h75: r_data = 7'b010_0000; // u -> 0x75
            default: r_data = 0;
        endcase
    end
endmodule
