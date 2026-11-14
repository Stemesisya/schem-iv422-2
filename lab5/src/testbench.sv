module testbench();

    logic clk;
    logic reset;
    logic [5:0] state;

    processor proc (.reset(reset), .clk(clk));


    initial begin
        reset=1;
        state = 0;
    end

    always begin
        clk <= 1; #10; clk<=0; #10;
    end

    always @(negedge clk) begin
        state++;
        if(state == 0)
            $stop;
        #5; reset = 0;
	end

endmodule