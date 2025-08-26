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
    output logic [ 7:0] fndFont
);

    logic       fcr;
    logic [3:0] fmr;
    logic [3:0] fdr;

    APB_SlaveIntf_FndDontroller U_APB_IntfO (.*);
    //GPIO U_GPIO_IP (.*);
    FndController U_FND(.*);
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
    output logic [7:0] fcr,
    output logic [7:0] fmr,
    output logic [7:0] fdr
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2;//, slv_reg3;

    assign fcr = slv_reg0[0];
    assign fmr = slv_reg1[3:0];
    assign fdr = slv_reg2[3:0];

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

module FndController (
    input logic fcr,
    input logic [3:0] fmr,
    input logic [3:0] fdr,
    output logic [3:0] fndCom,
    output logic [7:0] fndFont
);
    assign fndCom = fcr ? ~fmr : 4'b1111;
    
    always_comb begin
        case (fdr)
            4'd0: fndFont = 8'b1100_0000;  
            4'd1: fndFont = 8'b1111_1001;
            4'd2: fndFont = 8'b1010_0100;
            4'd3: fndFont = 8'b1011_0000;
            4'd4: fndFont = 8'b1001_1001;
            4'd5: fndFont = 8'b1001_0010;
            4'd6: fndFont = 8'b1000_0010;
            4'd7: fndFont = 8'b1101_1000;
            4'd8: fndFont = 8'b1000_0000;
            4'd9: fndFont = 8'b1001_0000;
            default: fndFont = 8'b1111_1111; 
        endcase
    end
endmodule
