`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/22 16:04:09
// Design Name: 
// Module Name: blob_filter
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


/*module blob_filter #(
    K = 1024
)(
    input logic clk,
    input logic rst,
    input logic en,
    input logic i_data,
    output logic o_flag,
    output logic [35:0] o_data
    );
    
    logic pre, state;
    logic [35:0] run[K-1:0];
    logic [35:0] run_wdata, run_rdata, run_tdata;
    logic [9:0] waddr, raddr;
    logic [7:0] row;
    logic [8:0] col;
    logic [9:0] label, c_label;

    assign o_flag = (row == 239 & col == 319) & (raddr == waddr);

    always_ff @( posedge clk ) begin
        if (en) begin
            run[waddr] <= {c_label,run_tdata[25:0]}; 
        end 
        run_rdata <= run[raddr];
    end
    assign o_data = run_rdata;

    always_ff @(posedge clk) begin 
        if (rst) begin
            c_label <= 0;
            raddr <= 0;
            waddr <= 0;
        end
        else begin
            if (row > 0) begin
                if (row == run_rdata[7:0] + 1) begin
                    if ((run_rdata[25:17] <= run_tdata[16:8]) || (run_rdata[16:8]) >= run_tdata[25:17]) begin
                        c_label <= run_rdata[35:26];
                        waddr <= waddr + 1;
                    end
                    else begin
                        c_label <= run_tdata[35:26];
                    end
                end
                if (state == 0) begin
                    if (run_rdata[7:0] < row ) begin
                        raddr <= raddr + 1;
                    end
                    else begin
                        raddr <= 0;
                    end
                    if (o_flag) begin
                        state <= 1;
                    end
                end
                else begin
                    if (raddr == waddr) begin
                        state <= 0;
                    end
                    else begin
                        raddr <= raddr + 1;
                    end
                end
            end
        end
    end

    
    end
endmodule

module rain_snow_detect #(
    RAIN_WIDTH = 5,
    SNOW_WIDTH = 10,
    SNOW_HEIGHT = 10
)(
    input logic clk,
    input logic rst,
    input logic snow_en,
    input logic i_flag,
    input logic i_sig,
    input logic [35:0] i_data,
    output logic o_data
    );
    localparam IDLE = 0, RAIN = 1, SNOW = 2, DONE = 3;
    logic [1:0] state, next;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end
        else begin
            state <= next;
        end
    end

    always_comb begin 
        case (state)
            IDLE: begin
                if (i_flag&snow_en) begin
                    next = SNOW;
                end
                else if(i_flag&!snow_en) begin
                    next = RAIN;
                end
                else begin
                    next = IDLE;
                end
            end
            DONE: begin
                next = IDLE;
            end
            RAIN: begin
                if (snow_en) begin
                    next = SNOW;
                end
                else begin
                    next = RAIN;
                end
            end
            SNOW: begin
                if (snow_en) begin
                    next = SNOW;
                end
                else begin
                    next = RAIN;
                end
            end
              
        endcase
    end

    always_comb begin
        case(state)
            IDLE: begin
                o_data = 0;
            end
            WAIT: begin
                
            end
            RAIN: begin
                o_data = (i_data[:] - i_data[]) < RAIN_WIDTH
            end
            SNOW: begin
                
            end
            
        endcase
    end
endmodule*/
/*
module blob_filter #(
    COL = 640,
    ROW = 480,
    RAIN_WD = 16,
    SNOW_WD = 96,
    SNOW_HG = 72,
    MIN_W = 1,
    LABEL = (COL + 1)/(MIN_W +1)
)(
    input logic clk,
    input logic rst,
    input logic en,
    input logic i_data,
    output logic o_flag,
    output logic o_data
    );

    logic [17:0] mem [2**(LABEL-1) : 0];
    logic [2*($clog2(ROW)-1):0] mem1 [2**(LABEL-1) : 0];

    //logic [5:0] fifo [SNOW_HG*-1:0];
    
    logic [LABEL-1 : 0] wlabel, rlabel, flabel;

    logic [$clog2(COL)-1:0] col;
    logic [$clog2(ROW)-1:0] row;

    logic [($clog2(COL) - 1)*2: 0]run_wdata, run_rdata, run_tdata, run_kdata;

    logic pre;

    // memory
    always_ff @( posedge clk ) begin : memory
        if (en) begin
            mem[wlabel] <= run_wdata; 
        end
        run_rdata <= mem[rlabel];    
    end

    // memory
    always_ff @( posedge clk ) begin 
        if (en) begin
            mem1[wlabel] <= run_tdata; 
        end
        run_kdata <= mem1[rlabel];    
    end

    // row, col
    always_ff @( posedge clk, posedge rst ) begin : row_and_col
        if (rst) begin
            col <= 0;
            row <= 0;
        end
        else begin
            if (col == COL - 1) begin
                col <= 0;
                if (row == ROW - 1) begin
                    row <= 0;
                end
                else begin
                    row <= row + 1;
                end
            end
            else begin
                col <= col + 1;
            end
        end
    end

    // stage 1 - detect continuous data
    always_ff @( posedge clk, posedge rst ) begin : blockName
        if (rst) begin
            pre <= 0;
            wlabel <= 1;
            run_wdata <= 0;
        end
        else begin
            pre <= i_data;
            if (!(row && col)) begin
                wlabel <= 0;
            end
            else begin
                case ({i_data,pre})
                    2'b00: begin
                        
                    end 
                    2'b01: begin
                        run_wdata <= {col,col};
                    end 
                    2'b10: begin
                        if (run_wdata[2*($clog2(COL)-1):$clog2(COL)] == run_wdata[$clog2(COL)-1:0] + MIN_W) begin
                            run_wdata <= 0;
                        end
                        else begin
                            wlabel <= wlabel + 1;
                        end
                    end
                    2'b11: begin
                        run_wdata[16:8] <= col;
                    end
            endcase
            end 
        end
    end
    
    // stage2 - memory update 
    always_ff @( posedge clk ) begin
        if (run_wdata[2*($clog2(COL) - 1): $clog2(COL)] > run_rdata[$clog2(COL) - 1: 0] && run_wdata[$clog2(COL) - 1: 0] > run_rdata[2*($clog2(COL) - 1): $clog2(COL)]) begin
            run_tdata <= run_wdata;
        end
        if (rlabel == wlabel) begin
            rlabel <= 0;
        end
        else begin
            rlabel <= rlabel + 1;
        end
    end

    // stage3 - 
endmodule*/

// SNOW_WD + 1 + 1
module blob_filter #(
    HSYNC = 640,
    VSYNC = 480,
    RAIN_WD = 16,
    SNOW_WD = 96,
    SNOW_HG = 72,
    MIN_W = 1,
    COL = HSYNC,
    ROW = SNOW_HG 
)(
    input logic clk,
    input logic rst,
    input logic sw,
    input logic i_data,
    output logic mask
);

    logic [ROW : 0] mem [COL -1 : 0];
    logic en;
    logic sfull, rfull;
    logic [ROW -1 : 0] cal;
    logic v_check;
    logic snow, rain;
    logic [$clog2(SNOW_WD):0] scnt;
    logic [$clog2(RAIN_WD):0] rcnt;
    logic [1:0] wdata;
    logic [VSYNC:0] rdata;
    logic [SNOW_WD:0] wid_scheck;
    logic [RAIN_WD:0] wid_rcheck;
    logic [$clog2(COL)-1:0] col;
    logic [$clog2(ROW)-1:0] row;

    assign en = 1;

    always_ff @( posedge clk) begin 
        if (en) begin
            mem[col] <= {wdata[0], cal};
        end
         rdata <= mem[col];
    end

    assign sfull = &wid_scheck;
    assign rfull = &wid_rcheck;
    assign cal = {479'b0, wdata[1]} << row;
    assign v_check =  &rdata[VSYNC-1 :0];
    assign snow = !v_check & rdata[VSYNC];
    assign rain = (!rcnt & wid_rcheck[RAIN_WD]) ? 1 : 0;
    assign mask = sw ? snow : rain;

    // snow
    always_ff @( posedge clk, posedge rst ) begin 
        if (rst) begin
            scnt <= 0;
        end
        else begin
            if (sfull) begin
                scnt <= SNOW_WD;
            end
            else if (scnt) begin
                scnt <= scnt -1;
            end
        end
    end

    // rain
    always_ff @( posedge clk, posedge rst ) begin
        if (rst) begin
            rcnt <= 0;
        end
        else begin
            if (rfull) begin
                rcnt <= RAIN_WD;
            end
            else if (scnt) begin
                rcnt <= rcnt -1;
            end
        end
    end

    always_comb begin
        if (scnt) begin
            wdata = 2'b10;
        end
        else begin
            if (wid_scheck[SNOW_WD]) begin
                wdata = 2'b01;
            end
            else begin
                wdata = 2'b00;
            end
        end
    end

    // row, col
    always_ff @( posedge clk, posedge rst ) begin : row_and_col
        if (rst) begin
            col <= 0;
            row <= 0;
        end
        else begin
            if (col == COL - 1) begin
                col <= 0;
                if (row == ROW - 1) begin
                    row <= 0;
                end
                else begin
                    row <= row + 1;
                end
            end
            else begin
                col <= col + 1;
            end
        end
    end

    // main logic 
    always_ff @( posedge clk, posedge rst ) begin
        if (rst) begin
            wid_scheck <= 0;
            wid_rcheck <= 0;
        end
        else begin
            if(sw) begin
                wid_scheck <= {wid_scheck[SNOW_WD:0], i_data};
            end
            else begin
               wid_rcheck <= {wid_rcheck[RAIN_WD:0],i_data}; 
            end
        end
    end

endmodule