module testbench();

logic clk, writeenable;
logic [31:0] writedata, readdata;
logic [5:0] dataadr, addrbuff;

dmem mem (clk, writeenable, dataadr, writedata, readdata);

initial begin
    writeenable =0;
    writedata = 0;
    dataadr = 0;
    addrbuff = 0;
end

always begin
    clk <= 1; #5; clk<=0; #5;
end

always @ (negedge clk) begin
    if (writeenable ==1) begin

        $display ("RESULT: %b in %d", readdata, dataadr);
        if (readdata != writedata) begin
            $display ("readdata != writedata");
        end

        writeenable =0;

        if (dataadr >=63) begin
            $stop;
        end

        addrbuff = dataadr;

        for (dataadr++; dataadr != 0; dataadr++) begin
            #5
            $display ("XXXXX?: %b in %d", readdata, dataadr);
            if($isunknown(readdata))
            $display("good job");
        end

        dataadr <= addrbuff+1;

    end else begin
        writeenable = 1;
        writedata = $urandom;
        $display ("%b in %d", writedata, dataadr);
    end
end
endmodule
