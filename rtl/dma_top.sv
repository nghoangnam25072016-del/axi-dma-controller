module dma_top (
    input  logic clk,
    input  logic rst_n,

    // AXI Read Address Channel
    output logic [31:0] araddr,
    output logic        arvalid,
    input  logic        arready,

    // AXI Read Data Channel
    input  logic [31:0] rdata,
    input  logic        rvalid,
    output logic        rready
);

    // =============================
    // Internal signals
    // =============================
    logic [31:0] read_addr;
    logic        read_en;

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
