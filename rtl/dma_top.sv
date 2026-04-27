module dma_top (
    input  logic clk,
    input  logic rst_n,
    input logic start,
    input logic [7:0] length,
output logic busy,
output logic dma_done
   

    // AXI Read Address Channel
    output logic [31:0] araddr,
    output logic        arvalid,
    input  logic        arready,

    // AXI Read Data Channel
    input  logic [31:0] rdata,
    input  logic        rvalid,
    output logic        rready
);

// AXI Write Address Channel
output logic [31:0] awaddr,
output logic        awvalid,
input  logic        awready,

// AXI Write Data Channel
output logic [31:0] wdata,
output logic        wvalid,
input  logic        wready,

// AXI Write Response Channel
input  logic        bvalid,
output logic        bready

logic write_start;
logic write_done;

dma_write u_write (
    .clk(clk),
    .rst_n(rst_n),

    .start(write_start),
    .base_addr(32'h2000),
    .data_in(data_out),

    .awaddr(awaddr),
    .awvalid(awvalid),
    .awready(awready),

    .wdata(wdata),
    .wvalid(wvalid),
    .wready(wready),

    .bvalid(bvalid),
    .bready(bready),

    .done(write_done)
);
    
    // =============================
    // Internal signals
    // =============================
    logic [31:0] read_addr;
    logic        read_en;
logic read_start;
logic read_done;
logic write_start;
logic write_done;
    
    // =============================
    // Simple FSM
    // =============================
    typedef enum logic [1:0] {
        IDLE,
        SEND_ADDR,
        READ_DATA
    } state_t;

    state_t state, next_state;

    // =============================
    // State Register
    // =============================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // =============================
    // Next State Logic
    // =============================
    always_comb begin
        next_state = state;

        case (state)
            IDLE:
                if (read_en)
                    next_state = SEND_ADDR;

            SEND_ADDR:
                if (arready)
                    next_state = READ_DATA;

            READ_DATA:
                if (rvalid)
                    next_state = IDLE;
        endcase
    end

endmodule


// thêm vào phần always_comb / always_ff phù hợp
always_comb begin
    arvalid = (state == SEND_ADDR);
    rready  = (state == READ_DATA);
    araddr  = read_addr;
end

// tăng địa chỉ mỗi lần đọc xong
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        read_addr <= 32'h0;
    else if (state == READ_DATA && rvalid)
        read_addr <= read_addr + 32'd4;
end


logic start;
logic done;
logic [31:0] data_out;

dma_read u_read (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .base_addr(32'h1000),

    .araddr(araddr),
    .arvalid(arvalid),
    .arready(arready),

    .rdata(rdata),
    .rvalid(rvalid),
    .rready(rready),


    

    .data_out(data_out),
    .done(done)
);


dma_ctrl u_ctrl (
    .clk(clk),
    .rst_n(rst_n),

    .start(start),

    .read_start(read_start),
    .read_done(read_done),

    .write_start(write_start),
    .write_done(write_done),

    .busy(busy),
    .done(dma_done)
);
