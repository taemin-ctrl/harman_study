`timescale 1ns / 1ps
module Image_Rom (
    input logic [9:0] x_pixel,
    input logic [9:0] y_pixel,
    input logic DE,
    output logic [3:0] red_port,
    output logic [3:0] green_port,
    output logic [3:0] blue_port
);
    logic [16:0] image_addr;
    logic [15:0] image_data;
    
    assign image_addr = 320 * y_pixel[9:0] + x_pixel[9:0];
    
    always_comb begin
        if (x_pixel <320 && y_pixel < 240) begin
            red_port = image_data[15:12];
            green_port = image_data[10:7];
            blue_port = image_data[4:1];
        end
        else begin
            red_port = 4'b0; 
            green_port = 4'b0; 
            blue_port = 4'b0;
        end
    end

    image_rom U_ROM(
        .addr(image_addr),
        .data(image_data)
    );

endmodule

module image_rom(
    input logic  [16:0] addr,
    output logic [15:0] data
    );
    logic [15:0] rom[0:320*240-1];

    initial begin
        $readmemh("Lenna2.mem", rom);
    end

    assign data = rom[addr];
endmodule