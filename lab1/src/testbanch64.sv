module testbench64();
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

      if (readdata != writedata)
        $display ("%d: readdata != writedata", addrbuff);

      writeenable =0;

      if (dataadr >=63)
        $stop;
      
      addrbuff = dataadr;
      for (dataadr++; dataadr != 0; dataadr++) begin
        #5
        if(!$isunknown(readdata))
          $display("%d: not XXXXX", addrbuff);
      end
      
      dataadr <= addrbuff+1;
    end else begin
      writeenable = 1;
      writedata = $urandom;
    end
  end
endmodule
