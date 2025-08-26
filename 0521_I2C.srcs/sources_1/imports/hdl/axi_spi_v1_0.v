
`timescale 1 ns / 1 ps

	/*module axi_spi_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
// Instantiation of Axi Bus Interface S00_AXI
	axi_spi_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) axi_spi_v1_0_S00_AXI_inst (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here

	// User logic ends

	endmodule*/
module top (
	input clk,
	input reset,
	input start,
	input i2c_en,
	input stop,
	input rw,
	input [7:0] tx_data,
	//output [7:0] rx_data,
	//output tx_done,
	//output ready,
	output [3:0] lstate,
	// i2c
	output SCL_M,
	inout SDA_M
	//input SCL_S,
	//input SDA_S,
	//output [7:0] led
);

	wire w_start, w_stop, w_i2c_en;

	I2C_Master U_I2C(
		.clk(clk),
		.reset(reset),
		.start(w_start),
		.i2c_en(w_i2c_en),
		.stop(w_stop),
		.tx_data(tx_data),
		.rx_data(),
		.tx_done(),
		.ready(),
		.rw(rw),
		.lstate(lstate),
		.SCL(SCL_M),
		.SDA(SDA_M)
	);

	/*I2C_Slave U_I2C_S(
    	.clk(clk),
    	.reset(reset),
    	.SCL(SCL_S),
    	.SDA(SDA_S),
    	.data(led)
	);*/

	btn_debounce U_S_btn(
    	.clk(clk),
    	.reset(reset),
    	.i_btn(start),
    	.o_btn(w_start)
    );

	btn_debounce U_en_btn(
    	.clk(clk),
    	.reset(reset),
    	.i_btn(i2c_en),
    	.o_btn(w_i2c_en)
    );

	btn_debounce U_Stop_btn(
    	.clk(clk),
    	.reset(reset),
    	.i_btn(stop),
    	.o_btn(w_stop)
    );
endmodule


module I2C_Master (
	input clk,
	input reset,
	input start,
	input i2c_en,
	input stop,
	input rw,
	input [7:0] tx_data,
	output [7:0] rx_data,
	output tx_done,
	output ready,
	output [3:0] lstate,
	// i2c
	output SCL,
	inout SDA
	);

	
	localparam IDLE = 0, START0 = 1, START1 = 2, DATA0 = 3, DATA1 = 4, DATA2 = 5, 
	HOLD = 6, STOP0 = 7, STOP1 = 8, WAIT = 9, READ0 = 10, READ1 = 11, READ2 = 12;

	reg [3:0] state, next;
	reg [8:0] cnt_reg, cnt_next;
	reg [7:0] temp_tx_data_reg, temp_tx_data_next;
	reg [7:0] temp_rx_data_reg, temp_rx_data_next;
	reg [3:0] bit_cnt_reg, bit_cnt_next;
	reg flag_reg, flag_next;

	assign ready = (state == IDLE);
	assign SDA = (~flag_reg & (state == DATA0 | state == DATA1 | state == DATA2)) ? temp_tx_data_reg[7]: (((state == READ0 | state == READ1 | state == READ2) & ~flag_reg ) | (flag_reg & (state == DATA0 | state == DATA1 | state == DATA2))) ? 1'bz: (state == IDLE | state == STOP1 ) ? 1'b1 : 0;
	
	assign SCL = (state == IDLE | state == START0 | state == DATA1 | state == READ1 |state == STOP0 | state == STOP1) ? 1 : 0;
	assign tx_done =(state == HOLD | state == WAIT) ? 1 : 0;

	assign lstate = state;
	assign rx_data = temp_rx_data_reg;

	always @(posedge clk, posedge reset) begin
		if (reset) begin
			state <= IDLE;
			cnt_reg <= 0;
			temp_tx_data_reg <= 0;
			temp_rx_data_reg <= 0;
			bit_cnt_reg <= 0;
			flag_reg <= 0;
		end
		else begin
			state <= next;
			cnt_reg <= cnt_next;
			temp_tx_data_reg <= temp_tx_data_next;
			temp_rx_data_reg <= temp_rx_data_next;
			bit_cnt_reg <= bit_cnt_next;
			flag_reg <= flag_next;
		end
	end

	always @(*) begin
		next = state;
		cnt_next = cnt_reg;
		temp_tx_data_next = temp_tx_data_reg;
		temp_rx_data_next = temp_rx_data_reg;
		bit_cnt_next = bit_cnt_reg;
		flag_next = flag_reg; 
		case (state)
			IDLE: begin
				if (start) begin
					next = START0;
				end
			end 
			START0: begin
				if (cnt_reg == 499) begin
					next = START1;
					cnt_next = 0;
				end
				else begin
					cnt_next = cnt_reg + 1;
				end
			end
			START1: begin
				if (cnt_reg == 499) begin
					next = HOLD;
					cnt_next = 0;
				end
				else begin
					cnt_next = cnt_reg + 1;
				end
			end
			DATA0: begin
				if (cnt_reg == 249) begin
					next = DATA1;
					cnt_next = 0;

				end
				else begin
					cnt_next = cnt_reg + 1;
				end
			end
			DATA1: begin
				if (cnt_reg == 499) begin
					next = DATA2;
					cnt_next = 0;
				end
				else begin
					cnt_next = cnt_reg + 1;
				end
			end
			DATA2: begin
				if (cnt_reg == 249) begin
					cnt_next = 0;
					if (bit_cnt_reg == 8) begin
						next = HOLD;
						flag_next = 0;
					end
					else if (bit_cnt_reg == 7) begin
						temp_tx_data_next ={temp_tx_data_reg[6:0], temp_tx_data_reg[7]};
						flag_next = 1;
						bit_cnt_next = bit_cnt_reg + 1;
						next = DATA0;
					end
					else begin
						bit_cnt_next = bit_cnt_reg + 1;
						next = DATA0;
						temp_tx_data_next ={temp_tx_data_reg[6:0], temp_tx_data_reg[7]};
					end
				end
				else begin
					cnt_next = cnt_reg + 1;
				end
			end
			HOLD: begin
				cnt_next = 0;
				bit_cnt_next = 0;
				if (i2c_en & !rw) begin
					temp_tx_data_next = tx_data;
					next = DATA0;
				end
				if (i2c_en & rw) begin
					next = READ0;
				end
				if (stop) begin
					next = STOP0;
				end
			end
			STOP0: begin
				if (cnt_reg == 499) begin
					next = STOP1;
					cnt_next = 0;
				end
				else begin
					cnt_next = cnt_reg + 1;
				end
			end 
			STOP1: begin
				if (cnt_reg == 499) begin
					next = IDLE;
					cnt_next = 0;
				end
				else begin
					cnt_next = cnt_reg + 1;
				end
			end
			READ0: begin
				if (cnt_reg == 249) begin
					next = READ1;
					cnt_next = 0;
				end
				else begin
					cnt_next = cnt_reg + 1;
				end
			end
			READ1: begin
				if (cnt_reg == 499) begin
					next = READ2;
					cnt_next = 0;
					temp_rx_data_next = {temp_rx_data_reg[6:0], SDA}; 
				end
				else begin
					cnt_next = cnt_reg + 1;
				end
			end
			READ2: begin
				if (cnt_reg == 249) begin
					cnt_next = 0;
					if (bit_cnt_reg == 8) begin
						next = HOLD;
						flag_next = 0;
						bit_cnt_next = 0;
					end
					else if (bit_cnt_reg == 7) begin
						flag_next = 1;
						bit_cnt_next = bit_cnt_reg + 1;
						next = READ0;
					end
					else begin
						bit_cnt_next = bit_cnt_reg + 1;
						next = READ0;
					end
				end
				else begin
					cnt_next = cnt_reg + 1;
				end
			end
		endcase
	end
endmodule



module I2C_Slave(
    input clk,
    input reset,
    input SCL,
    input SDA,
    output [7:0] data
);

    wire [6:0] slv_addr;
    assign slv_addr = 7'b1101010;
    localparam IDLE = 0, HOLD = 1, START = 2, ADDR = 3, REG = 4, WRITE = 5, ACK1 = 6, ACK2 = 7;

    reg [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;
    reg [3:0] state, next;
    reg [7:0] temp_rx_data_reg, temp_rx_data_next;
    reg [3:0] bit_counter_reg, bit_counter_next;
	reg [7:0] data_reg, data_next;
    reg SCL_prev;
	
	assign data = data_reg;

    always @(posedge clk or posedge reset) begin
        if(reset)begin
            state <= IDLE;
            temp_rx_data_reg <= 0;
            bit_counter_reg <= 0;
			data_reg <= 0;
        end
        else begin
            state <= next;
            temp_rx_data_reg <= temp_rx_data_next;
            SCL_prev <= SCL;
            bit_counter_reg <= bit_counter_next;
			data_reg <= data_next;
        end
    end

    always @(*) begin
        next = state;
        temp_rx_data_next = temp_rx_data_reg;
        bit_counter_next = bit_counter_reg;
		data_next = data_reg;
        case (state)
            IDLE: begin
                // SDA = 1'bz;
                if(!SDA)begin
                    next = HOLD;
                end
            end
            HOLD: begin
                if(!SCL)begin
                    next = START;
                end
            end
            START: begin
                if(bit_counter_reg == 8)begin
                    bit_counter_next = 0;
                    next = ADDR;
                end
                else begin
                    if((SCL != SCL_prev) && (SCL == 1))begin
                        temp_rx_data_next = {temp_rx_data_reg, SDA};
                        bit_counter_next = bit_counter_reg + 1;
                    end
                end
            end
            ADDR: begin
                if(temp_rx_data_reg[7:1] == slv_addr)begin
                    if(temp_rx_data_reg[0])begin // READ MODE
                        // next = READ;
                        next = IDLE;
                    end
                    else begin // WRITE MODE
                        next = ACK1;
                    end
                end
                else begin
                    next = IDLE;
                end
            end
            ACK1: begin
                if((SCL != SCL_prev) && (SCL == 1))begin
                    next = REG;
                end
            end
            REG: begin // register addr 받음
                if(bit_counter_reg == 8)begin
                    bit_counter_next = 0;
                    next = ACK2;
                end
                else begin
                    if((SCL != SCL_prev) && (SCL == 1))begin
                        temp_rx_data_next = {temp_rx_data_reg, SDA};
                        bit_counter_next = bit_counter_reg + 1;
                    end
                end
            end
            ACK2: begin
                if((SCL != SCL_prev) && (SCL == 1))begin
                    next = WRITE;
                end
            end
            WRITE: begin
                // case (temp_rx_data_reg)
                //     0: slv_reg = slv_reg0;
                //     1: slv_reg = slv_reg1;
                //     2: slv_reg = slv_reg2;
                //     3: slv_reg = slv_reg3;
                // endcase
                if(bit_counter_reg == 8)begin
                    bit_counter_next = 0;
                    data_next = temp_rx_data_reg[7:0]; //slv_reg = temp_rx_data_reg[7:0];
					next = ACK2;
                end
                else begin
                    if((SCL != SCL_prev) && (SCL == 1))begin
                        temp_rx_data_next = {temp_rx_data_reg, SDA};
                        bit_counter_next = bit_counter_reg + 1;
                    end
                end
            end
            // READ: begin
                
            // end
            // ACK1: begin
            //     SDA = 0;
            //     if(clk_counter_reg == 249)begin // clk counter를 쓰는게 맞나
            //         clk_counter_next = 0;
            //         next = ACK2;
            //     end
            //     else begin
            //         clk_counter_next = clk_counter_reg + 1;
            //     end
            // end
            // ACK2: begin
            //     SDA = 0;
            //     if(clk_counter_reg == 499)begin
            //         clk_counter_next = 0;
            //         next = ACK3;
            //     end
            //     else begin
            //         clk_counter_next = clk_counter_reg + 1;
            //     end
            // end
            // ACK3: begin
            //     SDA = 0;
            //     if(clk_counter_reg == 249)begin
            //         clk_counter_next = 0;
            //         next = R? W?;
            //     end
            //     else begin
            //         clk_counter_next = clk_counter_reg + 1;
            //     end
            // end
        endcase
    end

endmodule
