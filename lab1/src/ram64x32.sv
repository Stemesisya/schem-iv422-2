module ram64x32 (
    input  logic        clk,
    input  logic        we,
    input  logic [5:0]  addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata
);

    logic [31:0] mem [63:0];

    // Асинхронное чтение
    assign rdata = mem[addr];

    // Синхронная запись по переднему фронту clk
    always_ff @(posedge clk) begin
        if (we)
            mem[addr] <= wdata;
    end

endmodule
