`timescale 1ns / 1ps
module fifo_Periph (
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
    output logic        PREADY
    // inport signals
);
    logic       full;
    logic       wr_en;
    // read side
    logic       empty;
    logic       rd_en;

    logic [1:0] fsr;
    logic [7:0] fwd;
    logic [7:0] frd;

    always_ff @( posedge PCLK, posedge PRESET ) begin : blockName
        if (PRESET) begin
            wr_en <= 0;
            rd_en <= 0;
        end
        else begin
            wr_en <= PSEL & PWRITE & PENABLE;
            rd_en <= (PADDR == 4'h8) & PSEL & (!PWRITE) & PENABLE;
        end
    end

    assign fsr[0] = empty;
    assign fsr[1] = full;

    APB_SlaveIntf_Fifo U_APB_IntfO (.*);
    //GPIO U_GPIO_IP (.*);
    fifo u_fifo(.*);
endmodule

module APB_SlaveIntf_Fifo (
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
    output logic [1:0] fsr,
    output logic [7:0] fwd,
    output logic [7:0] frd
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2;//, slv_reg3;

    //assign fsr = slv_reg0[1:0];
    assign fwd = slv_reg1[7:0];
    //assign frd = slv_reg2[7:0];
    always_comb begin 
        slv_reg0[1:0] = fsr;
        slv_reg2[7:0] = frd;
    end

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
                    //slv_reg2[7:0] <= frd; 
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

module fifo(
    input  logic       PCLK,
    input  logic       PRESET,
    // write side
    input  logic [7:0] fwd,
    input  logic       wr_en,
    output logic       full,
    // read side
    output  logic [7:0] frd,
    input  logic       rd_en,
    output logic       empty
    );

    logic [1:0] wr_ptr, rd_ptr;

    fifo_ram U_RAM(
        .clk(PCLK),
        .wAddr(wr_ptr),
        .wdata(fwd),
        .wr_en(wr_en & ~full),
        .rAddr(rd_ptr),
        .rdata(frd)
    );

    fifo_control_unit U_FIFO_ControlUnit(
        .clk(PCLK),
        .reset(PRESET),
        // write side
        .wr_ptr(wr_ptr),
        .wr_en(wr_en),
        .full(full),
        // read side
        .rd_ptr(rd_ptr),
        .rd_en(rd_en),
        .empty(empty)
    );
endmodule

module fifo_ram (
    input logic clk,
    input logic [1:0] wAddr,
    input logic [7:0] wdata,
    input logic       wr_en,
    input logic [1:0] rAddr,
    output logic [7:0] rdata
);
    logic [7:0] mem [0:2**2-1];

    always_ff @( posedge clk ) begin 
        if (wr_en) begin
            mem[wAddr] <= wdata;
        end
    end

    assign rdata = mem[rAddr];
endmodule

module fifo_control_unit (
    input  logic       clk,
    input  logic       reset,
    // write side
    output logic [1:0] wr_ptr,
    input  logic       wr_en,
    output logic       full,
    // read side
    output logic [1:0] rd_ptr,
    input  logic       rd_en,
    output logic       empty
);
    localparam READ = 2'b01, WRITE = 2'b10, READ_WRITE = 2'b11;
    logic [1:0] wr_ptr_next, wr_ptr_reg, rd_ptr_reg, rd_ptr_next;
    logic [1:0] fifo_state;
    logic       full_reg, full_next, empty_reg, empty_next;

    assign fifo_state = {wr_en, rd_en};
    assign full   = full_reg;
    assign empty  = empty_reg;
    assign wr_ptr = wr_ptr_reg;
    assign rd_ptr = rd_ptr_reg;

    always_ff @( posedge clk, posedge reset ) begin 
        if (reset) begin
            wr_ptr_reg <= 0;
            rd_ptr_reg <= 0;
            full_reg   <= 1'b0;
            empty_reg  <= 1'b1;
        end
        else begin
            wr_ptr_reg <= wr_ptr_next;
            rd_ptr_reg <= rd_ptr_next;
            full_reg   <= full_next;
            empty_reg  <= empty_next;
        end
    end

    always_comb begin : fifo_comb
        empty_next = empty_reg;
        full_next = full_reg;
        wr_ptr_next = wr_ptr_reg;
        rd_ptr_next = rd_ptr_reg;
        case (fifo_state)
            READ: begin
                if (empty_reg == 1'b0) begin
                    full_next = 1'b0;
                    rd_ptr_next = rd_ptr_reg + 1;
                    if (rd_ptr_next == wr_ptr_reg) begin
                        empty_next = 1'b1;
                    end
                end
            end 
            WRITE: begin
                if (full_reg == 1'b0) begin
                    empty_next = 1'b0;
                    wr_ptr_next = wr_ptr_reg + 1'b1;
                    if (wr_ptr_next == rd_ptr_reg) begin
                        full_next = 1'b1;
                    end
                end
            end
            READ_WRITE: begin
                if (empty_reg == 1'b1) begin
                    wr_ptr_next = wr_ptr_reg + 1;
                    empty_next  = 1'b0;
                end
                else if (full_reg == 1'b1) begin
                    rd_ptr_next = rd_ptr_reg + 1;
                    full_next   = 1'b0;
                end
                else begin
                    wr_ptr_next = wr_ptr_reg + 1;
                    rd_ptr_next = rd_ptr_reg + 1;
                end
            end 
        endcase
    end
endmodule