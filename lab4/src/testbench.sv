module testbench();

    logic clk;
    logic reset;
    logic [2:0] state;

    logic [4:0] regAddr;
    logic [31:0] regg;

    processor proc (.reset(reset), .clk(clk));

    assign regg = proc.registers.regs[regAddr];

    logic [31:0] a, b, sum, expected, result;
    assign a = proc.storage.mem[0];
    assign b = proc.storage.mem[1];
    assign sum = a+b;
    assign expected = sum[31] == 0 ? 32'b1 : 32'b0;
    assign result = proc.storage.mem[3];


    initial begin
        reset=1;
        state = 0;
    end

    always begin
        clk <= 1; #10; clk<=0; #10;
    end

    always @(negedge clk) begin
        reset = 0;

        case (state)
        0: begin
            regAddr = 9; #1
            if(regg != a)
                $display("lw s1, 0(zero) : Incorrect register 's1' value:%h. Should be %h", regg, a);

            if(result != 32'b0)
                $display("lw s1, 0(zero) : Incorrect memory '0x8' value:%h. Should be %h", result, 0);
        end
        1: begin
            regAddr = 18; #1
            if(regg != b)
                $display("lw s2, 4(zero) : Incorrect register 's2' value:%h. Should be %h", regg, b);

            if(result != 32'b0)
                $display("lw s2, 4(zero) : Incorrect memory '0x8' value:%h. Should be %h", result, 0);
        end
        2: begin
            regAddr = 22; #1
            if(regg != 32'hFFFFFFFF)
                $display("lw s6, 8(zero) : Incorrect register 's6' value:%h. Should be %h", regg, 32'hFFFFFFFF);
        end
        3: begin
            regAddr = 9; #1
            if(regg != a)
                $display("add s3, s1, s2 : Incorrect register 's1' value:%h. Should be %h", regg, a);
            regAddr = 18; #1
            if(regg != b)
                $display("add s3, s1, s2 : Incorrect register 's2' value:%h. Should be %h", regg, b);
            regAddr = 19; #1
            if(regg != sum)
                $display("add s3, s1, s2 : Incorrect register 's3' value:%h. Should be %h", regg, sum);

            if(result != 32'b0)
                $display("add s3, s1, s2 : Incorrect memory '0x8' value:%h. Should be %h", result, 0);
        end
        4: begin
            regAddr = 9; #1
            if(regg != a)
                $display("slt s4, s6, s3 : Incorrect register 's1' value:%h. Should be %h", regg, a);
            regAddr = 18; #1
            if(regg != b)
                $display("slt s4, s6, s3 : Incorrect register 's2' value:%h. Should be %h", regg, b);
            regAddr = 19; #1
            if(regg != sum)
                $display("slt s4, s6, s3 : Incorrect register 's3' value:%h. Should be %h", regg, sum);
            regAddr = 20; #1
            if(regg != expected)
                $display("slt s4, s6, s3 : Incorrect register 's4' value:%h. Should be %h", regg, expected);
            regAddr = 22; #1
            if(regg != 32'hFFFFFFFF)
                $display("slt s4, s6, s3 : Incorrect register 's6' value:%h. Should be %h", regg, 32'hFFFFFFFF);

            if(result != 32'b0)
                $display("slt s4, s6, s3 : Incorrect memory '0x8' value:%h. Should be %h", result, 0);
        end
        5: begin
            regAddr = 9; #1
            if(regg != a)
                $display("sw s4, 8(zero) : Incorrect register 's1' value:%h. Should be %h", regg, a);
            regAddr = 18; #1
            if(regg != b)
                $display("sw s4, 8(zero) : Incorrect register 's2' value:%h. Should be %h", regg, b);
            regAddr = 19; #1
            if(regg != sum)
                $display("sw s4, 8(zero) : Incorrect register 's3' value:%h. Should be %h", regg, sum);
            regAddr = 20; #1
            if(regg != expected)
                $display("sw s4, 8(zero) : Incorrect register 's4' value:%h. Should be %h", regg, expected);

            if(result != 32'b0)
                $display("sw s4, 8(zero) : Incorrect memory '0x8' value:%h. Should be %h", result, 32'b0);
        end
        6: begin
            regAddr = 9; #1
            if(regg != a)
                $display("lw s5, 8(zero) : Incorrect register 's1' value:%h. Should be %h", regg, a);
            regAddr = 18; #1
            if(regg != b)
                $display("lw s5, 8(zero) : Incorrect register 's2' value:%h. Should be %h", regg, b);
            regAddr = 19; #1
            if(regg != sum)
                $display("lw s5, 8(zero) : Incorrect register 's3' value:%h. Should be %h", regg, sum);
            regAddr = 20; #1
            if(regg != expected)
                $display("lw s5, 8(zero) : Incorrect register 's4' value:%h. Should be %h", regg, expected);
            regAddr = 21; #1
            if(regg != expected)
                $display("lw s5, 8(zero) : Incorrect register 's5' value:%h. Should be %h", regg, expected);

            if(result != expected)
                $display("lw s5, 8(zero) : Incorrect memory '0x8' value:%h. Should be %h", result, expected);
            $stop;
        end
        endcase

        state++;
	end

endmodule