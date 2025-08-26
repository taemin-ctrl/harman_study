`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/10 10:52:14
// Design Name: 
// Module Name: seq_dector_1010
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


module seq_dector_1010(
    input clk,
    input rst_n,
    input x,
    output z
    );

    parameter A = 4'h1;
  parameter B = 4'h2;
  parameter C = 4'h3;
  parameter D = 4'h4;
  
  reg [3:0] state, next_state;
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin 
      state <= A;
    end
    else state <= next_state;
  end
  
  always @(state or x) begin
    case(state)
      A: begin
           if(x == 0) next_state = A;
           else       next_state = B;
         end
      B: begin
           if(x == 0) next_state = C;
           else       next_state = B;
         end
      C: begin
           if(x == 0) next_state = A;
           else       next_state = D;
         end
      D: begin
        if(x == 0) next_state = A; //This state only differs when compared with Mealy Overlaping Machine
           else       next_state = B;
         end
      default: next_state = A;
    endcase
  end
  assign z = (state == D) && (x == 0)? 1:0;
endmodule