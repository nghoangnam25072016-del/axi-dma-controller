
`timescale 1ns/1ps

module dma_tb;

    // Clock & Reset
    logic clk;
    logic rst_n;

    // AXI signals
    logic [31:0] araddr;
    logic        arvalid;
    logic        arready;

    logic [31:0] rdata;
    logic        rvalid;
    logic        rready;

    // DUT instantiation
    dma_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .araddr(araddr),
        .arvalid(arvalid),
        .arready(arready),
        .rdata(rdata),
        .rvalid(rvalid),
        .rready(rready)
    );

    // =============================
    // Clock generation
    // =============================
    always #5 clk = ~clk;

    // =============================
    // Initial block
    // =============================
    initial begin
        clk = 0;
        rst_n = 0;

        arready = 0;
        rvalid  = 0;
        rdata   = 32'h0;

        #20;
        rst_n = 1;

        // Simulate AXI handshake
        #10;
        arready = 1;

        #10;
        arready = 0;

        #20;
        rvalid = 1;
        rdata  = 32'hDEADBEEF;

        #10;
        rvalid = 0;

        #50;
        $finish;
    end

    // =============================
    // Monitor
    // =============================
    initial begin
        $monitor("Time=%0t | arvalid=%0b arready=%0b rvalid=%0b rdata=%h",
                  $time, arvalid, arready, rvalid, rdata);
    end

endmodule
