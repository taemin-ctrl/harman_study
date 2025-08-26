`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/27 15:10:34
// Design Name: 
// Module Name: adder
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
module full_adder(
    input a, b, cin,
    output s, c
);
    wire w_s;
    wire w_c1, w_c2;
    
    half_adder U_HA1(
        .a(a) , .b(b), .s(w_s), .c(w_c1)
    );
    
    half_adder U_HA2(
        .a(w_s) , .b(cin), .s(s), .c(w_c2)
    );
    
    assign c = w_c1 | w_c2;
    //assign s = a ^ b ^ cin;
    //assign c = (a & b) | (b & cin) | (a & cin);
endmodule

module half_adder(
    input a, b,
    output s, c
    );
    assign s = a ^ b;
    assign c = a & b;
endmodule

