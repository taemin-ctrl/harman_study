`timescale 1ns / 1ps

module AXI4_Lite_SPI(
    // Global signals
    input wire ACLK,
    input wire ARESETn,
    // WRITE Transaction, AW Channel
    input wire [3:0] AWADDR,
    input wire AWVALID,
    output reg AWREADY,
    // WRITE Transaction, W Channel
    input wire [31:0] WDATA,
    input wire WVALID,
    output reg WREADY,
    // WRITE Transaction, B Channel
    output reg [1:0] BRESP,
    output reg BVALID,
    input wire BREADY,

    // READ Transaction, AR Channel
    input wire [3:0] ARADDR,
    input wire ARVALID,
    output reg ARREADY,

    // READ Transaction, R Channel
    output reg [31:0] RDATA,
    output reg RVALID,
    input wire RREADY,
    input wire RRESP,

    // SPI
    output SCLK,
    output MOSI,
    input MISO
    );

    // external 
    wire [2:0] cr;
    wire [7:0] sod;
    wire [7:0] sid;
    wire [1:0] sr;

    AXI4_LITE_Intf U_AXI(
    // Global signals
        .ACLK(ACLK),
        .ARESETn(ARESETn),
    // WRITE Transaction, AW Channel
        .AWADDR(AWADDR),
        .AWVALID(AWVALID),
        .AWREADY(AWREADY),
    // WRITE Transaction, W Channel
        .WDATA(WDATA),
        .WVALID(WVALID),
        .WREADY(WREADY),
    // WRITE Transaction, B Channel
        .BRESP(BRESP),
        .BVALID(BVALID),
        .BREADY(BREADY),

    // READ Transaction, AR Channel
        .ARADDR(ARADDR),
        .ARVALID(ARVALID),
        .ARREADY(ARREADY),

    // READ Transaction, R Channel
        .RDATA(RDATA),
        .RVALID(RVALID),
        .RREADY(RREADY),
        .RRESP(RRESP),

    // external 
        .cr(cr),
        .sod(sod),
        .sid(sid),
        .sr(sr)
    );

    /*SPI_Master(
    // global signals
        .clk(ACLK),
        .reset(ARESETn),
        .cpol(cr[2]),
        .cpha(cr[1]),
        .start(cr[0]),
        .tx_data(sod),
        .rx_data(sid),
        .done(sr[1]),
        .ready(sr[0]),
    // external port
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO)
    );*/
endmodule

module AXI4_LITE_Intf (
    // Global signals
    input wire ACLK,
    input wire ARESETn,
    // WRITE Transaction, AW Channel
    input wire [3:0] AWADDR,
    input wire AWVALID,
    output reg AWREADY,
    // WRITE Transaction, W Channel
    input wire [31:0] WDATA,
    input wire WVALID,
    output reg WREADY,
    // WRITE Transaction, B Channel
    output reg [1:0] BRESP,
    output reg BVALID,
    input wire BREADY,

    // READ Transaction, AR Channel
    input wire [3:0] ARADDR,
    input wire ARVALID,
    output reg ARREADY,

    // READ Transaction, R Channel
    output reg [31:0] RDATA,
    output reg RVALID,
    input wire RREADY,
    input wire RRESP,

    // external 
    output [2:0] cr,
    output [7:0] sod,
    input [7:0] sid,
    input [1:0] sr

);
    reg [31:0] slv_reg0_reg, slv_reg1_reg;//, slv_reg2_reg, slv_reg3_reg;
    reg [31:0] slv_reg0_next, slv_reg1_next;//, slv_reg2_next, slv_reg3_next;
    reg [31:0] aw_addr_reg, aw_addr_next;
    localparam AW_IDLE_S = 0, AW_READY_S = 1;
    reg [1:0] aw_state, aw_state_next;

    assign cr = slv_reg0_reg[2:0];
    assign sod = slv_reg1_reg[7:0];  

    always @( posedge ACLK ) begin 
        if (!ARESETn) begin
            aw_state <= AW_IDLE_S;
            aw_addr_reg <= 0;
        end
        else begin
            aw_state <= aw_state_next;
            aw_addr_reg <= aw_addr_next; 
        end
    end

    always @(*) begin 
        aw_state_next = aw_state;
        AWREADY = 1'b0;
        aw_addr_next = aw_addr_reg;
        case (aw_state)
            AW_IDLE_S: begin
                AWREADY = 1'b0;
                if (AWVALID) begin
                    aw_state_next = AW_READY_S;
                    aw_addr_next = AWADDR;
                end
            end 
            AW_READY_S: begin
                AWREADY = 1'b1;
                if (AWVALID && AWREADY) begin
                    aw_state_next = AW_IDLE_S;
                end
            end 
        endcase
    end

    // WRITE Transaction, W Channel transfer
    localparam W_IDLE_S = 0, W_READY_S = 1; 

    reg w_state, w_state_next;

    always @( posedge ACLK ) begin 
        if (!ARESETn) begin
            w_state <= W_IDLE_S;
            slv_reg0_reg <= 0;
            slv_reg1_reg <= 0;
            //slv_reg2_reg <= 0;
            //slv_reg3_reg <= 0;
        end
        else begin
            w_state <= w_state_next;
            slv_reg0_reg <= slv_reg0_next;
            slv_reg1_reg <= slv_reg1_next;
            //slv_reg2_reg <= slv_reg2_next;
            //slv_reg3_reg <= slv_reg3_next;
        end
        
    end

    always @(*) begin 
        slv_reg0_next = slv_reg0_reg;
        slv_reg1_next = slv_reg1_reg;
        //slv_reg2_next = slv_reg2_reg;
        //slv_reg3_next = slv_reg3_reg;
        w_state_next = w_state;
        WREADY = 1'b0;
        case (w_state)
            W_IDLE_S: begin
                WREADY = 1'b0;
                if (AWVALID) begin
                    w_state_next = W_READY_S;
                end
            end 
            W_READY_S: begin
                WREADY = 1'b1;
                if (WVALID) begin
                    w_state_next = W_IDLE_S;
                    case (aw_addr_reg[3:2])
                        2'b00: slv_reg0_next = WDATA;
                        2'b01: slv_reg1_next = WDATA;
                        //2'b10: slv_reg2_next = WDATA;
                        //2'b11: slv_reg3_next = WDATA; 
                    endcase
                end
            end 
        endcase
    end

    // WRITE Transaction, B Channel transfer

    localparam B_IDLE_S = 0, B_VALID_S = 1; 

    reg b_state, b_state_next;

    always @( posedge ACLK ) begin 
        if (!ARESETn) begin
            b_state <= B_IDLE_S;
        end
        else begin
            b_state <= b_state_next;
        end
    end

    always @(*) begin 
        b_state_next = b_state;
        BRESP = 2'b00;
        BVALID = 1'b0;
        case (b_state)
            B_IDLE_S: begin
                BVALID = 1'b0;
                if (WVALID && WREADY) begin
                    b_state_next = B_VALID_S;
                end
            end 
            B_VALID_S: begin
                BRESP = 2'b00; // ok
                BVALID = 1'b1;
                if (BREADY) begin
                    b_state_next = B_IDLE_S;
                end
            end 
        endcase
    end

    // READ Transaction, AR Channel transfer
    reg [3:0] ar_addr_reg, ar_addr_next;

    localparam AR_IDLE_S = 0, AR_READY_S = 1; 

    reg ar_state, ar_state_next;

    always @( posedge ACLK ) begin 
        if (!ARESETn) begin
            ar_state <= AR_IDLE_S;
            ar_addr_reg <= 0;
        end
        else begin
            ar_state <= ar_state_next;
            ar_addr_reg <= ar_addr_next; 
        end
    end

    always @(*) begin 
        ar_state_next = ar_state;
        ARREADY = 1'b0;
        ar_addr_next = ar_addr_reg;
        case (ar_state)
            AR_IDLE_S: begin
                ARREADY = 1'b0;
                if (ARVALID) begin
                    ar_state_next = AR_READY_S;
                    ar_addr_next = ARADDR;
                end
            end 
            AR_READY_S: begin
                ARREADY = 1'b1;
                ar_state_next = AR_IDLE_S;
            end 
        endcase
    end

    // READ Transaction, R Channel transfer
    reg [31:0] rdata_next, rdata_reg;

    localparam R_IDLE_S = 0, R_VALID_S = 1; 

    reg r_state, r_state_next;

    always @( posedge ACLK ) begin 
        if (!ARESETn) begin
            r_state <= R_IDLE_S;
            rdata_reg <= 0;
        end
        else begin
            r_state <= r_state_next;
            rdata_reg <= rdata_next;
        end
    end

    always @(*) begin 
        r_state_next = r_state;
        rdata_next = rdata_reg;
        RVALID = 1'b0;
        RDATA = rdata_reg;
        case (r_state)
            R_IDLE_S: begin
                RVALID = 1'b0;
                if (ARVALID && ARREADY) begin
                    r_state_next = R_VALID_S;
                end
            end
            R_VALID_S: begin
                case (ar_addr_reg[3:2])
                    2'b00: rdata_next = slv_reg0_reg;
                    2'b01: rdata_next = slv_reg1_reg;
                    2'b10: rdata_next = sid;
                    2'b11: rdata_next = sr;
                endcase
                RVALID = 1'b1;
                if (RREADY) begin
                    r_state_next = R_IDLE_S;
                end
            end
        endcase
    end
endmodule

module SPI_Master(
    // global signals
    input        clk,
    input        reset,
    
    input        cpol,
    input        cpha,
    input        start,
    input  [7:0] tx_data,
    output [7:0] rx_data,
    output reg   done,
    output reg   ready,
    // external port
    output SCLK,
    output MOSI,
    input MISO
    );

    localparam IDLE = 0, CP_DELAY = 1, CP0 = 2, CP1 = 3;

    wire r_sclk;
    reg [1:0] state, state_next;
    reg [7:0] temp_tx_data_next, temp_tx_data_reg;
    reg [5:0] sclk_counter_next, sclk_counter_reg;
    reg [2:0] bit_counter_next, bit_counter_reg;
    reg [7:0] temp_rx_data_next, temp_rx_data_reg;

    assign MOSI = temp_tx_data_reg[7];
    assign rx_data = temp_rx_data_reg;
    
    assign r_sclk = ((state_next == CP1) && ~cpha) || ((state_next == CP0) && cpha); 
    assign SCLK = cpol ? ~r_sclk: r_sclk;

    always @(posedge clk, posedge reset) begin
        if (!reset) begin
            state <= IDLE;
            sclk_counter_reg <= 0;
            bit_counter_reg <= 0;
            temp_rx_data_reg <= 0;
            temp_tx_data_reg <= 0;
        end
        else begin
            state <= state_next;
            sclk_counter_reg <= sclk_counter_next;
            bit_counter_reg <= bit_counter_next;
            temp_rx_data_reg <= temp_rx_data_next;
            temp_tx_data_reg <= temp_tx_data_next;
        end
    end

    always @(*) begin
        state_next = state;
        done = 0;
        ready = 0;
        //r_sclk = 0;
        temp_tx_data_next = temp_tx_data_reg;
        temp_rx_data_next = temp_rx_data_reg;
        sclk_counter_next = sclk_counter_reg;
        bit_counter_next = bit_counter_reg;
        case (state)
            IDLE: begin
                temp_tx_data_next = 0;
                done = 0;
                ready = 1;
                if (start) begin
                    state_next = cpha ? CP_DELAY : CP0;
                    temp_tx_data_next = tx_data;
                    ready = 0;
                    sclk_counter_next = 0;
                    bit_counter_next = 0;
                end
            end
            CP_DELAY: begin
                if (sclk_counter_reg == 49) begin
                    sclk_counter_next = 0;
                    state_next = CP0;
                end
                else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end 
            CP0: begin
                //r_sclk = 0;
                if (sclk_counter_reg == 49) begin
                    temp_rx_data_next = {temp_rx_data_reg[6:0], MISO};
                    sclk_counter_next = 0;
                    state_next = CP1;
                end
                else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end
            CP1: begin
                //r_sclk = 1;
                if (sclk_counter_reg == 49) begin
                    if (bit_counter_reg == 7) begin
                        done = 1;
                        state_next = IDLE;
                    end
                    else begin
                        temp_tx_data_next = {temp_tx_data_reg[6:0], 1'b0};
                        sclk_counter_next = 0;
                        state_next = CP0;
                        bit_counter_next = bit_counter_reg + 1;
                    end
                end
                else begin
                    sclk_counter_next = sclk_counter_reg + 1;
                end
            end 
        endcase
    end
endmodule
