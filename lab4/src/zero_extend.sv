module zeroExtend(
    input logic  [31:0] in,
    input logic  [1:0]  immSrc,
    output logic [31:0] out
);

always_comb begin
    // R has no Imm
    case (immSrc)
		2'b00: begin
			out = {{20{Instr[31]}}, Instr[31:20]}; // I
		end
		2'b01: begin
            out = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]}; // S
		end
		2'b10: begin
            out = {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0}; // B
		end
		2'b11: begin
            out = {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0}; // J
		end
	endcase
end

endmodule