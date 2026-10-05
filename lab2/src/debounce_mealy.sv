module debounce_mealy #(parameter int N = 3) (
    input  logic clk,
    input  logic reset,
    input  logic in,
    output logic out
);

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        WAIT = 2'b01
    } state_t;

    state_t state, next_state;

    logic start_delay;
    logic done_delay;

    delay #(.N(N)) u_delay (
        .clk   (clk),
        .reset (reset),
        .start (start_delay),
        .done  (done_delay)
    );

    always_comb begin
        next_state  = state;
        start_delay = 1'b0;

        case (state)
            IDLE: begin
                if (in) begin
                    next_state  = WAIT;
                    start_delay = 1'b1;
                end
            end

            WAIT: begin
                if (done_delay)
                    next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    assign out = (state == IDLE) && in;

endmodule