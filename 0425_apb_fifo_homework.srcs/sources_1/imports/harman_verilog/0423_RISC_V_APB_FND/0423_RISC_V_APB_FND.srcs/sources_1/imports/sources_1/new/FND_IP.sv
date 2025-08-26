`timescale 1ns / 1ps

/*module FND_IP (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // inport signals
    output logic [ 3:0] fnd_com,
    output logic [ 7:0] seg
);

    logic       en;
    logic [3:0] com;
    logic [3:0] num;

    APB_SlaveIntf_IP U_APB_IntfO (.*);
    //GPIO U_GPIO_IP (.*);
    fnd U_FND(.*);
endmodule

module APB_SlaveIntf_IP (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // internal signals
    output logic en,
    output logic [3:0] num,
    output logic [3:0] com
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2;//, slv_reg3;

    assign en = slv_reg0[0];
    assign num = slv_reg1[3:0];
    assign com = slv_reg2[3:0];

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            // slv_reg3 <= 0;
        end else begin
            if (PSEL && PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[3:2])
                        2'd0: slv_reg0 <= PWDATA;
                        2'd1: slv_reg1 <= PWDATA;
                        2'd2: slv_reg2 <= PWDATA;
                        // 2'd3: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                    PRDATA <= 32'bx;
                    case (PADDR[3:2])
                        2'd0: PRDATA <= slv_reg0;
                        2'd1: PRDATA <= slv_reg1;
                        2'd2: PRDATA <= slv_reg2;
                        // 2'd3: PRDATA <= slv_reg3;
                    endcase
                end
            end else begin
                PREADY <= 1'b0;
            end
        end
    end

endmodule

module GPIO (
    input  logic [7:0] moder,
    output logic [7:0] idr,
    input  logic [7:0] odr,
    inout  logic [7:0] inOutPort
);

    genvar i;
    generate
        for (i = 0; i < 8; i++) begin
            assign inOutPort[i] = moder[i] ? odr[i] : 1'bz; // output
            assign idr[i] = ~moder[i] ? inOutPort[i] : 1'bz; // input
        end
    endgenerate

endmodule

module fnd (
    input logic en,
    input logic [3:0] num,
    input logic [3:0] com,
    output logic [3:0] fnd_com,
    output logic [7:0] seg
);
    assign fnd_com = en ? com : 4'b1111;
    
    always @(*) begin
        case (num)
            4'd0: seg = 8'b1100_0000;  
            4'd1: seg = 8'b1111_1001;
            4'd2: seg = 8'b1010_0100;
            4'd3: seg = 8'b1011_0000;
            4'd4: seg = 8'b1001_1001;
            4'd5: seg = 8'b1001_0010;
            4'd6: seg = 8'b1000_0010;
            4'd7: seg = 8'b1101_1000;
            4'd8: seg = 8'b1000_0000;
            4'd9: seg = 8'b1001_0000;
            default: seg = 8'b1111_1111; 
        endcase
    end
endmodule*/


module FndController_Periph (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // inport signals
    output logic [ 3:0] fndCom,
    output logic [ 6:0] fndFont,
    output logic        dot
);

    logic       fcr;
    logic [13:0] fdr;
    logic  [3:0] fpr;

    APB_SlaveIntf_FndDontroller U_APB_IntfO (.*);
    //GPIO U_GPIO_IP (.*);
    fnd_controller U_fnd_controller(.*);
endmodule

module APB_SlaveIntf_FndDontroller (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // internal signals
    output logic fcr,
    output logic [13:0] fdr,
    output logic [3:0] fpr
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2;//, slv_reg3;

    assign fcr = slv_reg0[0];
    assign fdr = slv_reg1[13:0];
    assign fpr = slv_reg2[3:0];

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            // slv_reg3 <= 0;
        end else begin
            if (PSEL && PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[3:2])
                        2'd0: slv_reg0 <= PWDATA;
                        2'd1: slv_reg1 <= PWDATA;
                        2'd2: slv_reg2 <= PWDATA;
                        // 2'd3: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                    PRDATA <= 32'bx;
                    case (PADDR[3:2])
                        2'd0: PRDATA <= slv_reg0;
                        2'd1: PRDATA <= slv_reg1;
                        2'd2: PRDATA <= slv_reg2;
                        // 2'd3: PRDATA <= slv_reg3;
                    endcase
                end
            end else begin
                PREADY <= 1'b0;
            end
        end
    end

endmodule

module fnd_controller (
    input logic PCLK,
    input logic PRESET,
    input logic fcr,
    input logic [13:0] fdr,
    input logic [3:0] fpr,
    output logic [6:0] fndFont,
    output logic [3:0] fndCom,
    output logic dot
);

    wire [3:0] w_bcd, w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [1:0] w_seg_sel;
    wire cnt;

    wire w_clk_100hz;
    clk_divider U_Clk_Divider (
        .clk(PCLK),
        .reset(PRESET),
        .o_clk(w_clk_100hz)
    );
    counter_4 U_Counter_4 (
        .clk  (w_clk_100hz),
        .reset(PRESET),
        .o_sel(w_seg_sel)
    );


    decoder_2x4 U_decoder_2x4 (
        .seg_sel (w_seg_sel),
        .fcr(fcr),
        .seg_comm(fndCom)
    );


    digit_splitter U_Digit_Splitter (
        .bcd(fdr),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );


    mux_4x1 U_Mux_4x1 (
        .sel(w_seg_sel),
        .fpr(fpr),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000),
        .bcd(w_bcd),
        .sig(sig)
    );

    counter U_CNT(
        .clk(w_clk_100hz),
        .reset(PRESET),
        .cnt(cnt)
);
    bcdtoseg U_bcdtoseg (
        .bcd(w_bcd),  // [3:0] sum 값
        .cnt(cnt),
        .sig(sig), 
        .fndFont(fndFont),
        .dot(dot)
    );

endmodule

module clk_divider (
    input logic clk,
    input logic reset,
    output logic o_clk
);
    parameter FCOUNT = 500_000 ;// 이름을 상수화하여 사용.
    // $clog2 : 수를 나타내는데 필요한 비트수 계산
    reg [$clog2(FCOUNT)-1:0] r_counter;
    reg r_clk;
    assign o_clk = r_clk;

    always @(posedge clk, posedge reset) begin
        if (reset ) begin  // 
            r_counter <= 0;  // 리셋상태
            r_clk <= 1'b0;
        end else begin
            // clock divide 계산, 100Mhz -> 200hz
            if (r_counter == FCOUNT - 1) begin
                r_counter <= 0;
                r_clk <= 1'b1;  // r_clk : 0->1
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;  // r_clk : 0으로 유지.;
            end
        end
    end

endmodule

module counter_4 (
    input        clk,
    input        reset,
    output [1:0] o_sel
);

    reg [1:0] r_counter;
    assign o_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end


endmodule

module decoder_2x4 (
    input [1:0] seg_sel,
    input fcr,
    output reg [3:0] seg_comm
);

    // 2x4 decoder
    always @(*) begin
        case (seg_sel)
            2'b00:   seg_comm = fcr ? 4'b1110 : 4'b1111;
            2'b01:   seg_comm = fcr ? 4'b1101 : 4'b1111;
            2'b10:   seg_comm = fcr ? 4'b1011 : 4'b1111;
            2'b11:   seg_comm = fcr ? 4'b0111 : 4'b1111;
            default: seg_comm = 4'b1111;
        endcase
    end

endmodule

module digit_splitter (
    input  [13:0] bcd,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);
    assign digit_1 = bcd % 10;  // 10의 1의 자리
    assign digit_10 = bcd / 10 % 10;  // 10의 10의 자리
    assign digit_100 = bcd / 100 % 10;  // 10의 100의 자리
    assign digit_1000 = bcd / 1000 % 10;  // 10의 1000의 자리

endmodule

module mux_4x1 (
    input  [1:0] sel,
    input  [3:0] fpr,
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    output [3:0] bcd,
    output logic sig
);
    reg [3:0] r_bcd;
    assign bcd = r_bcd;
    // * : input 모두 감시, 아니면 개별 입력 선택 할 수 있다.
    // alwasys : 항상 감시한다 @이벤트 이하를 ()의 변화가 있으면, begin - end를 수행해라.
    always @(*) begin
        case (sel)
            2'b00:   begin
                r_bcd = digit_1;
                if (fpr[0]) begin
                    sig = 1'b1;
                end
                else begin
                    sig = 1'b0;
                end
            end
            2'b01: begin  
                r_bcd = digit_10;
                if (fpr[1]) begin
                    sig = 1'b1;
                end
                else begin
                    sig = 1'b0;
                end
            end
            2'b10: begin  
                r_bcd = digit_100;
                if (fpr[2]) begin
                    sig = 1'b1;
                end
                else begin
                    sig = 1'b0;
                end
            end
            2'b11:  begin 
                r_bcd = digit_1000;
                if (fpr[3]) begin
                    sig = 1'b1;
                end
                else begin
                    sig = 1'b0;
                end
            end
            default: begin
                r_bcd = 4'bx;
                sig = 1'b0;
            end
        endcase
    end

endmodule

module bcdtoseg (
    input logic [3:0] bcd,  // [3:0] sum 값 
    input logic cnt,
    input logic sig,
    output logic [6:0] fndFont,
    output logic dot
);
    // always 구문 출력으로 reg type을 가져야 한다.
    assign dot = ~(sig&cnt);
    always_comb begin
        case (bcd)
            4'd0: fndFont = 7'b100_0000;  
            4'd1: fndFont = 7'b111_1001;
            4'd2: fndFont = 7'b010_0100;
            4'd3: fndFont = 7'b011_0000;
            4'd4: fndFont = 7'b001_1001;
            4'd5: fndFont = 7'b001_0010;
            4'd6: fndFont = 7'b000_0010;
            4'd7: fndFont = 7'b101_1000;
            4'd8: fndFont = 7'b000_0000;
            4'd9: fndFont = 7'b001_0000;
            default: fndFont = 7'b111_1111; 
        endcase
    end

    /*typedef enum logic [6:0] {
    ZERO = 7'b100_0000,  // 숫자 0
    ONE  = 7'b111_1001,  // 숫자 1
    TWO  = 7'b010_0100,  // 숫자 2
    THREE = 7'b011_0000, // 숫자 3
    FOUR = 7'b001_1001,  // 숫자 4
    FIVE = 7'b001_0010,  // 숫자 5
    SIX  = 7'b000_0010,  // 숫자 6
    SEVEN = 7'b101_1000, // 숫자 7
    EIGHT = 7'b000_0000, // 숫자 8
    NINE = 7'b001_0000   // 숫자 9
} k;

// fndFont 값 설정
always_comb begin
    case (bcd)
        4'd0: fndFont = ZERO;  
        4'd1: fndFont = ONE;
        4'd2: fndFont = TWO;
        4'd3: fndFont = THREE;
        4'd4: fndFont = FOUR;
        4'd5: fndFont = FIVE;
        4'd6: fndFont = SIX;
        4'd7: fndFont = SEVEN;
        4'd8: fndFont = EIGHT;
        4'd9: fndFont = NINE;
        default: fndFont = 7'b111_1111;  // 오류 처리
    endcase
end*/
endmodule

module counter (
    input logic clk,
    input logic reset,
    output logic cnt
);
    logic [$clog2(100)-1:0] r;
    always_ff @( posedge clk, posedge reset ) begin 
        if (reset) begin
            r <= 0;
            cnt <= 1'b0;
        end
        else begin
            if (r == 99) begin
                cnt <= ~cnt;
                r <= 0;
            end
            else begin
                r <= r + 1'b1;
            end
        end
    end
endmodule
