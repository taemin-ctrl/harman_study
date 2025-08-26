`timescale 1ns / 1ps

module gates(
    input a, b,
    output y0, y1,y2, y3, y4, y5
    );
    assign y0 = a & b; // and
    assign y1 = a | b; // or
    assign y2 =  ~(a & b); // nand
    assign y3 = a ^ b; // xor
    assign y4 = ~(a | b); // nor 
    assign y5 = ~a; // not
    
endmodule
