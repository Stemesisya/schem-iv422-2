module tb_1_3();

    parameter int N = 6;

    logic clk = 0;
    logic we;

    logic [5:0] addr_ram;
    logic [4:0] addr_rom;

    logic [31:0] wdata_ram;
    logic [31:0] rdata_ram;
    logic [31:0] rdata_rom;

    logic [31:0] temp_data;

    // RAM 64x32
    ram64x32 u_ram (
        .clk(clk),
        .we(we),
        .addr(addr_ram),
        .wdata(wdata_ram),
        .rdata(rdata_ram)
    );

    // ROM 32x32
    rom32x32 u_rom (
        .addr(addr_rom),
        .rdata(rdata_rom)
    );

    // Тактовый сигнал
    always #5 clk = ~clk;

    initial begin

        // Для диаграмм
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_1_3);

        // Начальные значения
        we = 0;
        addr_ram = 0;
        addr_rom = 0;
        wdata_ram = 0;

        #20;

        $display("ЗАДАНИЕ 1.3");

        // Адрес из задания: 000010 = 2
        addr_rom = 5'b00010;
        #1;

        // Считываем значение из ROM
        temp_data = rdata_rom;

        $display("Считано из ROM[2]: %h", temp_data);

        // Записываем значение в RAM по адресу N
        @(negedge clk);

        addr_ram = N;
        wdata_ram = temp_data;
        we = 1;

        // Ждём положительный фронт,
        // на котором произойдёт запись
        @(negedge clk);

        we = 0;
        #1;

        // Проверяем запись
        addr_ram = N;
        #1;

        if (rdata_ram !== temp_data) begin
            $display(
                "ОШИБКА: копирование из ROM не удалось. Ожидалось %h, получено %h",
                temp_data,
                rdata_ram
            );
            $stop;
        end

        $display(
            "Значение успешно скопировано в RAM[%0d]: %h",
            N,
            rdata_ram
        );

        for (int i = 0; i < 64; i++) begin

            if (i == N)
                continue;

            addr_ram = i;
            #1;

            if (rdata_ram !== 32'hX) begin
                $display(
                    "ОШИБКА: RAM[%0d] изменена, ожидалось X, получено %h",
                    i,
                    rdata_ram
                );
                $stop;
            end
        end

        $display("Остальные ячейки RAM остались X.");

        $finish;

    end

endmodule