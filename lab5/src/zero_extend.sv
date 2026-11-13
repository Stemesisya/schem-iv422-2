module zeroExtend(
    input logic  [31:0] in,
    input logic  [1:0]  immSrc,
    output logic [31:0] out
);

always_comb begin
    // R has no Imm
    case (immSrc)
		2'b00: begin
			out = {{20{in[31]}}, in[31:20]}; // I
		end
		2'b01: begin
            out = {{20{in[31]}}, in[31:25], in[11:7]}; // S
		end
		2'b10: begin
            out = {{20{in[31]}}, in[7], in[30:25], in[11:8], 1'b0}; // B
		end
		2'b11: begin
            out = {{12{in[31]}}, in[19:12], in[20], in[30:21], 1'b0}; // J
		end
	endcase
end

endmodule