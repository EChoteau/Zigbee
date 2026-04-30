`timescale 1ns/1ps

module tb_demod_wrapper;

    // =========================================================
    // PARAMETRES
    // =========================================================
    localparam int CLK_PERIOD = 100;

    // =========================================================
    // SIGNAUX
    // =========================================================
    logic i_clk = 0;
    logic i_rst_n;

    logic [3:0] i_i;
    logic [3:0] i_q;

    logic [9:0] i_Bus_B_10;
    logic [2:0] i_cfg;

    logic signed [5:0] o_i_bb;
    logic signed [5:0] o_q_bb;

    logic signed [3:0] o_cos_test;
    logic signed [3:0] o_sin_test;

    logic [11:0] o_Bus_B_12;

    // =========================================================
    // DUT
    // =========================================================
    demod_wrapper dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_i(i_i),
        .i_q(i_q),
        .i_Bus_B_10(i_Bus_B_10),
        .i_cfg(i_cfg),
        .o_i_bb(o_i_bb),
        .o_q_bb(o_q_bb),
        .o_cos_test(o_cos_test),
        .o_sin_test(o_sin_test),
        .o_Bus_B_12(o_Bus_B_12)
    );

    // =========================================================
    // CLOCK
    // =========================================================
    always #(CLK_PERIOD/2) i_clk = ~i_clk;

    // =========================================================
    // RESET
    // =========================================================
    initial begin
        i_rst_n = 0;
        i_i = 4'd8;
        i_q = 4'd8;
        i_Bus_B_10 = 10'd0;
        i_cfg = 3'b000;

        #(5*CLK_PERIOD);
        @(negedge i_clk);
        i_rst_n = 1;
    end

    // =========================================================
    // APPLY SAMPLE (REALISTIC TIMING)
    // =========================================================
    task apply_sample(input [3:0] I, input [3:0] Q);
    begin
        @(negedge i_clk);
        i_i = I;
        i_q = Q;
    end
    endtask

    // =========================================================
    // MONITOR
    // =========================================================
    initial begin
        $timeformat(-9, 1, " ns", 12);

        $display("time | cfg | I Q | I_BB Q_BB | Bus12");

        forever begin
            @(posedge i_clk);
            #5;
            $display("%t | %b | %2d %2d | %4d %4d | %b",
                $time, i_cfg, i_i, i_q, o_i_bb, o_q_bb, o_Bus_B_12);
        end
    end

    // =========================================================
    // MAIN TEST
    // =========================================================
    initial begin
        wait(i_rst_n);

        // =============================================
        // LOOP OVER ALL CONFIGS
        // =============================================
        for (int cfg = 0; cfg < 8; cfg++) begin

            @(negedge i_clk);
            i_cfg = cfg[2:0];

            $display("\n==============================");
            $display("TEST CFG = %0d", cfg);
            $display("==============================");

            // =========================================
            // Inject some realistic patterns
            // =========================================

            repeat (4) begin
                apply_sample(4'd15, 4'd8);
                apply_sample(4'd8 , 4'd15);
                apply_sample(4'd0 , 4'd8);
                apply_sample(4'd8 , 4'd0);
            end

            // =========================================
            // Bus test values
            // =========================================
            @(negedge i_clk);
            i_Bus_B_10 = {4'd12, 2'b00, 4'd4};

            repeat (8) @(posedge i_clk);
        end

        $display("\nFIN TEST WRAPPER");
        $finish;
    end

endmodule
