module alu(
    input logic [31:0] a, rawb,
    input logic [2:0] funcsel,
    output logic [31:0] result,
    output logic isZero
);

    logic [31:0] b, sum, sltResult;
    assign b = funcsel[2]? ~rawb : rawb;
    assign sum = funcsel[2]? a + b + 1 : a + b;
    assign sltResult = 32'b0 | sum[31];

    // funcsel values:
    // 000 A & B
    // 001 A | B
    // 010 A + B
    // 011 <nothing>
    // 100 A & ~B
    // 101 A | ~B
    // 110 A - B
    // 111 A < B ?

    always_comb begin
        case (funcsel[1:0])
            2'b00: result = a & b;
            2'b01: result = a | b;
            2'b10: result = sum;
            2'b11: result = funcsel[2]? sltResult : 32'bx;
        endcase

        isZero = (result === 32'b0) ? 1'b1 : 0'b0;
    end

endmodule