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
                if(proc.regWrite != 0)
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
                    $display("[1:Decode] Unexpected value %h in oldPC", proc.oldPC);
                if(proc.PC != 32'h4)
                    $display("[1:Decode] Unexpected value %h in PC", proc.PC);
                if(proc.memWrite != 0)
                    $display("[1:Decode] Warning: memWrite enabled");
                if(proc.regWrite != 0)
                    $display("[1:Decode] Warning: regWrite enabled");
                if(proc.IRWrite != 0)
                    $display("[1:Decode] Warning: IRWrite enabled.");
                if(proc.PCWrite != 0)
                    $display("[1:Decode] Warning: PCWrite enabled.");
            end
            3: begin // Формируем указатель на ячейку памяти (складываем base и immediate) 32(zero). Сохраняем в aluOut.
                if(proc.controller.state != S2_MEMADR)
                    $display("[1:MemAddr] Oh no. Wrong state: %d", proc.controller.state);
                if(proc.srcA != 32'h0)
                    $display("[1:MemAddr] Unexpected value %h in srcA", proc.srcA);
                if(proc.srcB != 32'h20)
                    $display("[1:MemAddr] Unexpected value %h in srcB", proc.srcB);
                if(proc.aluResult != 32'h20)
                    $display("[1:MemAddr] Unexpected value %h in readData", proc.aluResult);
                if(proc.memWrite != 0)
                    $display("[1:MemAddr] Warning: memWrite enabled");
                if(proc.regWrite != 0)
                    $display("[1:MemAddr] Warning: regWrite enabled");
                if(proc.IRWrite != 0)
                    $display("[1:MemAddr] Warning: IRWrite enabled.");
                if(proc.PCWrite != 0)
                    $display("[1:MemAddr] Warning: PCWrite enabled.");
            end
            4: begin // Берем aluOut за адрес и читаем из памяти данные. Пихаем в data.
                if(proc.controller.state != S3_MEMREAD)
                    $display("[1:MemRead] Oh no. Wrong state: %d", proc.controller.state);
                if(proc.aluOut != 32'h20)
                    $display("[1:MemRead] Unexpected value %h in aluOut", proc.aluOut);
                if(proc.readData != 32'h1)
                    $display("[1:MemRead] Unexpected value %h in readData", proc.readData);
                if(proc.memWrite != 0)
                    $display("[1:MemRead] Warning: memWrite enabled");
                if(proc.regWrite != 0)
                    $display("[1:MemRead] Warning: regWrite enabled");
                if(proc.IRWrite != 0)
                    $display("[1:MemRead] Warning: IRWrite enabled.");
                if(proc.PCWrite != 0)
                    $display("[1:MemRead] Warning: PCWrite enabled.");
            end
            5: begin // data пихаем в rd.
                if(proc.controller.state != S4_MEMWB)
                    $display("[1:MemWb] Oh no. Wrong state: %d", proc.controller.state);
                if(proc.result != 32'h1)
                    $display("[1:MemWb] Unexpected value %h in result", proc.result);
                if(proc.data != 32'h1)
                    $display("[1:MemWb] Unexpected value %h in data", proc.data);
                if(proc.memWrite != 0)
                    $display("[1:MemWb] Warning: memWrite enabled");
                if(proc.regWrite != 1)
                    $display("[1:MemWb] Warning: regWrite disabled. Data will not save.");
                if(proc.IRWrite != 0)
                    $display("[1:MemWb] Warning: IRWrite enabled.");
                if(proc.PCWrite != 0)
                    $display("[1:MemWb] Warning: PCWrite enabled.");
            end
            6: begin // читаем команду, сохраняем в Instr. Инкрементируем PC на 4 (на следующем такте)
                if(proc.controller.state != S0_FETCH)
                    $display("[2:Fetch] Oh no. Wrong state: %d", proc.controller.state);
                if(proc.readData != 32'h02402903)
                    $display("[2:Fetch] Unexpected value %h in readData", proc.readData);
                if(proc.PC != 32'h4)
                    $display("[2:Fetch] Unexpected value %h in PC", proc.PC);
                if(proc.memWrite != 0)
                    $display("[2:Fetch] Warning: memWrite enabled");
                if(proc.regWrite != 0)
                    $display("[2:Fetch] Warning: regWrite enabled");
                if(proc.IRWrite != 1)
                    $display("[2:Fetch] Warning: IRWrite diabled. Instruction won't update.");
                if(proc.PCWrite != 1)
                    $display("[2:Fetch] Warning: PCWrite disabled. PC won't update.");
            end
            7: begin // Декодируем команду. Сразу складываем ее с операндом (на случай джампа)
                if(proc.controller.state != S1_DECODE)
                    $display("[2:Decode] Oh no. Wrong state: %d", proc.controller.state);
                if(proc.instr != 32'h02402903)
                    $display("[2:Decode] Unexpected value %h in instr", proc.readData);
                if(proc.oldPC != 32'h4)
                    $display("[2:Decode] Unexpected value %h in oldPC", proc.oldPC);
                if(proc.PC != 32'h8)
                    $display("[2:Decode] Unexpected value %h in PC", proc.PC);
                if(proc.memWrite != 0)
                    $display("[2:Decode] Warning: memWrite enabled");
                if(proc.regWrite != 0)
                    $display("[2:Decode] Warning: regWrite enabled");
                if(proc.IRWrite != 0)
                    $display("[2:Decode] Warning: IRWrite enabled.");
                if(proc.PCWrite != 0)
                    $display("[2:Decode] Warning: PCWrite enabled.");
            end
            // 8 MemAdr
            // 9 MemRead
            10: begin // data пихаем в rd.
                if(proc.controller.state != S4_MEMWB)
                    $display("[2:MemWb] Oh no. Wrong state: %d", proc.controller.state);
                if(proc.result != 32'hFFFFFFFF)
                    $display("[2:MemWb] Unexpected value %h in result", proc.result);
                if(proc.data != 32'hFFFFFFFF)
                    $display("[2:MemWb] Unexpected value %h in data", proc.data);
                if(proc.memWrite != 0)
                    $display("[2:MemWb] Warning: memWrite enabled");
                if(proc.regWrite != 1)
                    $display("[2:MemWb] Warning: regWrite disabled. Data will not save.");
                if(proc.IRWrite != 0)
                    $display("[2:MemWb] Warning: IRWrite enabled.");
                if(proc.PCWrite != 0)
                    $display("[2:MemWb] Warning: PCWrite enabled.");
            end
            // 11 3:Fetch
            // 12 3:Decode
            // 13 3:MemAdr
            // 14 3:MemRead
            15: begin // data пихаем в rd.
                if(proc.controller.state != S4_MEMWB)
                    $display("[3:MemWb] Oh no. Wrong state: %d", proc.controller.state);
                if(proc.result != 32'hFFFFFFFF)
                    $display("[3:MemWb] Unexpected value %h in result", proc.result);
                if(proc.data != 32'hFFFFFFFF)
                    $display("[3:MemWb] Unexpected value %h in data", proc.data);
                if(proc.memWrite != 0)
                    $display("[3:MemWb] Warning: memWrite enabled");
                if(proc.regWrite != 1)
                    $display("[3:MemWb] Warning: regWrite disabled. Data will not save.");
                if(proc.IRWrite != 0)
                    $display("[3:MemWb] Warning: IRWrite enabled.");
                if(proc.PCWrite != 0)
                    $display("[3:MemWb] Warning: PCWrite enabled.");
            end
            16: begin // читаем команду, сохраняем в Instr. Инкрементируем PC на 4 (на следующем такте)
                if(proc.controller.state != S0_FETCH)
                    $display("[4:Fetch] Oh no. Wrong state: %d", proc.controller.state);
                if(proc.readData != 32'h012489b3)
                    $display("[4:Fetch] Unexpected value %h in readData", proc.readData);
                if(proc.PC != 32'd12)
                    $display("[4:Fetch] Unexpected value %d in PC", proc.PC);
                if(proc.memWrite != 0)
                    $display("[4:Fetch] Warning: memWrite enabled");
                if(proc.regWrite != 0)
                    $display("[4:Fetch] Warning: regWrite enabled");
                if(proc.IRWrite != 1)
                    $display("[4:Fetch] Warning: IRWrite diabled. Instruction won't update.");
                if(proc.PCWrite != 1)
                    $display("[4:Fetch] Warning: PCWrite disabled. PC won't update.");
            end
            17: begin // Декодируем команду. Сразу складываем ее с операндом (на случай джампа)
                if(proc.controller.state != S1_DECODE)
                    $display("[4:Decode] Oh no. Wrong state: %d", proc.controller.state);
                if(proc.instr != 32'h012489b3)
                    $display("[4:Decode] Unexpected value %h in instr", proc.readData);
                if(proc.oldPC != 32'd12)
                    $display("[4:Decode] Unexpected value %h in OldPC", proc.oldPC);
                if(proc.PC != 32'd16)
                    $display("[4:Decode] Unexpected value %h in PC", proc.PC);
                if(proc.memWrite != 0)
                    $display("[4:Decode] Warning: memWrite enabled");
                if(proc.regWrite != 0)
                    $display("[4:Decode] Warning: regWrite enabled");
                if(proc.IRWrite != 0)
                    $display("[4:Decode] Warning: IRWrite enabled.");
                if(proc.PCWrite != 0)
                    $display("[4:Decode] Warning: PCWrite enabled.");
            end
            18: begin // Нашли тип R. Суммируем. Результат сохраняем в aluOut.
                if(proc.controller.state != S6_EXECUTER)
                    $display("[4:ExecuteR] Oh no. Wrong state: %d", proc.controller.state);
                if(proc.alu.funcsel != 32'b010)
                    $display("[4:ExecuteR] Unexpected value %h in alu.funcsel", proc.alu.funcsel);
                if(proc.srcA != 32'h1)
                    $display("[4:ExecuteR] Unexpected value %h in srcA", proc.srcA);
                if(proc.srcB != 32'hFFFFFFFF)
                    $display("[4:ExecuteR] Unexpected value %h in srcB", proc.srcB);
                if(proc.aluResult != 32'h0)
                    $display("[4:ExecuteR] Unexpected value %h in aluResult", proc.aluResult);
                if(proc.memWrite != 0)
                    $display("[4:ExecuteR] Warning: memWrite enabled");
                if(proc.regWrite != 0)
                    $display("[4:ExecuteR] Warning: regWrite enabled");
                if(proc.IRWrite != 0)
                    $display("[4:ExecuteR] Warning: IRWrite enabled.");
                if(proc.PCWrite != 0)
                    $display("[4:ExecuteR] Warning: PCWrite enabled.");
            end
            19: begin // записываем aluOut в регистр rd.
                if(proc.controller.state != S7_ALUWB)
                    $display("[4:AluWb] Oh no. Wrong state: %d", proc.controller.state);
                if(proc.result != 32'h0)
                    $display("[4:AluWb] Unexpected value %h in result", proc.result);
                if(proc.memWrite != 0)
                    $display("[4:AluWb] Warning: memWrite enabled");
                if(proc.regWrite != 1)
                    $display("[4:AluWb] Warning: regWrite disabled. Data will not save.");
                if(proc.IRWrite != 0)
                    $display("[4:AluWb] Warning: IRWrite enabled.");
                if(proc.PCWrite != 0)
                    $display("[4:AluWb] Warning: PCWrite enabled.");
            end
            20: begin // читаем команду, сохраняем в Instr. Инкрементируем PC на 4 (на следующем такте)
                if(proc.controller.state != S0_FETCH)
                    $display("[5:Fetch] Oh no. Wrong state: %d", proc.controller.state);
                if(proc.readData != 32'h013b2a33)
                    $display("[5:Fetch] Unexpected value %h in readData", proc.readData);
                if(proc.PC != 32'd16)
                    $display("[5:Fetch] Unexpected value %d in PC", proc.PC);
                if(proc.memWrite != 0)
                    $display("[5:Fetch] Warning: memWrite enabled");
                if(proc.regWrite != 0)
                    $display("[5:Fetch] Warning: regWrite enabled");
                if(proc.IRWrite != 1)
                    $display("[5:Fetch] Warning: IRWrite diabled. Instruction won't update.");
                if(proc.PCWrite != 1)
                    $display("[5:Fetch] Warning: PCWrite disabled. PC won't update.");
            end
            // 21 5:Decode
            22: begin // Нашли тип R. Делаем slt. Результат сохраняем в aluOut.
                if(proc.controller.state != S6_EXECUTER)
                    $display("[5:ExecuteR] Oh no. Wrong state: %d", proc.controller.state);
                if(proc.alu.funcsel != 32'b111)
                    $display("[5:ExecuteR] Unexpected value %h in alu.funcsel", proc.alu.funcsel);
                if(proc.srcA != 32'hFFFFFFFF)
                    $display("[5:ExecuteR] Unexpected value %h in srcA", proc.srcA);
                if(proc.srcB != 32'h0)
                    $display("[5:ExecuteR] Unexpected value %h in srcB", proc.srcB);
                if(proc.aluResult != 32'h1)
                    $display("[5:ExecuteR] Unexpected value %h in aluResult", proc.aluResult);
                if(proc.memWrite != 0)
                    $display("[5:ExecuteR] Warning: memWrite enabled");
                if(proc.regWrite != 0)
                    $display("[5:ExecuteR] Warning: regWrite enabled");
                if(proc.IRWrite != 0)
                    $display("[5:ExecuteR] Warning: IRWrite enabled.");
                if(proc.PCWrite != 0)
                    $display("[5:ExecuteR] Warning: PCWrite enabled.");
            end
            // 23: 5:aluWb
            // 24: 6:Fetch
            // 25: 6:Decode
            26: begin // Формируем указатель на ячейку памяти (складываем base и immediate) 44(zero). Сохраняем в aluOut.
                if(proc.controller.state != S2_MEMADR)
                    $display("[6:MemAddr] Oh no. Wrong state: %d", proc.controller.state);
                if(proc.srcA != 32'h0)
                    $display("[6:MemAddr] Unexpected value %h in srcA", proc.srcA);
                if(proc.srcB != 32'd44)
                    $display("[6:MemAddr] Unexpected value %d in srcB", proc.srcB);
                if(proc.aluResult != 32'd44)
                    $display("[6:MemAddr] Unexpected value %d in aluResult", proc.aluResult);
                if(proc.memWrite != 0)
                    $display("[6:MemAddr] Warning: memWrite enabled");
                if(proc.regWrite != 0)
                    $display("[6:MemAddr] Warning: regWrite enabled");
                if(proc.IRWrite != 0)
                    $display("[6:MemAddr] Warning: IRWrite enabled.");
                if(proc.PCWrite != 0)
                    $display("[6:MemAddr] Warning: PCWrite enabled.");
            end
            27: begin // записываем в ячейку с адресом aluOut 
                if(proc.controller.state != S5_MEMWRITE)
                    $display("[6:MemWrite] Oh no. Wrong state: %d", proc.controller.state);
                if(proc.result != 32'd44)
                    $display("[6:MemWrite] Unexpected value %d in result", proc.result);
                if(proc.writeData != 32'h1)
                    $display("[6:MemWrite] Unexpected value %h in writeData", proc.writeData);
                if(proc.memWrite != 1)
                    $display("[6:MemWrite] Warning: memWrite disabled. Register value won't save.");
                if(proc.regWrite != 0)
                    $display("[6:MemWrite] Warning: regWrite enabled");
                if(proc.IRWrite != 0)
                    $display("[6:MemWrite] Warning: IRWrite enabled.");
                if(proc.PCWrite != 0)
                    $display("[6:MemWrite] Warning: PCWrite enabled.");
            end
            
        endcase
        if(state == 0)
            $stop;
        #5; reset = 0;
	end

endmodule