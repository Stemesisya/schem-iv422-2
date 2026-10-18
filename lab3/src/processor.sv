
module processor(
    input  logic clk
);

logic PC[4:0];
logic PCPlus4[4:0];
logic instr[31:0];

assign PCPlus4 = PC + 4;

storage instructions(clk, .we(0), .addr(PC), .wdata(1'x), .rdata(instr));

endmodule