module zeroExtend(
    input logic [24:0] in,
    input logic immSrc,
    output logic [31:0] out
);

always_comb begin
    out = 32'b0;
    out[31:11] = {20{in[24]}};
    out[11:5] = in[24:18];
    out[4:0] = in[4:0];
end

assign out = (immSrc) ? 32'b0 | in[24:12] : 32'b0 | in[24:17] | in[];

endmodule