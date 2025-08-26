`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/24 13:47:28
// Design Name: 
// Module Name: DHT
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


module DHT(
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
    inout  logic        dht_io
    );

    logic       fcr;
    logic [13:0] fdr;
    logic  [3:0] fpr;

    APB_SlaveIntf_FndDontroller U_APB_IntfO (.*);
    //GPIO U_GPIO_IP (.*);
    //fnd_controller U_fnd_controller(.*);
    humity_sensor_top(
        .*,
    output [15:0] TDATA,
    output [15:0] HDATA
    );
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
    output logic [13:0] fhr,
    output logic [3:0] ftr
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2;//, slv_reg3;

    assign fcr = slv_reg0[0];
    assign fhr = slv_reg1[15:0];
    assign ftr = slv_reg2[15:0];

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

module humity_sensor_top(
    input PCLK,
    input RESET,
    
    input fcr,
    
    inout dht_io,
    output [15:0] TDATA,
    output [15:0] HDATA
    );

    wire w_tick;
    wire [39:0] data;
    
    assign TDATA = data[23:8];
    assign HDATA = data[39:24];

    tick_generator u_tick(
        .clk(PCLK),
        .rst(RESET),
        .tick(w_tick)
    );

    sensor_cu u_cu(
        // global signal
        .clk(PCLK),
        .rst(RESET),
        .tick(w_tick),
        
        // i/o
        .start(fcr),
    
        // sensor protocol signal
        .dht(dht_io),
        
        // humity & temperature data
        .data(data)

    );
endmodule

module tick_generator #(
    CNT = 1000 // 1us
)(
    input clk,
    input rst,
    output tick
);
    reg r_tick;
    assign tick = r_tick; 

    reg [$clog2(CNT)-1:0] cnt;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_tick <= 0;
            cnt <= 0;
        end    
        else begin
            if (cnt == CNT-1) begin
                cnt <= 0;
                r_tick <= 1;
            end
            else begin
                r_tick <= 0;
                cnt <= cnt + 1;
            end
        end
    end
endmodule

module sensor_cu (
    // global signal
    input clk,
    input rst,
    input tick,
    // i/o
    input start,
    output [7:0] cstate,
    // sensor protocol signal
    inout dht,
    // humity & temperature data
    output [39:0] data
);
    // parameter
    localparam START_CNT = 1800, WAIT_CNT = 3, DATA_CNT = 3, STOP_CNT = 5, TIME_OUT = 2000,
                LOW =5,RES_CNT =8;
    // fsm
    localparam IDLE = 0, START = 1, WAIT = 2, SYNC_LOW =3, SYNC_HIGH = 4, DATA_SRT = 5, 
                DATA_SYNC = 6, STOP = 9, TICK = 10, DATA_CAL = 7, DATA_S = 8;
    reg [3:0] state, next;

    // counter register
    reg [$clog2(START_CNT)-1:0] tcnt_reg, tcnt_next;
    reg [5:0] icnt_reg, icnt_next;

    // inout pin
    assign dht = (state == START) ? 0 : 
                ((state == IDLE)|(state == WAIT)) ? 1 : 1'bz;

    // data register
    reg [39:0] data_reg, data_next;
    assign data = (state == TICK)? data_reg[39:0] : 0;

    // edge_flag
    reg flag_r, flag_n;

    // fsm sync logic
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
            tcnt_reg <= 0;
            data_reg <= 0;
            icnt_reg <= 6'd39;
            flag_r <= 0;

        end
        else begin
            state <= next;
            tcnt_reg <= tcnt_next;
            data_reg <= data_next;
            icnt_reg <= icnt_next;
            flag_r <= flag_n;
            
        end
    end

    // fsm state logic
    always @(*) begin
        next = state;
        tcnt_next = tcnt_reg;
        data_next = data_reg;
        icnt_next = icnt_reg;
        flag_n = flag_r;
        
        case (state)
            IDLE: begin
                flag_n = 0;
                tcnt_next = 0;
                icnt_next = 6'd39;
                if (start) begin
                    next = START;
                end
            end 
            START: begin
                if (tick) begin
                    if (tcnt_reg == START_CNT-1) begin
                        next = WAIT;
                        tcnt_next = 0;
                    end
                    else begin
                        tcnt_next = tcnt_reg + 1'b1;
                    end
                end
            end
            WAIT: begin
                if (tick) begin
                    if (tcnt_reg == WAIT_CNT-1) begin
                        next = SYNC_LOW;
                        tcnt_next = 0;
                    end
                    else begin
                        tcnt_next = tcnt_reg + 1'b1;
                    end
                end
            end
            SYNC_LOW: begin // sensor protocol
                if (tick) begin
                    if (dht) begin
                        next = SYNC_HIGH;
                    end
                end
            end
            SYNC_HIGH: begin // sensor protocol
                if (tick) begin
                    if (~dht) begin
                        next = DATA_SRT;
                    end
                end
            end
            DATA_SRT: begin // sensor protocol
                if (TICK) begin
                    if (dht) begin
                        next = DATA_SYNC;
                    end
                end
            end
            DATA_SYNC: begin // sensor data count
                if (tick) begin
                    if (dht) begin
                        tcnt_next = tcnt_reg + 1;
                    end
                    else begin
                        next = DATA_CAL;
                    end
                end
                if (flag_r == 1) begin
                    flag_n = 0;
                    icnt_next = icnt_reg - 1'b1;
                end
                
            end
            DATA_CAL: begin // decide to 1 or 0
                if (tick) begin
                    if (tcnt_reg < DATA_CNT) begin
                        data_next[icnt_reg] = 0; 
                        next = DATA_S;
                        tcnt_next = 0; 
                    end
                    else begin
                        data_next[icnt_reg] = 1; 
                        next = DATA_S;
                        tcnt_next = 0;
                    end
                end
            end
            DATA_S: begin // change to state
                if (tick) begin
                    if (dht) begin
                        next = DATA_SYNC;
                        flag_n = 1;
                    end
                    else begin
                        if (icnt_reg == 0) begin
                            next = STOP;
                            tcnt_next = 0;
                        end
                    end
                end
            end
            STOP: begin // sensor stop
                if (tick) begin
                    if (tcnt_reg == STOP_CNT) begin
                        next = TICK;
                    end
                    else begin
                        tcnt_next = tcnt_reg + 1;
                    end
                end
            end
            TICK: begin // data 
                next = IDLE;
            end
        endcase
    end

endmodule
