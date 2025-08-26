`timescale 1ns / 1ps

module tb_adder();
    reg a, b, cin;
    wire s,c;
    
    full_adder u_full_adder(.a(a), .b(b), .cin(cin), .s(s), .c(c));
    
    initial begin
        #10;
        a = 0; b = 0; cin = 0;
                
        #10;
        a = 1; b = 0; cin = 0;
        
        #10;
        a = 0; b = 1; cin = 0;
                
        #10;
        a = 1; b = 1; cin = 0;
        
        
        #10;
        a = 0; b = 0; cin = 1;
                
        #10;
        a = 1; b = 0; cin = 1;
        
        #10;
        a = 0; b = 1; cin = 1;
                
        #10;
        a = 1; b = 1; cin = 1;
        
        #10;
        $finish();
    end
endmodule
