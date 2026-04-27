
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
    logic [31:0] awaddr;
logic        awvalid;
logic        awready;

logic [31:0] wdata;
logic        wvalid;
logic        wready;

logic        bvalid;
logic        bready;

    logic start;
logic busy;
logic dma_done;
    

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
        .awaddr(awaddr),
.awvalid(awvalid),
.awready(awready),

.wdata(wdata),
.wvalid(wvalid),
.wready(wready),

.bvalid(bvalid),
        .bready(bready),
        .start(start),
.busy(busy),
        .dma_done(dma_done)
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
awready = 0;
wready  = 0;
bvalid  = 0;
        
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
        
// Write address + data ready
#20;
awready = 1;
wready  = 1;

#10;
awready = 0;
wready  = 0;

// Write response
#20;
bvalid = 1;

#10;
bvalid = 0;
        start = 0;

#20;
rst_n = 1;

#10;
start = 1;

#10;
start = 0;
        
    end

    // =============================
    // Monitor
    // =============================
    initial begin
        $monitor("Time=%0t | arvalid=%0b arready=%0b rvalid=%0b rdata=%h",
                  $time, arvalid, arready, rvalid, rdata);
    end

endmodule


logic test_pass;

initial begin
    test_pass = 1;

    // sau khi rvalid
    #100;
    if (rdata !== 32'hDEADBEEF) begin
        $display("TEST FAIL: Wrong data");
        test_pass = 0;
    end

    #10;
    if (test_pass)
        $display("TEST PASS");
    else
        $display("TEST FAILED");

    $finish;
end


initial begin
    clk = 0;
    rst_n = 0;
    #20;
    rst_n = 1;

    // ready address
    #10 arready = 1;
    #10 arready = 0;

    // data response
    #20;
    rvalid = 1;
    rdata  = 32'hCAFEBABE;

    #10 rvalid = 0;

    #50 $finish;
end


always @(posedge clk) begin
    if (rvalid) begin
        if (rdata !== 32'hCAFEBABE)
            $display("FAIL");
        else
            $display("PASS");
    end
end


always @(posedge clk) begin
    if (awvalid && awready) begin
        if (awaddr == 32'h2000)
            $display("WRITE ADDRESS PASS: awaddr=%h", awaddr);
        else
            $display("WRITE ADDRESS FAIL: awaddr=%h", awaddr);
    end

    if (wvalid && wready) begin
        if (wdata == 32'hCAFEBABE)
            $display("WRITE DATA PASS: wdata=%h", wdata);
        else
            $display("WRITE DATA FAIL: wdata=%h", wdata);
    end

    if (bvalid && bready) begin
        $display("WRITE RESPONSE PASS");
    end
end

always @(posedge clk) begin
    if (dma_done)
        $display("DMA END-TO-END PASS");
end
