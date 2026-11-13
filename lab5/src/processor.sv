
module processor(
    input logic reset,
    input logic clk
);

	logic [31:0] result;

    logic PCWrite;
    logic addrSrc;
    logic memWrite;
    logic IRWrite;

    logic [31:0] PC;

    logic [31:0] addr;
    assign addr = addrSrc == 1'b1? result : PC;
    
    logic [31:0] readData;
    logic [31:0] writeData;
    storage storage(
        .clk   (clk      ),
        .addr  (addr[9:2]),
        .wdata (writeData),
        .rdata (readData ),
        .we    (memWrite )
    );

    logic [31:0] oldPC;
    logic [31:0] instr;
    logic [31:0] data;

    logic        zero;
	logic [1:0] resultSrc;
    logic [2:0] aluControl;
    logic [1:0] aluSrcB;
    logic [1:0] aluSrcA;
    logic [1:0] immSrc;
    logic       regWrite;

    controller controller(
        .opcode     (instr[6:0]  ),
        .funct3     (instr[14:12]),
        .funct7     (instr[31:25]),
        .zero       (zero        ),

        .PCWrite    (PCWrite     ),
        .addrSrc    (addrSrc     ),
        .memWrite   (memWrite    ),
        .IRWrite    (IRWrite     ),

        .resultSrc  (resultSrc   ),
        .aluControl (aluControl  ),
        .aluSrcA    (aluSrcA     ),
        .aluSrcB    (aluSrcB     ),
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
        .wd  (result      ),
        .rd1 (rd1         ),
        .rd2 (rd2         )
    );

    logic [31:0] a;
    logic [31:0] srcA;
    assign srcA = aluSrcA == 2'b00 ? pc : (aluSrcA == 2'b01? oldPC : a);

    logic [31:0] immExt;

    zeroExtend ze(
        .in     (instr   ),
        .immSrc (immSrc  ),
        .out    (immExt )
    );

    logic srcB [31:0];
    assign srcB = aluSrcB == 2'b00? writeData : (aluSrcB == 2'b01? immExt : 32'b100);

    logic [31:0] aluResult;


    alu alu(
        .a          (srcA      ),
        .rawb       (srcB      ),
        .funcsel    (aluControl),
        .result     (aluResult ),
        .isZero     (zero      )
    );

    logic [31:0] aluOut;

    assign result = resultSrc == 2'b00? aluOut : (resultSrc == 2'b01? data : aluResult);

    always_ff @(posedge clk) begin
        if(reset == 1'b1)
            PC <= 0;
        else if(PCWrite == 1'b1)
            PC <= result;

        if(IRWrite == 1'b1) begin
            oldPC <= PC;
            instr <= readData;
        end

        data <= readData;
        a <= rd1;
        writeData <= rd2;
        aluOut <= aluResult;
    end

endmodule