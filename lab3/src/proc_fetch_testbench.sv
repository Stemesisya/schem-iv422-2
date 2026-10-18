module testbench();

    logic clk, memcheckClk;
    logic reset;
    logic [2:0] state;

    logic complete;

    logic [4:0] regAddr;
    logic [31:0] regg, mem, memExpected;
    logic [31:0] testIndex, errors;
    logic [31:0] testvectors [200:0];

    processor proc (.reset(reset), .clk(clk));

    assign mem = proc.storage.mem[testIndex];
    assign regg = proc.registers.regs[regAddr];

    initial begin
        $readmemh ("ramExpected.dat", testvectors);
        testIndex =0;
        errors=0;
        reset=1;
        state = 0;
        complete = 1;
    end

    always begin
        if(complete) begin
            clk <= 1; #5; clk<=0; #5;
        end else begin
            memcheckClk <= 1; #5; memcheckClk<=0; #5;
        end
    end

    always @ (posedge memcheckClk) begin
		#1; {memExpected} = testvectors [testIndex];
	end

    always @(negedge memcheckClk) begin
        if (mem!==memExpected) begin
            $display("Error result: memAddr = %d", testIndex);
            $display(" result = %x (%x expected)", mem, memExpected);
            errors = errors+1;
        end
        testIndex++;
        if (testvectors[testIndex]===32'bx) begin
            $display("%d tests completed with %d errors", testIndex, errors);
            $stop;
        end
    end

    always @(negedge clk) begin
        reset = 0;

        case (state)
        0: begin
            regAddr = 19; #1
            if(regg != 32'hF)
            $display("lw s3, 32(zero) : Incorrect register 's3' value:%h. Should be F", regg);
        end
        1: begin
            regAddr = 9; #1
            if(regg != 32'hFF0110D8)
            $display("lw s1, 12(s3) : Incorrect register 's1' value:%h. Should be FF0110D8", regg);
        end
        2: begin
            regAddr = 9; #1
            if(regg != 32'hFF0110D8)
            $display("lw s1, 12(s3) : Incorrect register 's1' value:%h. Should be FF0110D8", regg);
        end
        3: complete = 0;
        endcase

        state++;
	end

endmodule