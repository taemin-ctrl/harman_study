`timescale 1ns / 1ps

module fnd_controller(
    input [3:0] bcd,
    input [1:0] seg_sel,
    output [7:0] seg,
    output [3:0] seg_comm
    );

    decoder decoder_uut(
        .seg_sel(seg_sel), .seg_comm(seg_comm)
    );
    bcdtoseg u_b2s(
        .bcd(bcd), .seg(seg)
    );

endmodule

module decoder (
    input [1:0] seg_sel,
    output reg [3:0] seg_comm
);
    always @(*) begin
        case (seg_sel)
            2'b00: seg_comm = 4'b1110;
            2'b01: seg_comm = 4'b1101;
            2'b10: seg_comm = 4'b1011;
            2'b11: seg_comm = 4'b0111;
            default: seg_comm = 4'b1110;
        endcase
    end
    
endmodule

module bcdtoseg (
    input [3:0] bcd,
    output reg [7:0] seg
);
    always @(bcd) begin
        case (bcd)
            4'h0: seg =  8'hc0;
            4'h1: seg =  8'hf9;
            4'h2: seg =  8'ha4;
            4'h3: seg =  8'hb0;
            4'h4: seg =  8'h99;
            4'h5: seg =  8'h92;
            4'h6: seg =  8'h82;
            4'h7: seg =  8'hf8;
            4'h8: seg =  8'h80;
            4'h9: seg =  8'h90;
            4'ha: seg =  8'h88;
            4'hb: seg =  8'h83;
            4'hc: seg =  8'hc6;    
            4'hd: seg =  8'ha1;
            4'he: seg =  8'h86;
            4'hf: seg =  8'h8e;
            default: seg = 8'hff;
        endcase
    end
endmodule