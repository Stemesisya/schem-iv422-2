module testbench();

    logic clk;
    logic reset;
    logic [5:0] state;

    processor proc (.reset(reset), .clk(clk));

    typedef enum logic [3:0] {
        S0_FETCH,
        S1_DECODE,
        S2_MEMADR,
        S3_MEMREAD,
        S4_MEMWB,
        S5_MEMWRITE,
        S6_EXECUTER,
        S7_ALUWB,
        S10_BEQ
    } statetype;

    initial begin
        reset=1;
        state = 0;
    end

    always begin
        clk <= 1; #10; clk<=0; #10;
    end

    always @(negedge clk) begin
        state++;

        case (state)
            1: begin // читаем команду, сохраняем в Instr. Инкрементируем PC на 4 (на следующем такте)
                if(proc.controller.state != S0_FETCH)
                    $display("[1:Fetch] Oh no. Wrong state: %d", proc.controller.state);
                if(proc.readData != 32'h02002483)
                    $display("[1:Fetch] Unexpected value %h in readData", proc.readData);
                if(proc.PC != 32'h0)
                    $display("[1:Fetch] Unexpected value %h in PC", proc.PC);
                if(proc.memWrite != 0)
                    $display("[1:Fetch] Warning: memWrite enabled");
                if(proc.memWrite != 0)
                    $display("[1:Fetch] Warning: regWrite enabled");
                if(proc.IRWrite != 1)
                    $display("[1:Fetch] Warning: IRWrite diabled. Instruction won't update.");
                if(proc.PCWrite != 1)
                    $display("[1:Fetch] Warning: PCWrite disabled. PC won't update.");
            end
            2: begin // Декодируем команду. Сразу складываем ее с операндом (на случай джампа)
                if(proc.controller.state != S1_DECODE)
                    $display("[1:Decode] Oh no. Wrong state: %d", proc.controller.state);
                if(proc.instr != 32'h02002483)
                    $display("[1:Decode] Unexpected value %h in instr", proc.readData);
                if(proc.oldPC != 32'h0)
                    $display("[1:Decode] Unexpected value %h in PC", proc.oldPC);
                if(proc.PC != 32'h4)
                    $display("[1:Decode] Unexpected value %h in PC", proc.PC);
                if(proc.memWrite != 0)
                    $display("[1:Decode] Warning: memWrite enabled");
                if(proc.memWrite != 0)
                    $display("[1:Decode] Warning: regWrite enabled");
                if(proc.IRWrite != 0)
                    $display("[1:Decode] Warning: IRWrite enabled. Corruption expected.");
                if(proc.PCWrite != 0)
                    $display("[1:Decode] Warning: PCWrite enabled. Corruption expected.");
            end
        endcase
        if(state == 0)
            $stop;
        #5; reset = 0;
	end

endmodule