`timescale 1ns/1ps
module TB;
  reg clk, rst_n, x;
  wire z;
  
  seq_dector_1010 sd(clk, rst_n, x, z);
  initial clk = 0;   
  always #5 clk = ~clk;
    
  initial begin
    x = 0;
    #10 rst_n = 0;
    #10 rst_n = 1;
    
    #10 x = 1;
    #10 x = 1;
    #10 x = 0;
    #10 x = 1;
    #10 x = 0;
    #10 x = 1;
    #10 x = 0;
    #10 x = 1;
    #10 x = 1;
    #10 x = 1;
    #10 x = 0;
    #10 x = 1;
    #10 x = 0;
    #10 x = 1;
    #10 x = 0;
    #10;
    $finish;
  end

endmodule
