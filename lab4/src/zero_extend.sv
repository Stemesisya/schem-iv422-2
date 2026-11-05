module zeroExtend(
    input logic [24:0] in,
    input logic immSrc,
    output logic [31:0] out
);

always_comb begin
    out = 32'b0;
    if(immSrc == 1'b1) begin
        out[31:12] = {20{in[24]}};
        out[11:5] = in[24:18];
        out[4:0] = in[4:0];
    end else begin
        out[31:12] = {20{in[24]}};
        out[11:0] = in[24:13];
    end
end

endmodule