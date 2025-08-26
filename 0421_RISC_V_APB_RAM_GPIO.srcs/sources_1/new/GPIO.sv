`timescale 1ns / 1ps

module GPIO_Periph (
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
    // export signals
    inout logic [7:0] Port
);
    logic [7:0] moder;
    logic [7:0] idr;
    logic [7:0] odr;

    APB_SlaveInf_GPIO U_APB_Intf(
        .*
    );

    GPIO U_GPI_IP(
        .*    
    );

endmodule

module APB_SlaveInf_GPIO (
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
    output logic [7:0] moder,
    input logic [7:0] idr,
    output logic [7:0] odr
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2;//, slv_reg3;

    assign moder = slv_reg0[7:0];
    assign odr   = slv_reg1[7:0];

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            //slv_reg3 <= 0;
        end else begin
            slv_reg2[7:0] <= idr;
            if (PSEL && PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[3:2])
                        2'd0: slv_reg0 <= PWDATA;
                        2'd1: slv_reg1 <= PWDATA;
                        2'd2: slv_reg2 <= PWDATA;
                        //2'd3: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                    PRDATA <= 32'bx;
                    case (PADDR[3:2])
                        2'd0: PRDATA <= slv_reg0;
                        2'd1: PRDATA <= slv_reg1;
                        2'd2: PRDATA <= slv_reg2;
                        //2'd3: PRDATA <= slv_reg3;
                    endcase
                end
            end else begin
                PREADY <= 1'b0;
            end
        end
    end

endmodule

module GPIO(
    input logic  [7:0] moder,
    input logic        PWRITE,
    output logic  [7:0] idr,
    input logic  [7:0] odr,
    inout logic   [7:0] Port
    );

    logic  [7:0] outPort;
    
    genvar i;
    generate
        for (i = 0; i<8; i= i + 1 ) begin
            assign idr[i] = ~moder[i] ? Port[i] : 1'bz;        
        end
    endgenerate

    genvar j;
    generate
        for (j = 0; j<8; j= j + 1 ) begin
            assign outPort[j] = moder[j] ? odr[j] : 1'bz;        
        end
    endgenerate

    assign Port = PWRITE ? outPort : 8'bz;

endmodule

