module ram32x32 (
    input  logic        clk,
    input  logic        we,
    input  logic [4:0]  addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata
);

    logic [31:0] mem [31:0];

    // Инициализация из файла
    initial begin
        $readmemh("memfile.dat", mem, 0, 31);
    end

    assign rdata = mem[addr];

    always_ff @(posedge clk) begin
        if (we)
            mem[addr] <= wdata;
    end

endmodule
