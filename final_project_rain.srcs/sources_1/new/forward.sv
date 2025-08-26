`timescale 1ns / 1ps

module total_background #(
    T = 24'd768
)(
    input logic clk,
    input logic rst,
    input logic [7:0] pixel,
    output logic out_pixel
);
    logic o_clk;

    logic [7:0] diff[4:0];
    logic [15:0] abs_diff [4:0];

    logic [2:0] addr_cnt;

    // Gaussian Model State Parameters
    logic [7:0] mean [4:0]; // 8
    logic [23:0] variance [4:0]; // 16.8
    logic [15:0] weight [4:0]; // 0.16

    logic [7:0] mean_final[4:0];
    logic [23:0] variance_final[4:0];
    logic [15:0] weight_final[4:0];

    logic [7:0] mean2sort[4:0];
    logic [23:0] variance2sort[4:0];
    logic [15:0] weight2sort[4:0];

    logic [7:0] mean_bg[4:0];
    logic [23:0] variance_bg[4:0];
    logic [15:0] weight_bg[4:0];

    logic [7:0] mean_pdf;
    logic [23:0] variance_pdf;

    logic [15:0] p;

    logic [2:0] match;
    logic [7:0] match2update_pixel, update2final_pixel;
    logic o_match;

    logic [7:0] pixel1, pixel2, pixel3, pixel4, fpixel;

    logic [31:0] num[4:0];
    logic [31:0] out_num[4:0];

    // match
    genvar i;
    generate
        for (i = 0; i < 5; i++) begin
            assign diff[i] = (pixel > mean[i]) ? (pixel - mean[i]) : (mean[i] - pixel);
            assign abs_diff[i] = diff[i] * diff[i];
        end
    endgenerate

    always_comb begin 
        if ({abs_diff[0], 8'b0}  <= T * variance[0]) begin
            match = 3'b000;
        end
        else if ({abs_diff[1], 8'b0}  <= T * variance[1]) begin
            match = 3'b001;
        end
        else if ({abs_diff[2], 8'b0}  <= T * variance[2]) begin
            match = 3'b010;
        end
        else if ({abs_diff[3], 8'b0}  <= T * variance[3]) begin
            match = 3'b011;
        end
        else if ({abs_diff[4], 8'b0}  <= T * variance[4]) begin
            match = 3'b100;
        end
        else begin
            match = 3'b111;
        end
    end

    genvar j;
    generate
        for (j = 0; j < 5; j++) begin
            assign num[j] = weight2sort[j] * weight2sort[j];
            assign out_num[j] = variance2sort[j] ? num[j] / {8'b0, variance2sort[j]} : 32'hfffff;
        end
    endgenerate

    // pixel delay
    always_ff @( posedge o_clk, posedge rst ) begin 
        if (rst) begin
            pixel1 <= 0;
            pixel2 <= 0;
            pixel3 <= 0;
            pixel4 <= 0;
        end
        else begin
            pixel1 <= pixel;
            pixel2 <= pixel1;
            pixel3 <= pixel2;
            pixel4 <= pixel3;
        end
    end

    assign fpixel = pixel4;

    // memory address
    always_ff @( posedge clk, posedge rst ) begin 
        if (rst) begin
            addr_cnt <= 0;
        end
        else begin
            if (addr_cnt == 5) begin
                addr_cnt <= 1;
            end
            else begin
                addr_cnt <= addr_cnt + 1;
            end
        end
    end

    logic [2:0] addr_cnt_abs;
    assign addr_cnt_abs = addr_cnt > 0 ? addr_cnt - 1 : 0; 
    assign mean_pdf = mean[addr_cnt_abs];
    assign variance_pdf = variance[addr_cnt_abs];

    // gaussian point distribution model module
    gaussian gaussian_pdf_mem(
        .clk(o_clk),
        .rst(rst),
        .mean(mean_pdf),
        .variance(variance_pdf),
        .p(p)
    );

    Gaussian_MAtch u_match(
        .clk(o_clk),
        .rst(rst),
        .match(match),
        .p(p),
        .pixel(fpixel),
        .mean(mean),
        .variance(variance),
        .weight(weight),
        .o_pixel(match2update_pixel),
        .o_match(o_match),
        .mean_final(mean_final),
        .variance_final(variance_final),
        .weight_final(weight_final)
    );

    gaussian_update u_update(
        .clk(o_clk),
        .rst(rst),
        .match(o_match),
        .pixel(match2update_pixel),
        .variance(variance),
        .mean_final(mean_final),
        .variance_final(variance_final),
        .weight_final(weight_final),
        .o_pixel(update2final_pixel),
        .omean(mean2sort),
        .ovariance(variance2sort),
        .oweight(weight2sort)
    );
    sort_fd sort1(
        .weight(weight2sort),
        .mean(mean2sort),
        .variance(variance2sort),
        .o_weight(weight),
        .o_mean(mean),
        .o_variance(variance)
    );

    bg_final u_final(
        .clk(o_clk),
        .rst(rst),
        .pixel(update2final_pixel),
        .mean(mean_bg),
        .variance(variance_bg),
        .weight(weight_bg),
        .out_pixel(out_pixel), // 0 배경, 1 전경
        .o_pixel()
    );

    sort_bg u_sort(
    .wgt_var(out_num),
    .weight  (weight2sort),
    .mean    (mean2sort),
    .variance(variance2sort),
    .o_weight(weight_bg),
    .o_mean  (mean_bg),
    .o_variance(variance_bg)
    );

    clk_div u_clk_div(
        .clk(clk),
        .rst(rst),
        .o_clk(o_clk)
    );

    
endmodule

// 1clk : pdf memory
// 2clk : calculate_power
// 3clk : calculate_final
module Gaussian_MAtch #(
    A = 5 // 학습률
)(
    input logic clk,
    input logic rst,
    input logic [2:0] match,
    input logic [15:0] p,
    input logic [7:0] pixel,
    input logic [7:0] mean[4:0],
    input logic [23:0] variance[4:0],
    input logic [15:0] weight[4:0],
    output logic [7:0] o_pixel,
    output logic o_match,
    output logic [7:0] mean_final[4:0],
    output logic [23:0] variance_final[4:0],
    output logic [15:0] weight_final[4:0]
);

    logic [15:0] p_plus, p_plus1; // 0.16
    logic [15:0] p_minus, p_minus1; //0.16

    logic [15:0] a;
    logic [15:0] a_minus;

    logic [47:0] lpower[4:0]; 
    logic [15:0] rpower[4:0];

    logic [31:0] lpower_lower[4:0]; 
    logic [15:0] rpower_lower[4:0];

    logic [48:0] mean_row[4:0];
    logic [64:0] variance_row[4:0];

    logic [31:0] weight_row[4:0];

    logic [2:0] pmatch1, pmatch2;
    logic pmatch3;
    logic [7:0] pmean1[4:0], pmean2[4:0];
    logic [23:0] pvariance1[4:0];
    logic [15:0] pweight1[4:0], pweight2[4:0];
    logic [7:0] pixel_p1, pixel_p2, pixel_p3; 

    assign o_pixel = pixel_p3;
    assign o_match = pmatch3; 

    always_comb begin
        for (int i = 0; i < 5; i++) begin
            lpower_lower[i] = (lpower[i][47:32])?  32'hfffffff: lpower[i][31:0];
            rpower_lower[i] = {rpower[i],16'b0};
            mean_final[i] = (mean_row[i][48:40]) ? 8'hff : mean_row[i][39:32];
            variance_final[i] = (variance_row[i][64:48]) ? 23'hfff: variance_row[i][47:24];
            weight_final[i] = weight_row[i][31:16];
        end
    end

    assign a = A;
    assign a_minus = 17'd65536 - A;

    always_ff @( posedge clk, posedge rst ) begin : blockName
        if (rst) begin
            pixel_p1 <= 0;
            pixel_p2 <= 0;
            pixel_p3 <= 0;

            pmatch1 <= 0;
            pmatch2 <= 0;
            pmatch3 <= 0;

            p_minus <= 0;
            p_plus <= 0;
            p_plus1 <= 0;
            p_minus1 <= 0;
            for (int i = 0; i < 5; i++) begin
                pmean1[i] <= 0;
                pmean2[i] <= 0;
                pvariance1[i] <= 0;
                pweight1[i] <= 0;
                pweight2[i] <= 0;
            end
        end
        else begin
            p_plus <= p;
            p_minus <= 17'd65536 - p;
            p_plus1 <= p_plus;
            p_minus1 <= p_minus;

            pmean1 <= mean;
            pmean2 <= pmean1;

            pvariance1 <= variance;

            pweight1 <= weight;
            pweight2 <= pweight1;

            pixel_p1 <= pixel;
            pixel_p2 <= pixel_p1;
            pixel_p3 <= pixel_p2;

            pmatch1 <= match;
            pmatch2 <= pmatch1;
            pmatch3 <= &pmatch2;
        end
    end

    always_ff @( posedge clk, posedge rst ) begin 
        if (rst) begin
            for (int i = 0; i<5; i++) begin
                lpower[i] <= 0;
                rpower[i] <= 0;
                mean_row[i] <= 0;
                variance_row[i] <= 0;
                weight_row[i] <= 0;
            end
        end
        else begin
            for (int i = 0; i < 5; i++) begin
                lpower[i] <= pvariance1[i] * pvariance1[i];
                rpower[i] <= (pixel_p1 > pmean1[i]) ? (pixel_p1 - pmean1[i]) * (pixel_p1 - pmean1[i]) : (pmean1[i] - pixel_p1) * (pmean1[i] - pixel_p1);
                
                if (pmatch2 == i) begin
                    mean_row[i] <= {8'b0, p_minus1} * {pmean2[i], 16'b0} + {8'b0, p_plus1} * {pixel, 16'b0};
                    variance_row[i] <= lpower_lower[i] * {16'b0, p_minus1} + rpower_lower[i] * {16'b0, p_plus1};
                    weight_row[i] <= pweight2[i] * a_minus + a;
                end
                else begin
                    mean_row[i] <= {9'b0, pmean2[i], 32'b0};
                    variance_row[i] <= {17'b0, pvariance1[i], 24'b0};
                    weight_row[i] <= pweight2[i] * a_minus;
                end   
            end
        end
    end
endmodule

// 1clk : store
module gaussian_update (
    input logic clk,
    input logic rst,
    input logic match,
    input logic [7:0] pixel,
    input logic [23:0] variance[4:0],
    input logic [7:0] mean_final[4:0],
    input logic [23:0] variance_final[4:0],
    input logic [15:0] weight_final[4:0],
    output logic [7:0] o_pixel,
    output logic [7:0] omean[4:0],
    output logic [23:0] ovariance[4:0],
    output logic [15:0] oweight[4:0]
);
    localparam INIT_WGT = 16'h0ccd;
    localparam INIT_VAR = 16'hE100;

    always_ff @( posedge clk, posedge rst ) begin
        if (rst) begin
            o_pixel <= 0;
            for ( int i = 0; i < 5; i++) begin
                omean[i] <= 0;
                ovariance[i] <= INIT_VAR;
                oweight[i] <= 0;
            end
        end
        else begin
            o_pixel <= pixel;
            for (int i = 0; i < 5 ; i++) begin
                if (match && i == 0) begin
                    omean[i] <= pixel;
                    ovariance[i] <= INIT_VAR;
                    oweight[i] <= INIT_WGT;
                end
                else begin
                    omean[i] <= mean_final[i];
                    ovariance[i] <= variance_final[i];
                    oweight[i] <= weight_final[i];
                end
            end
        end
    end

endmodule

module bg_final #(
    parameter T = 16'd3,
    parameter A = 5, 
    parameter K = 5,
    parameter BG_THRESHOLD = 16'd45875 
)(
    input logic clk,
    input logic rst,
    input logic [7:0] pixel,
    input logic [7:0] mean[4:0],
    input logic [23:0] variance[4:0],
    input logic [15:0] weight[4:0],
    output logic out_pixel, // 0 배경, 1 전경
    output logic [7:0] o_pixel
    );
    
    logic [2:0]  bg_model_count;
    logic [7:0] pixel_p;
    assign o_pixel = pixel_p;
    
    logic [2:0]  num_background_models;  
    logic [23:0] background_models [4:0]; // {mean, variance}
    logic [16:0] accumulated_weight;

    // check the back ground parameter
    logic [16:0] total_match[4:0]; 
    logic [8:0] total_match_abs[4:0];
    logic total_data[4:0];

    wire [15:0] a;
    assign a = A;
    // sort module 
    always_comb begin
        accumulated_weight = weight[0];
        if (accumulated_weight > BG_THRESHOLD) begin
            bg_model_count = 1;
        end 
        else begin
            accumulated_weight = accumulated_weight + weight[1];
            if (accumulated_weight > BG_THRESHOLD) begin
                bg_model_count = 2;
            end 
            else begin
                accumulated_weight = accumulated_weight + weight[2];
                if (accumulated_weight > BG_THRESHOLD) begin
                    bg_model_count = 3;
                end 
                else begin
                    accumulated_weight = accumulated_weight + weight[3];
                    if (accumulated_weight > BG_THRESHOLD) begin
                        bg_model_count = 4;
                    end 
                    else begin
                        bg_model_count = 5;
                    end
                end
            end
        end
    end

    // Separate the Background, Foreground
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            pixel_p <= 0;
            num_background_models <= 0;
            for (int i = 0; i < 5; i++) begin
                background_models[i] <= 0;
            end
        end 
        else begin
            num_background_models <= bg_model_count;
            pixel_p <= pixel;
            for (int i = 0; i < 5; i++) begin
                if (i < num_background_models) begin
                    background_models[i] <= {mean[i], variance[i][23:8]};
                end 
                else begin
                    background_models[i] <= 0;
                end
            end
        end
    end

genvar j;
    generate
        for (j = 0; j < 5; j++) begin
            assign total_match_abs[j] = pixel_p > background_models[j][23:16] ? (pixel_p - background_models[j][23:16]) : (background_models[j][23:16] - pixel_p);
            assign total_match[j] = total_match_abs[j] * total_match_abs[j]; 
            assign total_data[j] = ({16'b0, total_match[j]} <= (T * background_models[j][15:0]));
        end
    endgenerate

    // final logic
    assign out_pixel = (total_data[0] | total_data[1] | total_data[2] | total_data[3] | total_data[4]) ? 0 : 1;
    
endmodule

module sort_fd (
    input  logic [15:0] weight   [4:0],
    input  logic [7:0]  mean     [4:0],
    input  logic [23:0] variance [4:0],
    output logic [15:0] o_weight [4:0],
    output logic [7:0]  o_mean   [4:0],
    output logic [23:0] o_variance [4:0]
);

    // 내부 임시 변수
    logic [15:0] w [4:0];
    logic [7:0]  m [4:0];
    logic [23:0] v [4:0];

    integer i, j;

    always_comb begin
        // 입력을 복사
        for (i = 0; i < 5; i++) begin
            w[i] = weight[i];
            m[i] = mean[i];
            v[i] = variance[i];
        end

        // 버블 정렬: weight 기준으로 내림차순
        for (i = 0; i < 5; i++) begin
            for (j = 0; j < 4 - i; j++) begin
                if (w[j] < w[j+1]) begin
                    // weight swap
                    {w[j], w[j+1]} = {w[j+1], w[j]};
                    // mean swap
                    {m[j], m[j+1]} = {m[j+1], m[j]};
                    // variance swap
                    {v[j], v[j+1]} = {v[j+1], v[j]};
                end
            end
        end

        // 결과 출력
        for (i = 0; i < 5; i++) begin
            o_weight[i]   = w[i];
            o_mean[i]     = m[i];
            o_variance[i] = v[i];
        end
    end

endmodule

module sort_bg (
    input logic [31:0] wgt_var [4:0],
    input  logic [15:0] weight   [4:0],
    input  logic [7:0]  mean     [4:0],
    input  logic [23:0] variance [4:0],
    output logic [15:0] o_weight [4:0],
    output logic [7:0]  o_mean   [4:0],
    output logic [23:0] o_variance [4:0]
);

    // 내부 임시 변수
    logic [15:0] w [4:0];
    logic [7:0]  m [4:0];
    logic [23:0] v [4:0];
    logic [31:0] s [4:0];

    integer i, j;

    always_comb begin
        // 입력을 복사
        for (i = 0; i < 5; i++) begin
            w[i] = weight[i];
            m[i] = mean[i];
            v[i] = variance[i];
            s[i] = wgt_var[i];
        end

        // 버블 정렬: weight 기준으로 내림차순
        for (i = 0; i < 5; i++) begin
            for (j = 0; j < 4 - i; j++) begin
                if (s[j] < s[j+1]) begin
                    // weight swap
                    {w[j], w[j+1]} = {w[j+1], w[j]};
                    // mean swap
                    {m[j], m[j+1]} = {m[j+1], m[j]};
                    // variance swap
                    {v[j], v[j+1]} = {v[j+1], v[j]};
                end
            end
        end

        // 결과 출력
        for (i = 0; i < 5; i++) begin
            o_weight[i]   = w[i];
            o_mean[i]     = m[i];
            o_variance[i] = v[i];
        end
    end

endmodule

module clk_div (
    input logic clk,
    input logic rst,
    output logic o_clk
);
    always_ff @( posedge clk, posedge rst ) begin : blockName
        if (rst) begin
            o_clk <= 0;
        end
        else begin
            o_clk <= ~o_clk;
        end
    end
endmodule

module gaussian (
    input logic clk,
    input logic rst,
    input logic [7:0] mean,
    input logic [23:0] variance,
    output logic [15:0] p
);
    logic [15:0] mem [0:65535];
    
    logic [7:0] mean_addr;
    logic [7:0] var_addr;
    logic [15:0] mem_addr;

    assign mean_addr = mean;
    assign var_addr = variance[23:16] > 0 ? 8'hff : variance[15:8];

    assign mem_addr = {mean_addr, var_addr};
    
    initial begin
        $readmemh("gaussian_pdf.mem", mem);
    end
    
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            p <= 0;
        end
        else begin
            p <= mem[mem_addr];
        end
    end

endmodule