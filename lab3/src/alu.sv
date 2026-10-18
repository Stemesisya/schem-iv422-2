module alu_bit_adder (
    input logic a, b, c_in,
    output logic sum, c_out
);
    assign sum = a ^ b ^ c_in;
    assign c_out = (a & b) || (c_in & (a || b));
endmodule

module alu_adder(
    input logic [3:0] a, b,
    input logic c_in,
    output logic[3:0] sum,
    output logic overflow
);
    logic c_out0, c_out1, c_out2;
    alu_bit_adder a1(.sum(sum[0]), .c_out(c_out0),  .a(a[0]), .b(b[0]), .c_in(c_in));
    alu_bit_adder a2(.sum(sum[1]), .c_out(c_out1),  .a(a[1]), .b(b[1]), .c_in(c_out0));
    alu_bit_adder a3(.sum(sum[2]), .c_out(c_out2),  .a(a[2]), .b(b[2]), .c_in(c_out1));
    alu_bit_adder a4(.sum(sum[3]), .c_out(overflow),  .a(a[3]), .b(b[3]), .c_in(c_out2));
endmodule


module alu_zeroExtend(
    input logic in,
    output logic [3:0] out
);
    assign out = 4'b0000 | in;
endmodule


module alu(
    input logic [3:0] a, rawb,
    input logic [2:0] funcsel,
    output logic [3:0] result,
    output logic overflow, isZero, isNegative
);

    logic [3:0] b;
    assign b = funcsel[2]? ~rawb : rawb;

    logic [3:0] sum;
    adder adderr(.a(a), .b(b), .sum(sum), .overflow(overflow), .c_in(funcsel[2]));

    logic [3:0] sltResult;
    zeroExtend ze(.in(sum[2]), .out(sltResult));

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
                2'b11: result = funcsel[2]? sltResult : 4'bxxxx;

        endcase

        isZero = (result === 4'b0000) ? 1'b1 : 0'b0;
        isNegative = result[3];
    end

endmodule