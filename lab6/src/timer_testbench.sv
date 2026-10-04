module timer_testbench();

    logic clk, reset, start, done;

    logic doneExpected;
    logic [31:0] testIndex, errors;
    logic [2:0] testvectors [200:0];

    timer timer (clk, reset, start, done);

    initial begin
        reset = 1;
        start = 0;
        done = 0;

        $readmemb ("timer_vectors.txt", testvectors);
        testIndex =0;
        errors=0;
    end

    always begin
        clk <= 1; #5; clk<=0; #5;
    end

    always @ (posedge clk) begin
		#1; {reset, start, doneExpected} = testvectors [testIndex];
	end

    always @(negedge clk) begin
        if (done!==doneExpected) begin
            $display("Error result: inputs = reset:%b, start:%b", reset, start);
            $display(" result = %b (%b expected)", done, doneExpected);
            errors = errors+1;
        end
        testIndex++;
        if (testvectors[testIndex]===3'bx) begin
            $display("%d tests completed with %d errors", testIndex, errors);
            $stop;
        end
	end

endmodule