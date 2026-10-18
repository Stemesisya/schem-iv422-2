
module processor(
    input logic reset,
    input logic clk
);

    logic [31:0] PC;
    logic [31:0] PCPlus4;
    logic [31:0] instr;

    logic [31:0] reg1;
    logic [31:0] reg2;
    logic [31:0] signImm;

    logic [31:0] readData;

    logic       regWrite;
    logic       immsrc;
    logic [2:0] aluControl;
    logic       memWrite;

    assign PCPlus4 = PC + 3'd4;

    instr_memory instructions(
        .clk  (clk    ),
        .addr (PC[6:2]),
        .rdata(instr  )
    );

    register_file registers(
        .clk(clk),
        .rs1(instr[19:15]),
        .rs2(instr[24:20]),
        .rd (instr[11:7] ),
        .we(regWrite),
        .wd(readData),
        .rd1(reg1),
        .rd2(reg2)
    )

    zeroExtend ze(
        .in(instr[31:7]),
        .immsrc(immsrc),
        .out(signImm)
    )

    logic [31:0] aluResult;
    logic        zero;
    logic        negative;

    alu alu(
        .a(reg1),
        .rawb(signImm),
        .funcsel(aluControl),
        .result(aluResult),
        .isZero(zero),
        .isNegative(negative)
    )

    storage storage(
        .clk(clk),
        .addr(aluResult),
        .wdata(reg2),
        .rdata(readData),
        .we(memWrite)
    )

    always_ff @(posedge clk) begin
        if(reset == 1'b1)
            PC <= 0;
        else
            PC <= PCPlus4;
    end

endmodule