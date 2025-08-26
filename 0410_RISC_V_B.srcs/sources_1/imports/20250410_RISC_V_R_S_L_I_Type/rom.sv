`timescale 1ns / 1ps

module rom (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] rom[0:15];

    initial begin
        //rom[x]=32'b fucn7 _ rs2 _ rs1 _f3 _ rd  _opcode; // R-Type

        /*rom[0] = 32'b0000000_00001_00010_000_00100_0110011; // add x4, x2, x1
        rom[1] = 32'b0100000_00001_00010_000_00101_0110011; // sub x5, x2, x1
        //rom[x]=32'b imm7  _ rs2_ rs1 _f3 _imm5 _ opcode; // B-Type
        rom[2] = 32'b0000000_00010_00010_000_01100_1100011; // beq x2, x2, 12 
        //rom[x]=32'b imm7  _ rs2 _ rs1 _f3 _ imm5_ opcode; // S-Type
        rom[3] = 32'b0000000_00010_00000_010_01000_0100011; // sw x2, 8(x0);
        //rom[x]=32'b imm12      _ rs1 _f3 _ rd  _ opcode; // L-Type
        rom[4] = 32'b000000001000_00000_010_00011_0000011; // lw x3, 8(x0);
        //rom[x]=32'b imm12      _ rs1 _f3 _ rd  _ opcode; // I-Type
        rom[5] = 32'b000000000001_00010_000_00001_0010011; // addi x6, x2, 8;
        rom[6] = 32'b0000000_00010_00001_001_00110_0010011; // slli x6, x1, 2; */
        rom[0] = 32'b00000000100000000000000101100111;
        rom[0] = 32'b00000000110000000000000101101111;
        //rom[0] = 32'b00000000000000001100000100110111;
        //rom[1] = 32'b00000000000000001100000100010111;
    end
    assign data = rom[addr[31:2]];
endmodule
