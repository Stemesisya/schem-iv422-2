module dmem(
    input logic clk, we,
    input logic [5:0] a,
    input logic [31:0] wd,
    output logic [31:0] rd
);

logic [31:0] RAM[31:0];

assign rd = RAM[a[5:0]];

always_ff @(posedge clk)
    if (we) RAM[a[5:0]] <= wd;
    
endmodule