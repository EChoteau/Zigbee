`timescale 1ns/1ps

module tb_demod_wrapper;

    localparam int CLK_PERIOD = 100;

    logic i_clk = 0;
    logic i_rst_n;

    logic [2:0]  i_cfg;
    logic [9:0]  i_bus_a;
    logic [11:0] i_bus_b;

    logic [11:0] o_bus_c;
    logic [1:0]  o_bus_d;

    // =========================================================
    // DUT
    // =========================================================
    demod_wrapper dut (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_cfg   (i_cfg),

        .i_bus_a (i_bus_a),
        .i_bus_b (i_bus_b),

        .o_bus_c (o_bus_c),
        .o_bus_d (o_bus_d)
    );

    // =========================================================
    // CLOCK
    // =========================================================
    always #(CLK_PERIOD/2) i_clk = ~i_clk;

    // =========================================================
    // RESET
    // =========================================================
    initial begin
        i_rst_n = 1'b0;
        i_cfg   = 3'b000;
        i_bus_a = 10'd0;
        i_bus_b = 12'd0;

        #(5*CLK_PERIOD);
        @(negedge i_clk);
        i_rst_n = 1'b1;
    end

    // =========================================================
    // APPLY INPUT ON BUS B
    // bus_b[7:4] = I debug input
    // bus_b[3:0] = Q debug input
    // bus_b[7:0] = FIR debug input
    // =========================================================
    task automatic apply_bus_b_sample(
        input logic [3:0] I,
        input logic [3:0] Q
    );
        begin
            @(negedge i_clk);
            i_bus_b[7:4]  = I;
            i_bus_b[3:0]  = Q;
            i_bus_b[11:8] = 4'd0;
        end
    endtask

    task automatic apply_fir_sample(
        input logic signed [7:0] x
    );
        begin
            @(negedge i_clk);
            i_bus_b[7:0]  = x;
            i_bus_b[11:8] = 4'd0;
        end
    endtask

    // =========================================================
    // MONITOR
    // =========================================================
    initial begin
        $timeformat(-9, 1, " ns", 12);

        $display("time | cfg | I | Q | FIR_in | o_bus_c | o_bus_d");
        $display("------------------------------------------------");

        forever begin
            @(posedge i_clk);
            #5;
            $display("%t | %b | I=%2d Q=%2d | FIR=%4d | o_bus_c=%b | o_bus_d=%b",
                $time,
                i_cfg,
                i_bus_b[7:4],
                i_bus_b[3:0],
                $signed(i_bus_b[7:0]),
                o_bus_c,
                o_bus_d
            );
        end
    end

    // =========================================================
    // MAIN TEST
    // =========================================================
    initial begin
        wait(i_rst_n);

        for (int cfg = 0; cfg < 8; cfg++) begin
            @(negedge i_clk);
            i_cfg = cfg[2:0];

            $display("\n==============================");
            $display("TEST CFG = %0d", cfg);
            $display("==============================");

            if ((cfg == 4) || (cfg == 5)) begin

                // =================================================
                // MODE 4 / 5 : FIR only
                // i_bus_b[7:0] is interpreted as signed 8-bit FIR input
                // =================================================
                repeat (4) begin
                    apply_fir_sample(8'sd20);
                    apply_fir_sample(8'sd0);
                    apply_fir_sample(-8'sd20);
                    apply_fir_sample(8'sd0);
                end

            end else begin

                // =================================================
                // MODE 0/1/2/3 : DEMOD observation
                // MODE 6/7     : full chain I-only / Q-only
                //
                // Inputs are 4-bit offset binary:
                // 4'd8  = zero
                // 4'd15 = positive max
                // 4'd0  = negative max
                // =================================================
                repeat (4) begin
                    apply_bus_b_sample(4'd15, 4'd8);
                    apply_bus_b_sample(4'd8 , 4'd15);
                    apply_bus_b_sample(4'd0 , 4'd8);
                    apply_bus_b_sample(4'd8 , 4'd0);
                end

            end

            repeat (20) @(posedge i_clk);
        end

        $display("\nFIN TEST WRAPPER");
        $finish;
    end

endmodule
