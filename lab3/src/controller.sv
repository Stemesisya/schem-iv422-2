module controller (
    input  logic [6:0] opcode,

    output logic       regWrite,
    output logic       memWrite,
    output logic [2:0] aluControl,
    output logic       immSrc
);

    localparam logic [6:0] OP_LOAD  = 7'h03;
    localparam logic [6:0] OP_STORE = 7'h23;

    localparam logic [2:0] ALU_ADD  = 3'b010;

    always_comb begin
        regWrite   = 0;
        memWrite   = 0;
        aluControl = ALU_ADD;
        immSrc     = 1;

        case (opcode)
            OP_LOAD: begin
                regWrite = 1;
                memWrite = 0;
                immSrc   = 0;
            end

            OP_STORE: begin
                regWrite = 0;
                memWrite = 0;
                immSrc   = 1;
            end
        endcase
    end

endmodule