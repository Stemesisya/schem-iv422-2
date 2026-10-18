
module processor(
    input logic reset,
    input logic clk
);

    logic [31:0] PC;
    logic [31:0] PCPlus4;
    logic [31:0] instr;

    assign PCPlus4 = PC + 3'd4;

    instr_memory instructions(
        .clk(clk),
        .addr(PC[6:2]),
        .rdata(instr)
    );

    always_ff @(posedge clk) begin
        if(reset == 1'b1)
            PC <= 0;
        else
            PC <= PCPlus4;
    end

endmodule