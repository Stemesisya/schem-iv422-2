module proc_fetch_testbench();

    logic clk;
    logic reset;

    logic [31:0] instr, instExpected;
    logic [31:0] testIndex, errors;
    logic [31:0] testvectors [200:0];

    processor proc (.reset(reset), .clk(clk));

    assign instr = proc.instr;

    initial begin
        $readmemh ("instructions.dat", testvectors);
        testIndex =0;
        errors=0;
        reset=1;
    end

    always begin
        clk <= 1; #5; clk<=0; #5;
    end

    always @ (posedge clk) begin
		#1; {instExpected} = testvectors [testIndex];
	end

    always @(negedge clk) begin
        reset = 0;
        if (instr!==instExpected) begin
            $display("Error result: inputs = PC:%x", proc.PC);
            $display(" result = %x (%x expected)", instr, instExpected);
            errors = errors+1;
        end
        testIndex++;
        if (testvectors[testIndex]===32'bx) begin
            $display("%d tests completed with %d errors", testIndex, errors);
            $stop;
        end
	end

endmodule