
module dma_read (
    input  logic clk,
    input  logic rst_n,
    input logic [7:0] index

    // control
    input  logic        start,
    input  logic [31:0] base_addr,

    // AXI Read Address
    output logic [31:0] araddr,
    output logic        arvalid,
    input  logic        arready,

    // AXI Read Data
    input  logic [31:0] rdata,
    input  logic        rvalid,
    output logic        rready,

    // output to ctrl/top
    output logic [31:0] data_out,
    output logic        done
);

    typedef enum logic [1:0] {IDLE, SEND_ADDR, WAIT_DATA} state_t;
    state_t state, next;

    // state
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= IDLE;
        else        state <= next;
    end

    // next
    always_comb begin
        next = state;
        case (state)
            IDLE:       if (start)   next = SEND_ADDR;
            SEND_ADDR:  if (arready) next = WAIT_DATA;
            WAIT_DATA:  if (rvalid)  next = IDLE;
        endcase
    end

    // outputs
    always_comb begin
        arvalid  = (state == SEND_ADDR);
        rready   = (state == WAIT_DATA);
        araddr = base_addr + (index * 4);
        data_out = rdata;
        done     = (state == WAIT_DATA && rvalid);
    end

.start(read_start),
.done(read_done)

endmodule
