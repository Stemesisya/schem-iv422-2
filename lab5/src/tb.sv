module tb();
    parameter int N = 6; 

    logic clk = 0;
    logic we1, we2;
    logic [5:0] addr64_32;
    logic [4:0] addr32_32, addr_rom;
    logic [31:0] wdata64_32, wdata32_32;
    logic [31:0] rdata64_32, rdata32_32, rdata_rom;

    ram64x32 u_ram1 (
        .clk(clk), .we(we1), .addr(addr64_32
), .wdata(wdata64_32), .rdata(rdata64_32)
    );

    ram32x32 u_ram2 (
        .clk(clk), .we(we2), .addr(addr32_32
), .wdata(wdata32_32), .rdata(rdata32_32)
    );

    rom32x32 u_rom (
        .addr(addr_rom), .rdata(rdata_rom)
    );

    always #5 clk = ~clk;

    initial begin
     logic [31:0] temp_data;
    		// Для диаграмм
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
           

        we1 = 0; we2 = 0;
        addr64_32
 = 0; addr32_32 = 0; addr_rom = 0;
        wdata64_32 = 0; wdata32_32 = 0;
        #20; 
        
        // 1. Проверка неопределенных значений в RAM1
        for (int i = 0; i < 64; i++) begin
            addr64_32
     = i; #1;
            if (rdata64_32 !== 32'hX) begin
                $display("ОШИБКА Адрес %0d не равен X (значение: %h)", i, rdata64_32); $stop;
            end
        end
        $display("Начальные значения X подтверждены.");

        // 2. Запись по адресу N (выставляем сигналы по спаду clk)
        @(negedge clk);
        addr64_32
 = N; 
        wdata64_32 = 32'hDEADBEEF;
        we1 = 1;
        
        @(negedge clk); // Ждем, пока пройдет один фронт (запись случится на posedge)
        we1 = 0;        // Снимаем разрешение записи
        #1;

        // Проверка записи
        addr64_32
 = N; #1;
        if (rdata64_32 !== 32'hDEADBEEF) begin
            $display("ОШИБКА Запись по адресу N не удалась. Получено: %h", rdata64_32); $stop;
        end

        for (int i = 0; i < 64; i++) begin
            if (i == N) continue;
            addr64_32
     = i; #1;
            if (rdata64_32 !== 32'hX) begin
                $display("ОШИБКА Адрес %0d изменился, а должен быть X.", i); $stop;
            end
        end
        $display("Запись успешна, остальные ячейки X.\n");

        $display("ЗАДАНИЕ 2");

        // Проверка инициализации RAM2
        addr32_32
 = 2; #1;
        if (rdata32_32 !== 32'h00000055) begin $display("ОШИБКА RAM2 не инициализирована (addr 2)."); $stop; end
        
        addr32_32
 = 4; #1;
        if (rdata32_32 !== 32'h00020007) begin $display("ОШИБКА RAM2 не инициализирована (addr 4)."); $stop; end
        $display("Инициализация RAM2 подтверждена.");

        // Читаем из RAM2 по адресу N
        addr32_32
 = N; #1;
        temp_data = rdata32_32;
        
        // Копируем в RAM1 по адресу N * 3
        @(negedge clk);
        addr64_32
 = N * 3;
        wdata64_32 = temp_data;
        we1 = 1;
        
        @(negedge clk);
        we1 = 0;
        #1;

        // Проверка копирования
        addr64_32
 = N * 3; #1;
        if (rdata64_32 !== temp_data) begin
            $display("ОШИБКА Копирование не удалось. Ожидалось %h, получено %h", temp_data, rdata64_32); $stop;
        end

        for (int i = 0; i < 64; i++) begin
            if (i == N || i == N*3) continue;
            addr64_32
     = i; #1;
            if (rdata64_32 !== 32'hX) begin
                $display("ОШИБКА Адрес %0d в RAM1 не равен X.", i); $stop;
            end
        end
        $display("Т2: Копирование успешно, остальные ячейки X. ЗАДАНИЕ 2 ВЫПОЛНЕНО!\n");

        $display("ЗАДАНИЕ 3");
        // Адрес из задания: 5'b00010 (это десятичная 2)
        addr_rom = 5'b00010; #1;
        temp_data = rdata_rom;
        $display("Считано из ПЗУ[2] значение: %h", temp_data);

        // Копируем в RAM1 по адресу N
        @(negedge clk);
        addr64_32
 = N;
        wdata64_32 = temp_data;
        we1 = 1;
        
        @(negedge clk);
        we1 = 0;
        #1;
        
        // Проверка копирования из ПЗУ
        addr64_32
 = N; #1;
        if (rdata64_32 !== temp_data) begin
            $display("ОШИБКА Копирование из ПЗУ не удалось. Получено: %h", rdata64_32); $stop;
        end

        for (int i = 0; i < 64; i++) begin
            if (i == N || i == N*3) continue;
            addr64_32
     = i; #1;
            if (rdata64_32 !== 32'hX) begin
                $display("ОШИБКА Адрес %0d в RAM1 не равен X.", i); $stop;
            end
        end
        $display("Копирование успешно, остальные ячейки X.\n");
       
        $finish;
    end

endmodule
