module controller (
    input logic       clk,
    input logic       reset, 
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic        zero,

    output logic       PCWrite,
    output logic       addrSrc,
    output logic       memWrite,
    output logic       IRWrite,

    output logic [1:0] resultSrc,
    output logic [2:0] aluControl,
    output logic [1:0] aluSrcA,
    output logic [1:0] aluSrcB,
    output logic [1:0] immSrc,
    output logic       regWrite
);

    logic aluOp;
    logic branch;
    logic PCUpdate;

    assign PCWrite = (zero & branch) | PCUpdate;

    localparam logic [6:0] R_FUNC = 7'h33;
    localparam logic [6:0] OP_LOAD  = 7'h03;
    localparam logic [6:0] OP_STORE = 7'h23;
    localparam logic [6:0] OP_BREQ  = 7'h63;
    localparam logic [6:0] OP_JAL   = 7'h6F;

    

    logic [3:0] state, nextstate;

    aluDecoder aluDecoder(
        .aluOp      (aluOp     ),
        .funct3     (funct3    ),
        .funct7     (funct7    ),
        .aluControl (aluControl)
    );
    opDecoder opDecoder(
        .opcode (opcode),
        .immSrc (immSrc)
    );

    always_ff @( posedge clk ) begin
        if (reset)
            state = 0;
        else
            state = nextstate;
    end
    
    always_comb begin
        PCUpdate = 0;
        IRWrite  = 0;
        memWrite = 0;
        regWrite = 0;
        branch   = 0;

        case (state)
            0: begin // Fetch
                addrSrc   = 0;
                IRWrite   = 1;
                aluSrcA   = 2'b00;
                aluSrcB   = 2'b10;
                aluOp     = 2'b00;
                resultSrc = 2'b10;
                PCUpdate  = 1;
                nextstate = 1;
            end
            1: begin // Decode
                aluSrcA   = 2'b01;
                aluSrcB   = 2'b01;
                aluOp     = 2'b00;
                case(opcode)
                    OP_LOAD, OP_STORE:
                        nextstate = 2;
                    R_FUNC:
                        nextstate = 6;
                    OP_BREQ:
                        nextstate = 10;
                endcase
            end
            2: begin // MemAddr
                aluSrcA   = 2'b10;
                aluSrcB   = 2'b01;
                aluOp     = 2'b00;
                if(opcode == OP_LOAD)
                    nextstate = 3;
                else
                    nextstate = 5;
            end
            3: begin // MemRead
                resultSrc = 2'b00;
                addrSrc   = 1;
                nextstate = 4;
            end
            4: begin // MemWB
                resultSrc = 2'b01;
                regWrite  = 1;
                nextstate = 0;
            end
            5: begin // MemWrite
                resultSrc = 2'b00;
                addrSrc   = 1;
                memWrite  = 1;
                nextstate = 0;
            end
            6: begin // ExecuteR
                aluSrcA   = 2'b10;
                aluSrcB   = 2'b00;
                aluOp     = 2'b10;
                nextstate = 7;
            end
            7: begin // ALUWB
                resultSrc = 2'b00;
                regWrite  = 1;
                nextstate = 0;
            end
            10: begin // BEQ
                aluSrcA   = 2'b10;
                aluSrcB   = 2'b00;
                aluOp     = 2'b01;
                resultSrc = 2'b00;
                branch    = 1;
                nextstate = 0;
            end
        endcase
    end

endmodule



module aluDecoder(
    input logic [1:0] aluOp,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    output logic [2:0] aluControl
);
    localparam logic [2:0] ALU_AND  = 3'b000;
    localparam logic [2:0] ALU_OR   = 3'b001;
    localparam logic [2:0] ALU_ADD  = 3'b010;
    localparam logic [2:0] ALU_SUB  = 3'b110;
    localparam logic [2:0] ALU_SLT  = 3'b111;

    always_comb begin
        case(aluOp)
            2'b00: aluControl = 3'b000;
            2'b01: aluControl = 3'b100;
            2'b10: begin
                case (funct3)
                    3'h0: aluControl = funct7 == 7'h0 ? ALU_ADD : ALU_SUB;
                    3'h7: aluControl = ALU_AND;
                    3'h6: aluControl = ALU_OR;
                    3'h2: aluControl = ALU_SLT;
                endcase
            end
        endcase
    end
endmodule

module opDecoder(
    input  logic [6:0] opcode,
    output logic [1:0] immSrc,
);

    localparam logic [6:0] R_FUNC = 7'h33;
    localparam logic [6:0] OP_LOAD  = 7'h03;
    localparam logic [6:0] OP_STORE = 7'h23;
    localparam logic [6:0] OP_BREQ  = 7'h63;
    localparam logic [6:0] OP_JAL   = 7'h6F;

    always_comb begin
        case (opcode)
            OP_LOAD:
                immSrc = 0;
            OP_STORE:
                immSrc = 1;
            R_FUNC:
                immSrc = 2'bxx;
            OP_BREQ:
                immSrc = 2;
            OP_JAL:
                immSrc = 3;
        endcase
    end
endmodule