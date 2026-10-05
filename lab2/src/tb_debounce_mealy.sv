`timescale 1ns / 1ps

module tb_debounce_mealy;

    parameter int N = 2;
    localparam int DELAY = (1 << N);

    logic clk;
    logic reset;
    logic in;
    logic out;

    int errors = 0;

    debounce_mealy #(.N(N)) u_dut (
        .clk   (clk),
        .reset (reset),
        .in    (in),
        .out   (out)
    );

    always #5 clk = ~clk;

    initial begin
        $display("--- Тест автомата Мили (N=%0d) ---", N);

        clk = 0;
        reset = 1;
        in = 0;

        #15;
        @(posedge clk);
        reset = 0;

        // Тест 1: мгновенная реакция
        $display("[Тест 1] Проверка реакции на нажатие...");

        @(posedge clk);
        in = 1;

        #1;

        if (out !== 1) begin
            $display("ОШИБКА: out не стал равен 1");
            errors++;
        end
        else begin
            $display("УСПЕХ: out = 1 на том же такте");
        end

        @(posedge clk);
        in = 0;

        #1;

        if (out !== 0) begin
            $display("ОШИБКА: out не вернулся в 0");
            errors++;
        end

        // Тест 2: дребезг игнорируется
        $display("[Тест 2] Проверка игнорирования дребезга...");

        in = 1;
        @(posedge clk);
        in = 0;

        in = 1;
        @(posedge clk);
        in = 0;

        repeat(DELAY - 2)
            @(posedge clk);

        @(posedge clk);
        #1;

        if (out !== 0) begin
            $display("ОШИБКА: схема не вернулась в IDLE");
            errors++;
        end
        else begin
            $display("УСПЕХ: дребезг проигнорирован");
        end

        if (errors == 0)
            $display("=== ТЕСТ МИЛИ ПРОЙДЕН ===");
        else
            $display("=== ОШИБОК: %0d ===", errors);

        $stop;
    end

endmodule