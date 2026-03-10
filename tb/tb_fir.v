`timescale 1ns/1ps

module tb_fir;

    // =========================
    // Parameters
    // =========================

    parameter CLK_PERIOD = 20;   // 50 MHz

    // =========================
    // Signals
    // =========================

    reg clk;
    reg rst;
    reg sample_en;
    reg signed [5:0] x_in;
    wire signed [22:0] y_out;

    // =========================
    // DUT
    // =========================

    fir_top DUT (
        .clk(clk),
        .rst(rst),
        .sample_en(sample_en),
        .x_in(x_in),
        .y_out(y_out)
    );

    // =========================
    // Clock generation
    // =========================

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // =========================
    // Stimulus
    // =========================

    integer i;
    integer period; 

    initial begin

        // Init
        rst = 0;
        sample_en = 0;
        x_in = 0;

        #(5*CLK_PERIOD);

        rst = 1;
        sample_en = 1;


        // =====================================
        // Test impulse response
        // =====================================

        $display("---- Impulse Response Test ----");

        x_in = 20;
        #(CLK_PERIOD);

        x_in = 0;

        for (i = 0; i < 40; i = i + 1)
            #(CLK_PERIOD);

        // =====================================
        // Frequency sweep sine test
        // =====================================

        $display("---- Frequency Sweep Test ----");

        for (period = 80; period >= 4; period = period - 4) begin
            $display("Testing sine period = %d", period);

            for (i = 0; i < 200; i = i + 1) begin
                x_in = 20 * $sin(2*3.14159*i/period);
                #(CLK_PERIOD);
            end
        end

        $display("Simulation finished.");
        $stop;

    end

endmodule

















































