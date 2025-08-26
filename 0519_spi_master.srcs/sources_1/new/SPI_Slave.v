`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/19 15:17:10
// Design Name: 
// Module Name: SPI_Slave
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


module SPI_Slave(
    
    );
endmodule

module SPI_Slave_Intf (
    input reset,
    input SCLK,
    input MOSI, 
    output MISO,
    input SS,
    // internal signals
    output write,
    output reg done,
    output [1:0] addr,
    output [7:0] wdata,
    input [7:0] rdata
);
    
    //localparam IDLE = 0, CP0 = 1, CP1 = 2;
    localparam IDLE = 0, ADDR = 1, DATA = 2;

    reg [1:0] state, state_next;
    reg [7:0] temp_tx_data_next, temp_tx_data_reg, temp_rx_data_next, temp_rx_data_reg;
    reg [2:0] bit_counter_next, bit_counter_reg;

    assign MISO = SS ? 1'bz : temp_tx_data_reg[7];


    always @(posedge SCLK, posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end
        else begin
            state <= state_next;
        end
    end

    always @(*) begin
        state_next = state;
        case (state)
            IDLE: begin
                if (!SS) begin
                    state_next = ADDR;
                end
            end 
            ADDR: begin
                if (bit_cnt_reg == 7) begin
                    state_next = DATA;
                end
            end
            DATA: begin
                
            end 
        endcase
    end

    always @(posedge SCLK) begin
        if (state == ADDR) begin
            
        end
    end

    always @(negedge SCLK) begin
        if (state == DATA) begin
            
        end
    end
    /*// MOSI sequence
    always @(posedge SCLK) begin
        if (!SS) begin
            temp_rx_data_reg <= {temp_rx_data_reg[6:0], MOSI};
        end
    end

    
    // MISO sequence
    always @(negedge SCLK) begin
    end

    always @(*) begin
        temp_tx_data_next = temp_tx_data_reg;
        case (state)
            SO_IDLE: begin
                if (SS == 1'b0 && rden) begin
                    temp_tx_data_next = rdata;
                    state_next = SO_DATA;
                end
            end 
            SO_DATA: begin
                if (SS == 1'b0 && rden) begin
                    
                end
            end 
        endcase
    end

    always @(posedge SCLK, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            temp_tx_data_reg <= 0;
            temp_rx_data_reg <= 0;
            bit_counter_reg <= 0;
        end
        else begin
            state <= state_next;
            temp_tx_data_reg <= temp_tx_data_next;
            temp_rx_data_reg <= temp_rx_data_next;
            bit_counter_reg <= bit_counter_next;
        end
    end    

    always @(*) begin
        state_next = state;
        temp_tx_data_next = temp_tx_data_reg;
        temp_rx_data_next = temp_rx_data_reg;
        bit_counter_next = bit_counter_reg;
        case (state)
            IDLE: begin
                if (!SS) begin
                    temp_tx_data_next = rdata;
                end
            end
            CP0: begin
                if (SCLK == 1'b1) begin
                    temp_rx_data_next = {temp_rx_data_reg[6:0], MOSI};
                    state_next = CP1;
                end
            end
            CP1: begin
                if (SCLK == 1'b0) begin
                    if(bit_counter_reg == 7) begin
                        done = 1'b1;
                        state_next = IDLE;
                    end
                    else begin
                        bit_counter_next = bit_counter_reg + 1;
                        state_next = CP0;
                    end
                end
            end  
        endcase
    end
endmodule*/