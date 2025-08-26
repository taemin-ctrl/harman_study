`timescale 1ns / 1ps

module ram(
    ram_intf intf
    );

    logic [7:0] mem[0:2**5-1];

    initial begin
        foreach (mem[i]) mem[i] = 0;
    end
    
    always_ff @( posedge intf.clk ) begin 
        if (intf.we) begin
            mem[intf.addr] <= intf.wData;
        end
    end

    assign intf.rData = mem[intf.addr];
endmodule
