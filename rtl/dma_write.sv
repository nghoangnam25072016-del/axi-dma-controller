module dma_write (
    input  logic        clk,
    input  logic        rst_n,

    input  logic        start,
    input  logic [31:0] base_addr,
    input  logic [31:0] data_in,

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
    output logic        bready,

    output logic        done
);

    typedef enum logic [1:0] {
        IDLE,
        SEND_AW_W,
        WAIT_RESP
    } state_t;

    state_t state, next;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next;
    end

    always_comb begin
        next = state;

        case (state)
            IDLE:
                if (start)
                    next = SEND_AW_W;

            SEND_AW_W:
                if (awready && wready)
                    next = WAIT_RESP;

            WAIT_RESP:
                if (bvalid)
                    next = IDLE;
        endcase
    end

    always_comb begin
        awaddr  = base_addr;
        awvalid = (state == SEND_AW_W);

        wdata   = data_in;
        wvalid  = (state == SEND_AW_W);

        bready  = (state == WAIT_RESP);
        done    = (state == WAIT_RESP && bvalid);
    end

endmodule
