`timescale 1ns / 1ps

module fnd_controller(
    input clk,
    input reset,
    output [7:0] seg,
    output [3:0] seg_comm
);
     wire [3:0] w_bcd,w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
     wire [1:0] w_seg_sel;
     wire w_clk_100hz;
     wire [13:0] w_result_count;
    
    bcdtoseg U_bcdtoseg(
        .bcd(w_bcd),
        .seg(seg)
    );

    counter_10000 U_Counter_10000(
    .reset(reset),
    .clk(w_clk_100hz),
    .result_count(w_result_count)

    );

    clk_divider U_Clk_Divider(
    .clk(clk),
    .reset(reset),
    .o_clk(w_clk_100hz)
    );

    counter_4 U_Counter_4(
    .clk(clk),
    .reset(reset),
    .o_sel(w_seg_sel)
    );

    mux_2x4 U_mux_2x4(
        .sel(w_seg_sel),
        .seg_comm(seg_comm)
    );

    digit_splitter U_Digit_Splitter(
        .bcd(w_result_count),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );
    
    mux_4x1 U_Mux_4x1(
    .sel(w_seg_sel),
    .digit_1(w_digit_1),
    .digit_10(w_digit_10),
    .digit_100(w_digit_100),
    .digit_1000(w_digit_1000),
    .bcd(w_bcd)
    );

endmodule

module clk_divider(
input clk,
input reset,
output o_clk
);
    reg [19:0] r_counter;
    reg r_clk;

    assign o_clk = r_clk;
    
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_counter <= 0;
            r_clk <= 1'b0;
            end 
            
            else begin
                
                if((r_counter)==100000 - 1) begin
                    r_counter <= 0;
                    r_clk<= 1'b1; //r_clk : 0-> 1
                 end 
                    
                    else begin
                    r_counter <= r_counter +1;
                    r_clk <= 1'b0; // r_clk : 1->0 r_counter : 0~99998
                    end
              end
       end


endmodule

module counter_10000(
input reset,
input clk,
output [13:0] result_count

);
    reg [13:0] r_counter;
    
    assign result_count = r_counter;

    always @(posedge clk, posedge reset)begin
        if(reset) begin
            r_counter <=0;
        end 
        else begin
        if((r_counter)==10000 - 1) begin
                    r_counter <= 0;
                                    end else begin
                                       r_counter <= r_counter +1;
                                     end
                         end
                         end
                         
                        

endmodule


module counter_4(
    input clk,
    input reset,
    output [1:0] o_sel
);

    reg [1:0] r_counter;
    assign o_sel= r_counter;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_counter <=0;
        end 
        
        else begin
            r_counter <= r_counter + 1;
        end
    end

endmodule

module mux_2x4(
    input [1:0] sel,
    output reg [3:0] seg_comm
);
    always @(sel) begin
        case(sel)
            2'b00: seg_comm = 4'b1110;
            2'b01: seg_comm = 4'b1101;
            2'b10: seg_comm = 4'b1011;
            2'b11: seg_comm = 4'b0111;
            default: seg_comm = 4'b1110;
        endcase
    end
endmodule

module digit_splitter(
    input [13:0] bcd,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);
    assign digit_1 = bcd % 10; 
    assign digit_10 = (bcd / 10) % 10;
    assign digit_100 = (bcd / 100) % 10;
    assign digit_1000 = (bcd / 1000) % 10;
endmodule

module mux_4x1(
    input [1:0] sel,
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    output reg [3:0] bcd
);
    always @(*) begin
        case(sel)
            2'b00: bcd = digit_1;
            2'b01: bcd = digit_10;
            2'b10: bcd = digit_100;
            2'b11: bcd = digit_1000;
            default: bcd = 4'bz;
        endcase
    end
endmodule

module bcdtoseg(
    input [3:0] bcd,
    output reg [7:0] seg
);
    always @(bcd) begin
        case(bcd)
            4'h0: seg = 8'hC0;
            4'h1: seg = 8'hF9;
            4'h2: seg = 8'hA4;
            4'h3: seg = 8'hB0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hF8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            4'hA: seg = 8'h88;
            4'hB: seg = 8'h83;
            4'hC: seg = 8'hC6;
            4'hD: seg = 8'hA1;
            4'hE: seg = 8'h86;
            4'hF: seg = 8'h8E;
            default: seg = 8'hFF;
        endcase
    end
endmodule
