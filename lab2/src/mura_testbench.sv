module mura_testbench();

    logic clk, reset, in, out;

    logic outExpected;
    logic [31:0] testIndex, errors;
    logic [2:0] testvectors [200:0];

    mura timer (clk, reset, in, out);

    initial begin
        reset = 1;
        in = 0;
        out = 0;

        $readmemb ("mura_vectors.txt", testvectors);
        testIndex =0;
        errors=0;
    end

    always begin
        clk <= 1; #5; clk<=0; #5;
    end

    always @ (posedge clk) begin
		#1; {reset, in, outExpected} = testvectors [testIndex];
	end

    always @(negedge clk) begin
        if (out!==outExpected) begin
            $display("Error result: inputs = reset:%b, in:%b", reset, in);
            $display(" result = %b (%b expected)", out, outExpected);
            errors = errors+1;
        end
        testIndex++;
        if (testvectors[testIndex]===3'bx) begin
            $display("%d tests completed with %d errors", testIndex, errors);
            $stop;
        end
	end

endmodule