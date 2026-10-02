module timer_testbench();

logic clk, reset, start, done;

timer timer (clk, reset, start, done);

initial begin
    clk =0;
    reset = 0;
    start = 0;
    done = 0;
end

always begin
    clk <= 1; #5; clk<=0; #5;
end

endmodule;