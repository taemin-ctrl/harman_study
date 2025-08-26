`timescale 1ns / 1ps

module uart_cu(
    input [7:0] i_data,
    output [4:0] o_data
    );
    
    reg [4:0] r_data;
    
    assign o_data = r_data;

    always @(*) begin
        case (i_data)
            8'h72: r_data= 5'b00001; // r -> 0x72
            8'h63: r_data= 7'b00010; // c -> 0x63
            8'h68: r_data= 7'b00100; // h -> 0x68
            8'h6d: r_data= 7'b01000;// m -> 0x6D
            8'h73: r_data= 7'b10000; // s -> 0x73
            default: r_data = 0;
        endcase
    end
endmodule
