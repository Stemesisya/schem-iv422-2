
module processor(
    input logic reset,
    input logic clk
);

    logic [31:0] PC;
    logic [31:0] PCPlus4;

    assign PCPlus4 = PC + 3'd4;

    logic [31:0] instr;

    instr_memory instructions(
        .clk   (clk    ),
        .addr  (PC[6:2]),
        .rdata (instr  )
    );

    logic       regWrite;
    logic       immSrc;
    logic [2:0] aluControl;
    logic       memWrite;

    controller controller(
        .opcode     (instr[0:6]),
        .regWrite   (regWrite  ),
        .memWrite   (memWrite  ),
        .aluControl (aluControl),
        .immSrc     (immSrc    )
    )

    logic [31:0] reg1;
    logic [31:0] reg2;
    logic [31:0] readData;

    register_file registers(
        .clk (clk         ),
        .rs1 (instr[19:15]),
        .rs2 (instr[24:20]),
        .rd  (instr[11:7] ),
        .we  (regWrite    ),
        .wd  (readData    ),
        .rd1 (reg1        ),
        .rd2 (reg2        )
    )

    logic [31:0] signImm;

    zeroExtend ze(
        .in     (instr[31:7]),
        .immSrc (immSrc     ),
        .out    (signImm    )
    )

    logic [31:0] aluResult;
    logic        zero;
    logic        negative;

    alu alu(
        .a          (reg1      ),
        .rawb       (signImm   ),
        .funcsel    (aluControl),
        .result     (aluResult ),
        .isZero     (zero      ),
        .isNegative (negative  )
    )

    storage storage(
        .clk   (clk      ),
        .addr  (aluResult),
        .wdata (reg2     ),
        .rdata (readData ),
        .we    (memWrite )
    )

    always_ff @(posedge clk) begin
        if(reset == 1'b1)
            PC <= 0;
        else
            PC <= PCPlus4;
    end

endmodule