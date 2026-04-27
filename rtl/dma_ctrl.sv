module dma_ctrl (
    input  logic clk,
    input  logic rst_n,

    input  logic start,

    output logic read_start,
    input  logic read_done,

    output logic write_start,
    input  logic write_done,

    output logic busy,
    output logic done
);

    typedef enum logic [1:0] {
        IDLE,
        READ,
        WRITE,
        DONE
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
                    next = READ;

            READ:
                if (read_done)
                    next = WRITE;

            WRITE:
                if (write_done)
                    next = DONE;

            DONE:
                next = IDLE;
        endcase
    end

    always_comb begin
        read_start  = (state == READ);
        write_start = (state == WRITE);
        busy        = (state != IDLE);
        done        = (state == DONE);
    end

endmodule
