`timescale 1ns / 1ps
module calculator (
    input clk, reset,
    input [7:0] a, b,
    output [7:0] seg,
    output [3:0] seg_comm
);
    wire [7:0] w_sum;
    wire w_carry;

    adder8 adder_dut(
        .a(a), .b(b), .sum(w_sum), .carry(w_carry)
    );


    fnd_controller fnd_controller_uut(
        .clk(clk), .reset(reset), .bcd({w_carry,w_sum}), .seg(seg), .seg_comm(seg_comm)
    );

endmodule

module adder8 (
    input [7:0] a,
    input [7:0] b,
    input cin,
    output [7:0] sum,
    output carry
);
    wire w_carry;

    adder a_up(
        .a(a[7:4]), .b(b[7:4]), .cin(0), .s(sum[7:4]), .c(w_carry)  // carry는 w_carry로 전달됨
    );

    adder a_lo(
        .a(a[3:0]), .b(b[3:0]), .cin(w_carry), .s(sum[3:0]), .c(carry)  // carry는 최종 출력 carry로 전달됨
    );
endmodule

module adder(
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [3:0] s,
    output c
    );
    
    wire [3:0] w_c;

    full_adder u_fa1(
        .a(a[0]), .b(b[0]), .cin(1'b0), .sum(s[0]), .c(w_c[0])    
    );

    full_adder u_fa2(
        .a(a[1]), .b(b[1]), .cin(w_c[0]), .sum(s[1]), .c(w_c[1])    
    );

    full_adder u_fa3(
        .a(a[2]), .b(b[2]), .cin(w_c[1]), .sum(s[2]), .c(w_c[2])    
    );

    full_adder u_fa4(
        .a(a[3]), .b(b[3]), .cin(w_c[2]), .sum(s[3]), .c(c)    
    );
endmodule

module full_adder (
    input a, b, cin,
    output sum, c 
);
    wire w_s, w_c1, w_c2;

    half_adder u_ha1(
        .a(a), .b(b), .sum(w_s), .c(w_c1) 
    );

    half_adder u_ha2(
        .a(w_s), .b(cin), .sum(sum), .c(w_c2) 
    );
    assign c = w_c1 | w_c2;
endmodule

module half_adder(
    input a, b,
    output sum, c
);
    
    assign sum = a ^ b;
    assign c = a & b;

    //xor(sum, a, b);
    //and(c, a, b); 
endmodule
