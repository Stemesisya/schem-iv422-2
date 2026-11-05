module controller (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    input logic        zero,

    output logic       PCSrc,
    output logic [1:0] resultSrc,
    output logic       memWrite,
    output logic [2:0] aluControl,
    output logic       aluSrc,
    output logic       immSrc
    output logic       regWrite,
);

    logic branch;
    logic jump;

    assign PCSrc = (zero & branch) | jump;

    localparam logic [6:0] R_FUNC = 7'h33;

    localparam logic [6:0] OP_LOAD  = 7'h03;
    localparam logic [6:0] OP_STORE = 7'h23;
    localparam logic [6:0] OP_BREQ  = 7'h63;
    localparam logic [6:0] OP_JAL   = 7'h6F;

    localparam logic [2:0] ALU_AND  = 3'b000;
    localparam logic [2:0] ALU_OR   = 3'b001;
    localparam logic [2:0] ALU_ADD  = 3'b010;
    localparam logic [2:0] ALU_SUB  = 3'b110;
    localparam logic [2:0] ALU_SLT  = 3'b111;

    always_comb begin
        branch     = 0;
        jump       = 0;
        resultSrc  = 1;
        memWrite   = 0;
        aluControl = ALU_ADD;
        aluSrc     = 1;
        immSrc     = 1;
        regWrite   = 0;

        case (opcode)
            OP_LOAD: begin
                regWrite = 1;
                immSrc   = 0;
                aluSrc = 1;
                memWrite = 0;
                resultSrc = 2'b01;
                aluControl = ALU_ADD;
            end

            OP_STORE: begin
                regWrite = 0;
                immSrc   = 2'b01;
                aluSrc = 1;
                memWrite = 1;
                resultSrc = 2'bxx;
                aluControl = ALU_ADD;
            end

            R_FUNC: begin
                regWrite = 1;
                immSrc = 2'bxx;
                aluSrc = 0;
                memWrite = 0;
                resultSrc =2'b00;
                case (funct3)
                    3'h0: aluControl = funct7 == 7'h0 ? ALU_ADD : ALU_SUB;
                    3'h7: aluControl = ALU_AND;
                    3'h6: aluControl = ALU_OR;
                    3'h2: aluControl = ALU_SLT;
                endcase
            end
            OP_BREQ: begin
                regWrite   = 0;
                immSrc     = 2'b10;
                aluSrc     = 0;
                memWrite   = 0;
                resultSrc  = 2'bxx;
                branch     = 1;
                aluControl = ALU_SUB;
            end
            OP_JAL: begin
                regWrite = 1;
                immSrc   = 2'b11;
                aluSrc = 1'bx;
                memWrite = 0;
                resultSrc = 2'b10;
                aluControl = ALU_ADD;
                jump = 1;
            end
        endcase
    end

endmodule