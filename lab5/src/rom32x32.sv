module rom32x32 (
    input  logic [4:0]  addr,
    output logic [31:0] rdata
);

    logic [31:0] mem [31:0];

    // Инициализация из файла с ПОЛНЫМ ПУТЁМ
    initial begin
        $readmemh("memfile.dat", mem, 0, 31);
    end

    assign rdata = mem[addr];

endmodule
