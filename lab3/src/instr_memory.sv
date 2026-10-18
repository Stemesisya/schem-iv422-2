module instr_memory (
    input  logic        clk,
    input  logic [4:0]  addr,
    output logic [31:0] rdata
);

    logic [31:0] mem [31:0];

    assign rdata = mem[addr];

    initial begin
        $readmemh("instructions.dat", mem);
    end

endmodule
