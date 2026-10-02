module timer (
    input clk, reset, start
    output done
);

logic [2:0] timer;

typedef enum logic [1:0] { s0, s1, s2 } statetype;
statetype state, nextstate;

always_comb begin
    case (state)
    s0: if (start == 1) nextstate = s1;
        else nextstate = s0;
    s1: if (reset == 0) nextstate = s2;
    s2: if (reset == 0) nextstate = s2;
    endcase
end

always_ff @( posedge clk ) begin
    if (reset) state = s0;
    else state = nextstate;

    if(state == s1) {
        timer++;
        if(timer == '3b111')
            state = s2;
    }
end

assign done = (state == s2);

endmodule