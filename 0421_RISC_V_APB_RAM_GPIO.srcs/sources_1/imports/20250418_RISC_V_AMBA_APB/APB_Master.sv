`timescale 1ns / 1ps

module APB_Master (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    output logic [31:0] PADDR,
    output logic [31:0] PWDATA,
    output logic        PWRITE,
    output logic        PENABLE,
    output logic        PSEL0,
    output logic        PSEL1,
    output logic        PSEL2,
    output logic        PSEL3,
    input  logic [31:0] PRDATA0,
    input  logic [31:0] PRDATA1,
    input  logic [31:0] PRDATA2,
    input  logic [31:0] PRDATA3,
    input  logic        PREADY0,
    input  logic        PREADY1,
    input  logic        PREADY2,
    input  logic        PREADY3,
    // Internal Interface Signals
    input  logic        transfer,  // trigger signal
    output logic        ready,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    input  logic        write      // 1:write, 0:read
);
    logic [31:0] temp_addr_next, temp_addr_reg;
    logic [31:0] temp_wdata_next, temp_wdata_reg;
    logic temp_write_next, temp_write_reg;
    logic decoder_en;
    logic [3:0] pselx;

    assign PSEL0 = pselx[0];
    assign PSEL1 = pselx[1];
    assign PSEL2 = pselx[2];
    assign PSEL3 = pselx[3];

    typedef enum bit [1:0] {
        IDLE,
        SETUP,
        ACCESS
    } apb_state_e;

    apb_state_e state, state_next;

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            state          <= IDLE;
            temp_addr_reg  <= 0;
            temp_wdata_reg <= 0;
            temp_write_reg <= 0;
        end else begin
            state          <= state_next;
            temp_addr_reg  <= temp_addr_next;
            temp_wdata_reg <= temp_wdata_next;
            temp_write_reg <= temp_write_next;
        end
    end

    always_comb begin
        state_next      = state;
        temp_addr_next  = temp_addr_reg;
        temp_wdata_next = temp_wdata_reg;
        temp_write_next = temp_write_reg;
        PADDR           = temp_addr_reg;
        PWDATA          = temp_wdata_reg;
        PWRITE          = 1'b0;
        PENABLE         = 1'b0;
        decoder_en      = 1'b0;
        case (state)
            IDLE: begin
                decoder_en = 1'b0;
                if (transfer) begin
                    state_next      = SETUP;
                    temp_addr_next  = addr;  // latching
                    temp_wdata_next = wdata;
                    temp_write_next = write;
                end
            end
            SETUP: begin
                decoder_en = 1'b1;
                PENABLE    = 1'b0;
                PADDR      = temp_addr_reg;
                if (temp_write_reg) begin
                    PWRITE = 1'b1;
                    PWDATA = temp_wdata_reg;
                end else begin
                    PWRITE = 1'b0;
                end
                state_next = ACCESS;
            end
            ACCESS: begin
                decoder_en = 1'b1;
                PENABLE    = 1'b1;
                PADDR      = temp_addr_reg;
                if (temp_write_reg) begin
                    PWRITE = 1'b1;
                    PWDATA = temp_wdata_reg;
                end else begin
                    PWRITE = 1'b0;
                end
                if (ready) begin
                    state_next = IDLE;
                end
            end
        endcase
    end

    APB_Decoder U_APB_Decoder (
        .en (decoder_en),
        .sel(temp_addr_reg),
        .y  (pselx)
    );

    APB_Mux U_APB_Mux (
        .sel  (temp_addr_reg),
        .d0   (PRDATA0),
        .d1   (PRDATA1),
        .d2   (PRDATA2),
        .d3   (PRDATA3),
        .r0   (PREADY0),
        .r1   (PREADY1),
        .r2   (PREADY2),
        .r3   (PREADY3),
        .rdata(rdata),
        .ready(ready)
    );
endmodule

module APB_Decoder (
    input  logic        en,
    input  logic [31:0] sel,
    output logic [ 3:0] y
);
    always_comb begin
        y = 4'b0;
        if (en) begin
            casex (sel)
                32'h1000_0xxx: y = 4'b0001;
                32'h1000_1xxx: y = 4'b0010;
                32'h1000_2xxx: y = 4'b0100;
                32'h1000_3xxx: y = 4'b1000;
            endcase
        end
    end
endmodule

module APB_Mux (
    input  logic [31:0] sel,
    input  logic [31:0] d0,
    input  logic [31:0] d1,
    input  logic [31:0] d2,
    input  logic [31:0] d3,
    input  logic        r0,
    input  logic        r1,
    input  logic        r2,
    input  logic        r3,
    output logic [31:0] rdata,
    output logic        ready
);

    always_comb begin
        rdata = 32'bx;
        casex (sel)
            32'h1000_0xxx: rdata = d0;
            32'h1000_1xxx: rdata = d1;
            32'h1000_2xxx: rdata = d2;
            32'h1000_3xxx: rdata = d3;
        endcase
    end

    always_comb begin
        ready = 1'b0;
        casex (sel)
            32'h1000_0xxx: ready = r0;
            32'h1000_1xxx: ready = r1;
            32'h1000_2xxx: ready = r2;
            32'h1000_3xxx: ready = r3;
        endcase
    end
endmodule
