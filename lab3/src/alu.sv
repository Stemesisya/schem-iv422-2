module alu(
    input logic [31:0] a, rawb,
    input logic [2:0] funcsel,
    output logic [31:0] result,
    output logic isZero, isNegative
);

    logic [3:0] b;
    assign b = funcsel[2]? ~rawb : rawb;

    logic [3:0] sum;

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
            2'b10: result = funcsel[2]? a + b + 1 : a + b;
            2'b11: result = funcsel[2]? /*TODO*/ 32'bx : 32'bx;
        endcase

        isZero = (result === 32'b0) ? 1'b1 : 0'b0;
        isNegative = result[31];
    end

endmodule