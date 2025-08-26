`timescale 1ns / 1ps

module AXI4_Lite_Slave(
    // Global signals
    input logic ACLK,
    input logic ARESETn,
    // WRITE Transaction, AW Channel
    input logic [3:0] AWADDR,
    input logic AWVALID,
    output logic AWREADY,
    // WRITE Transaction, W Channel
    input logic [31:0] WDATA,
    input logic WVALID,
    output logic WREADY,
    // WRITE Transaction, B Channel
    output logic [1:0] BRESP,
    output logic BVALID,
    input logic BREADY,

    // READ Transaction, AR Channel
    input logic [3:0] ARADDR,
    input logic ARVALID,
    output logic ARREADY,

    // READ Transaction, R Channel
    output logic [31:0] RDATA,
    output logic RVALID,
    input logic RREADY,
    input logic RRESP
    );

    logic [31:0] slv_reg0_next, slv_reg1_next, slv_reg2_next, slv_reg3_next;
    logic [31:0] slv_reg0_reg, slv_reg1_reg, slv_reg2_reg, slv_reg3_reg;
    logic [3:0] aw_addr_next, aw_addr_reg;

    // WRITE Transaction, AW Channel transfer
    typedef enum { 
        AW_IDLE_S, 
        AW_READY_S 
    } aw_state_e;

    aw_state_e aw_state, aw_state_next;

    always_ff @( posedge ACLK ) begin 
        if (!ARESETn) begin
            aw_state <= AW_IDLE_S;
            aw_addr_reg <= 0;
        end
        else begin
            aw_state <= aw_state_next;
            aw_addr_reg <= aw_addr_next; 
        end
    end

    always_comb begin 
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
    typedef enum { 
        W_IDLE_S, 
        W_READY_S 
    } w_state_e;

    w_state_e w_state, w_state_next;

    always_ff @( posedge ACLK ) begin 
        if (!ARESETn) begin
            w_state <= W_IDLE_S;
            slv_reg0_reg <= 0;
            slv_reg1_reg <= 0;
            slv_reg2_reg <= 0;
            slv_reg3_reg <= 0;
        end
        else begin
            w_state <= w_state_next;
            slv_reg0_reg <= slv_reg0_next;
            slv_reg1_reg <= slv_reg1_next;
            slv_reg2_reg <= slv_reg2_next;
            slv_reg3_reg <= slv_reg3_next;
        end
        
    end

    always_comb begin 
        slv_reg0_next = slv_reg0_reg;
        slv_reg1_next = slv_reg1_reg;
        slv_reg2_next = slv_reg2_reg;
        slv_reg3_next = slv_reg3_reg;
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
                        2'b10: slv_reg2_next = WDATA;
                        2'b11: slv_reg3_next = WDATA; 
                    endcase
                end
            end 
        endcase
    end

    // WRITE Transaction, B Channel transfer
    typedef enum { 
        B_IDLE_S, 
        B_VALID_S 
    } b_state_e;

    b_state_e b_state, b_state_next;

    always_ff @( posedge ACLK ) begin 
        if (!ARESETn) begin
            b_state <= B_IDLE_S;
        end
        else begin
            b_state <= b_state_next;
        end
    end

    always_comb begin 
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
    logic [3:0] ar_addr_reg, ar_addr_next;

    typedef enum { 
        AR_IDLE_S, 
        AR_READY_S 
    } ar_state_e;

    ar_state_e ar_state, ar_state_next;

    always_ff @( posedge ACLK ) begin 
        if (!ARESETn) begin
            ar_state <= AR_IDLE_S;
            ar_addr_reg <= 0;
        end
        else begin
            ar_state <= ar_state_next;
            ar_addr_reg <= ar_addr_next; 
        end
    end

    always_comb begin 
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
    logic [31:0] rdata_next, rdata_reg;

    typedef enum { 
        R_IDLE_S, 
        R_VALID_S 
    } r_state_e;

    r_state_e r_state, r_state_next;

    always_ff @( posedge ACLK ) begin 
        if (!ARESETn) begin
            r_state <= R_IDLE_S;
             rdata_reg <= 0;
        end
        else begin
            r_state <= r_state_next;
            rdata_reg <= rdata_next;
        end
    end

    always_comb begin 
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
                    2'b10: rdata_next = slv_reg2_reg;
                    2'b11: rdata_next = slv_reg3_reg;
                endcase
                RVALID = 1'b1;
                if (RREADY) begin
                    r_state_next = R_IDLE_S;
                end
            end
        endcase
    end

endmodule
