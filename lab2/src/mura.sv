module mura (
    input clk, reset, in,
    output out
);

logic [2:0] timer;

typedef enum logic [1:0] { s0, s1, s2 } statetype;
statetype state, nextstate;

always_comb begin
    case (state)
    s0: if (in == 1) nextstate = s1;
        else nextstate = s0;
    s1: if (reset == 0) nextstate = s2;
    s2: if (timer == 3'b111) nextstate = s0;
    endcase
end

always_ff @( posedge clk ) begin
    if (reset) begin
        state = s0;
        timer = 0;
    end
    else state = nextstate;

    if(state == s2) begin
        timer++;
    end
end

assign out = (state == s1);

endmodule