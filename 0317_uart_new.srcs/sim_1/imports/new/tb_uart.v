module tb_TOP_UART;
    reg clk;
    reg rst;
    reg rx;
    wire tx;
    wire [7:0] seg;
    wire [3:0] ans;

    // Instantiate the top module
    TOP_UART uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .seg(seg),
        .ans(ans)
    );

    // Clock generation
    always begin
        clk = 0;
        #5 clk = 1; // 100 MHz clock
    end

    // Initial block for simulation
    initial begin
        // Initialize signals
        rst = 0;
        rx = 1;  // Idle state for rx is high

        // Reset the system
        #10 rst = 1;
        #10 rst = 0;

        // Start sending data through rx with proper delays
        // Simulating UART data reception (start bit, data bits, stop bit)

        // Wait for 1 baud tick (about 65.1 µs) before changing rx signal
        #104170;

        // Start bit (0)
        rx = 0;  // Start bit
        #104170;      // Wait for 1 baud period

        // Send data (let's say we're sending 'A' (0x41))
        rx = 1; #104170;  // Bit 0 (1)
        rx = 0; #104170;  // Bit 1 (0)
        rx = 0; #104170;  // Bit 2 (0)
        rx = 0; #104170;  // Bit 3 (0)
        rx = 0; #104170;  // Bit 4 (1)
        rx = 1; #104170;  // Bit 5 (0)
        rx = 0; #104170;  // Bit 6 (0)
        rx = 1; #104170;  // Bit 7 (1)

        // Stop bit (1)
        rx = 1;  #104170;  // Stop bit

        // End of transmission
        #100;
        $finish;
    end

endmodule
