
module processor(
    input logic reset,
    input logic clk
);

	logic [31:0] PCTarget;
    logic [31:0] PC;
    logic [31:0] PCPlus4;

    assign PCPlus4 = PC + 3'd4;

    logic [31:0] instr;

    instr_memory instructions(
        .clk   (clk    ),
        .addr  (PC[9:2]),
        .rdata (instr  )
    );

	logic       PCSrc;
	logic [1:0] resultSrc;
    logic       memWrite;
    logic [2:0] aluControl;
    logic       aluSrc;
    logic [1:0] immSrc;
    logic       regWrite;

    controller controller(
        .opcode     (instr[6:0]  ),
        .funct3     (instr[14:12]),
        .funct7     (instr[30:0] ),
        .PCSrc      (PCSrc       ),
        .resultSrc  (resultSrc   ),
        .memWrite   (memWrite    ),
        .aluControl (aluControl  ),
        .aluSrc     (aluSrc      ),
        .immSrc     (immSrc      ),
        .regWrite   (regWrite    )
    );

    logic [31:0] rd1;
    logic [31:0] rd2;
	logic [31:0] result;

    register_file registers(
        .clk (clk         ),
        .rs1 (instr[19:15]),
        .rs2 (instr[24:20]),
        .rd  (instr[11:7] ),
        .we  (regWrite    ),
        .wd  (readData    ),
        .rd1 (rd1        ),
        .rd2 (rd2        )
    );

    logic [31:0] signImm;

    zeroExtend ze(
        .in     (instr[31:7]),
        .immSrc (immSrc     ),
        .out    (signImm    )
    );

    assign PCTarget = PC + signImm;

    logic [31:0] srcB
    logic [31:0] aluResult;
    logic        zero;
    logic        negative;

    assign srcB = ALUSrc ? signImm : rd2

    alu alu(
        .a          (rd1       ),
        .rawb       (srcB      ),
        .funcsel    (aluControl),
        .result     (aluResult ),
        .isZero     (zero      ),
        .isNegative (negative  )
    );

    logic [31:0] readData;

    storage storage(
        .clk   (clk      ),
        .addr  (aluResult[6:2]),
        .wdata (rd2     ),
        .rdata (readData ),
        .we    (memWrite )
    );

    assign Result = ResultSrc == 0 ? aluResult : (resultSrc == 1 ? readData : PCPlus4 )

    always_ff @(posedge clk) begin
        if(reset == 1'b1)
            PC <= 0;
        else
            PC <= PCSrc ? PCPlus4 : PCTarget;
    end

endmodule