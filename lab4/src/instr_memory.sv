module instr_memory (
    input  logic        clk,
    input  logic [7:0]  addr,
    output logic [31:0] rdata
);

    logic [31:0] mem [255:0];

    assign rdata = mem[addr];

    initial begin
        $readmemh("instructions.dat", mem);
    end

endmodule
