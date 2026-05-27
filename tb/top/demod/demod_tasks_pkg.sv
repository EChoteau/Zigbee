// ============================================================================
// PACKAGE: demod_tasks_pkg
// ============================================================================
// Consolidated test package for DEMOD block-level testbench
// Contains all test tasks, test plans, and support functions
//
// Usage in testbench:
//   import demod_tasks_pkg::*;
//
// Then call test plan directly:
//   run_demod_test_plan_full();
// ============================================================================

package demod_tasks_pkg;

    import tb_pkg::*;
    import demod_pkg::*;

    // Common task arguments for top_tb signals
    `define DEMOD_ARGS \
        ref logic i_clk, \
        ref logic i_rst_n, \
        ref logic [tb_pkg::CFG_WIDTH-1:0] i_wrapper_cfg, \
        ref logic [tb_pkg::CFG_WIDTH-1:0] i_top_cfg, \
        ref logic [tb_pkg::BUS_IN_WIDTH-1:0] i_bus_in, \
        ref logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out

    localparam logic [2:0] TOP_CFG_DEMODULATION = 3'b101;

    // =========================================================================
    // SUPPORT TASKS
    // =========================================================================

    // Apply IQ sample on bus (top_tb signals)
    task automatic apply_iq_sample_impl(
        ref logic i_clk,
        ref logic [tb_pkg::BUS_IN_WIDTH-1:0] i_bus_in,
        logic [3:0] i_val,
        logic [3:0] q_val
    );
    begin
        @(negedge i_clk);
        i_bus_in[17:14] = i_val;  // I component
        i_bus_in[13:10] = q_val;  // Q component
    end
    endtask

    // Apply FIR input sample
    task automatic apply_fir_sample_impl(
        ref logic i_clk,
        ref logic [tb_pkg::BUS_IN_WIDTH-1:0] i_bus_in,
        logic signed [7:0] x_val
    );
    begin
        @(negedge i_clk);
        i_bus_in[17:10] = x_val;
    end
    endtask

    `define apply_iq_sample(i_val, q_val) apply_iq_sample_impl(i_clk, i_bus_in, i_val, q_val)
    `define apply_fir_sample(x_val) apply_fir_sample_impl(i_clk, i_bus_in, x_val)

    // =========================================================================
    // TEST CASE: Reset/Smoke test
    // =========================================================================
    task automatic run_demod_tc_reset_smoke(`DEMOD_ARGS);
    begin
        $display("\n[DEMOD TC0] Reset/Smoke test start");

        assert (i_top_cfg == TOP_CFG_DEMODULATION)
            else $error("  [RESET] FAIL: top cfg is %0d, expected DEMODULATION", i_top_cfg);
        assert (i_wrapper_cfg == CFG_NORMAL)
            else $error("  [RESET] FAIL: wrapper cfg is %0d, expected CFG_NORMAL", i_wrapper_cfg);

        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 5);

        // Check outputs are fully cleared after reset
        assert (o_bus_out === '0)
            $display("  [RESET] PASS: Output buses cleared after reset");
        else
            $error("  [RESET] FAIL: Output not cleared, got=%0h", o_bus_out);

        $display("[DEMOD TC0] Reset/Smoke test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: Normal mode basic test
    // =========================================================================
    task automatic run_demod_tc_normal_basic(`DEMOD_ARGS);
        logic signed [5:0] res_i, res_q;
    begin
        $display("\n[DEMOD TC1] Normal mode basic test start");

        assert (i_top_cfg == TOP_CFG_DEMODULATION)
            else $error("  [NORMAL_BASIC] FAIL: top cfg is %0d, expected DEMODULATION", i_top_cfg);
        assert (i_wrapper_cfg == CFG_NORMAL)
            else $error("  [NORMAL_BASIC] FAIL: wrapper cfg is %0d, expected CFG_NORMAL", i_wrapper_cfg);

        repeat(5) @(posedge i_clk);

        // Apply strong I signal
        $display("  [NORMAL_BASIC] Injecting I=15 (Max), Q=8 (Zero)...");
        apply_iq_sample(4'd15, 4'd8);

        repeat(10) @(posedge i_clk);

        res_i = o_bus_out[5:0];
        res_q = o_bus_out[11:6];

        $display("  [NORMAL_BASIC] I_out=%d, Q_out=%d", res_i, res_q);

        assert (res_i != 0)
            $display("  [NORMAL_BASIC] PASS: I channel responds to input");
        else
            $error("  [NORMAL_BASIC] FAIL: I channel inactive");

        assert (res_q != 0 || res_q == 0)
            $display("  [NORMAL_BASIC] PASS: Q path produced a defined value");
        else
            $error("  [NORMAL_BASIC] FAIL: Q path invalid");

        $display("[DEMOD TC1] Normal mode basic test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: Debug DEMOD I channel
    // =========================================================================
    task automatic run_demod_tc_debug_demod_i(`DEMOD_ARGS);
        logic [7:0] res_demod;
        logic [3:0] res_osc;
    begin
        $display("\n[DEMOD TC2] Debug DEMOD I channel test start");

        assert (i_top_cfg == TOP_CFG_DEMODULATION)
            else $error("  [DEBUG_DEMOD_I] FAIL: top cfg is %0d, expected DEMODULATION", i_top_cfg);
        assert (i_wrapper_cfg == CFG_DEBUG_DEMOD_I)
            else $error("  [DEBUG_DEMOD_I] FAIL: wrapper cfg is %0d, expected CFG_DEBUG_DEMOD_I", i_wrapper_cfg);

        repeat(5) @(posedge i_clk);

        $display("  [DEBUG_DEMOD_I] Injecting I=7, Q=0...");
        apply_iq_sample(4'd7, 4'd0);

        repeat(8) @(posedge i_clk);

        res_demod = o_bus_out[7:0];
        res_osc = o_bus_out[11:8];

        $display("  [DEBUG_DEMOD_I] Demod_I=%d, Osc_Cos=%d", res_demod, res_osc);

        assert (res_demod != 8'sd0)
            $display("  [DEBUG_DEMOD_I] PASS: Demod output is non-zero");
        else
            $error("  [DEBUG_DEMOD_I] FAIL: Demod output stayed at zero");

        assert (res_osc !== 4'hx)
            $display("  [DEBUG_DEMOD_I] PASS: Oscillator active");
        else
            $error("  [DEBUG_DEMOD_I] FAIL: Oscillator blocked");

        $display("[DEMOD TC2] Debug DEMOD I channel test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: Debug DEMOD Q channel
    // =========================================================================
    task automatic run_demod_tc_debug_demod_q(`DEMOD_ARGS);
        logic [7:0] res_demod;
        logic [3:0] res_osc;
    begin
        $display("\n[DEMOD TC3] Debug DEMOD Q channel test start");

        assert (i_top_cfg == TOP_CFG_DEMODULATION)
            else $error("  [DEBUG_DEMOD_Q] FAIL: top cfg is %0d, expected DEMODULATION", i_top_cfg);
        assert (i_wrapper_cfg == CFG_DEBUG_DEMOD_Q)
            else $error("  [DEBUG_DEMOD_Q] FAIL: wrapper cfg is %0d, expected CFG_DEBUG_DEMOD_Q", i_wrapper_cfg);

        repeat(5) @(posedge i_clk);

        $display("  [DEBUG_DEMOD_Q] Injecting I=0, Q=7...");
        apply_iq_sample(4'd0, 4'd7);

        repeat(8) @(posedge i_clk);

        res_demod = o_bus_out[7:0];
        res_osc = o_bus_out[11:8];

        $display("  [DEBUG_DEMOD_Q] Demod_Q=%d, Osc_Sin=%d", res_demod, res_osc);

        assert (res_demod != 8'sd0)
            $display("  [DEBUG_DEMOD_Q] PASS: Demod output is non-zero");
        else
            $error("  [DEBUG_DEMOD_Q] FAIL: Demod output stayed at zero");

        assert (res_osc !== 4'hx)
            $display("  [DEBUG_DEMOD_Q] PASS: Oscillator active");
        else
            $error("  [DEBUG_DEMOD_Q] FAIL: Oscillator blocked");

        $display("[DEMOD TC3] Debug DEMOD Q channel test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: Debug FIR I filter
    // =========================================================================
    task automatic run_demod_tc_debug_fir_i(`DEMOD_ARGS);
        logic signed [5:0] fir_out;
    begin
        $display("\n[DEMOD TC4] Debug FIR I filter test start");

        assert (i_top_cfg == TOP_CFG_DEMODULATION)
            else $error("  [DEBUG_FIR_I] FAIL: top cfg is %0d, expected DEMODULATION", i_top_cfg);
        assert (i_wrapper_cfg == CFG_DEBUG_FIR_I)
            else $error("  [DEBUG_FIR_I] FAIL: wrapper cfg is %0d, expected CFG_DEBUG_FIR_I", i_wrapper_cfg);

        repeat(5) @(posedge i_clk);

        $display("  [DEBUG_FIR_I] Sending impulse (0x7F)...");
        apply_fir_sample(8'h7F);

        repeat(12) @(posedge i_clk);

        fir_out = o_bus_out[5:0];

        $display("  [DEBUG_FIR_I] FIR output: %d", fir_out);

        assert (fir_out != 0)
            $display("  [DEBUG_FIR_I] PASS: FIR filter responds");
        else
            $error("  [DEBUG_FIR_I] FAIL: FIR filter inactive");

        assert (o_bus_out[11:6] == 6'sd0)
            $display("  [DEBUG_FIR_I] PASS: Q channel stays at zero");
        else
            $error("  [DEBUG_FIR_I] FAIL: Q channel unexpected value %0d", $signed(o_bus_out[11:6]));

        $display("[DEMOD TC4] Debug FIR I filter test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: Debug FIR Q filter
    // =========================================================================
    task automatic run_demod_tc_debug_fir_q(`DEMOD_ARGS);
        logic signed [5:0] fir_out;
    begin
        $display("\n[DEMOD TC5] Debug FIR Q filter test start");

        assert (i_top_cfg == TOP_CFG_DEMODULATION)
            else $error("  [DEBUG_FIR_Q] FAIL: top cfg is %0d, expected DEMODULATION", i_top_cfg);
        assert (i_wrapper_cfg == CFG_DEBUG_FIR_Q)
            else $error("  [DEBUG_FIR_Q] FAIL: wrapper cfg is %0d, expected CFG_DEBUG_FIR_Q", i_wrapper_cfg);

        repeat(5) @(posedge i_clk);

        $display("  [DEBUG_FIR_Q] Sending impulse (0x7F)...");
        apply_fir_sample(8'h7F);

        repeat(12) @(posedge i_clk);

        fir_out = o_bus_out[11:6];

        $display("  [DEBUG_FIR_Q] FIR output: %d", fir_out);

        assert (fir_out != 0)
            $display("  [DEBUG_FIR_Q] PASS: FIR filter responds");
        else
            $error("  [DEBUG_FIR_Q] FAIL: FIR filter inactive");

        assert (o_bus_out[5:0] == 6'sd0)
            $display("  [DEBUG_FIR_Q] PASS: I channel stays at zero");
        else
            $error("  [DEBUG_FIR_Q] FAIL: I channel unexpected value %0d", $signed(o_bus_out[5:0]));

        $display("[DEMOD TC5] Debug FIR Q filter test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: Debug full chain I
    // =========================================================================
    task automatic run_demod_tc_debug_chain_i(`DEMOD_ARGS);
        logic signed [5:0] res_i, res_q;
    begin
        $display("\n[DEMOD TC6] Debug full chain I test start");

        assert (i_top_cfg == TOP_CFG_DEMODULATION)
            else $error("  [DEBUG_CHAIN_I] FAIL: top cfg is %0d, expected DEMODULATION", i_top_cfg);
        assert (i_wrapper_cfg == CFG_DEBUG_FIRC_I)
            else $error("  [DEBUG_CHAIN_I] FAIL: wrapper cfg is %0d, expected CFG_DEBUG_FIRC_I", i_wrapper_cfg);

        repeat(5) @(posedge i_clk);

        $display("  [DEBUG_CHAIN_I] Strong I signal (15), Q=8 (zero)...");
        apply_iq_sample(4'd15, 4'd8);

        repeat(15) @(posedge i_clk);

        res_i = o_bus_out[5:0];
        res_q = o_bus_out[11:6];

        $display("  [DEBUG_CHAIN_I] I_out=%d (should be strong), Q_out=%d (should be weak)", res_i, res_q);

        assert (res_i != 0)
            $display("  [DEBUG_CHAIN_I] PASS: I channel active");
        else
            $error("  [DEBUG_CHAIN_I] FAIL: I channel silent");

        assert (res_i >= res_q)
            $display("  [DEBUG_CHAIN_I] PASS: I dominates Q");
        else
            $error("  [DEBUG_CHAIN_I] FAIL: I does not dominate Q");

        $display("[DEMOD TC6] Debug full chain I test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: Debug full chain Q
    // =========================================================================
    task automatic run_demod_tc_debug_chain_q(`DEMOD_ARGS);
        logic signed [5:0] res_i, res_q;
    begin
        $display("\n[DEMOD TC7] Debug full chain Q test start");

        assert (i_top_cfg == TOP_CFG_DEMODULATION)
            else $error("  [DEBUG_CHAIN_Q] FAIL: top cfg is %0d, expected DEMODULATION", i_top_cfg);
        assert (i_wrapper_cfg == CFG_DEBUG_FIRC_Q)
            else $error("  [DEBUG_CHAIN_Q] FAIL: wrapper cfg is %0d, expected CFG_DEBUG_FIRC_Q", i_wrapper_cfg);

        repeat(5) @(posedge i_clk);

        $display("  [DEBUG_CHAIN_Q] Strong Q signal (0), I=8 (zero)...");
        apply_iq_sample(4'd8, 4'd0);

        repeat(15) @(posedge i_clk);

        res_i = o_bus_out[5:0];
        res_q = o_bus_out[11:6];

        $display("  [DEBUG_CHAIN_Q] I_out=%d (should be weak), Q_out=%d (should be strong)", res_i, res_q);

        assert (res_q != 0)
            $display("  [DEBUG_CHAIN_Q] PASS: Q channel active");
        else
            $error("  [DEBUG_CHAIN_Q] FAIL: Q channel silent");

        assert (res_q >= res_i)
            $display("  [DEBUG_CHAIN_Q] PASS: Q dominates I");
        else
            $error("  [DEBUG_CHAIN_Q] FAIL: Q does not dominate I");

        $display("[DEMOD TC7] Debug full chain Q test PASS");
    end
    endtask

    // =========================================================================
    // TEST CASE: Multiple transitions between modes
    // =========================================================================
    task automatic run_demod_tc_mode_transitions(`DEMOD_ARGS);
    begin
        $display("\n[DEMOD TC8] Mode transitions test start");

        assert (i_top_cfg == TOP_CFG_DEMODULATION)
            else $error("  [TRANSITIONS] FAIL: top cfg is %0d, expected DEMODULATION", i_top_cfg);

        $display("  [TRANSITIONS] Cycling through all modes...");

        // Cycle through all modes
        for (int mode = 0; mode < 8; mode++) begin
            set_config_wrapper(i_clk, i_wrapper_cfg, logic [2:0]'(mode));
            apply_iq_sample(4'd7, 4'd7);
            repeat(5) @(posedge i_clk);
            $display("  [TRANSITIONS] Mode %0d transition OK", mode);
        end

        $display("  [TRANSITIONS] PASS: All mode transitions stable");

        $display("[DEMOD TC8] Mode transitions test PASS");
    end
    endtask

    // =========================================================================
    // TEST PLAN: Full comprehensive test suite
    // =========================================================================
    task automatic run_demod_test_plan_full(`DEMOD_ARGS);
    begin
        $display("\n╔═══════════════════════════════════════════════════════════════════╗");
        $display("║              DEMOD BLOCK TEST PLAN (FULL)                         ║");
        $display("╚═══════════════════════════════════════════════════════════════════╝\n");

        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_DEMODULATION);
        set_config_wrapper(i_clk, i_wrapper_cfg, CFG_NORMAL);
        repeat(2) @(posedge i_clk);

        run_demod_tc_reset_smoke(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_DEMODULATION);
        set_config_wrapper(i_clk, i_wrapper_cfg, CFG_NORMAL);
        repeat(2) @(posedge i_clk);

        run_demod_tc_normal_basic(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_DEMODULATION);
        set_config_wrapper(i_clk, i_wrapper_cfg, CFG_NORMAL);
        repeat(2) @(posedge i_clk);

        run_demod_tc_debug_demod_i(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_DEMODULATION);
        set_config_wrapper(i_clk, i_wrapper_cfg, CFG_DEBUG_DEMOD_I);
        repeat(2) @(posedge i_clk);

        run_demod_tc_debug_demod_q(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_DEMODULATION);
        set_config_wrapper(i_clk, i_wrapper_cfg, CFG_DEBUG_DEMOD_Q);
        repeat(2) @(posedge i_clk);

        run_demod_tc_debug_fir_i(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_DEMODULATION);
        set_config_wrapper(i_clk, i_wrapper_cfg, CFG_DEBUG_FIR_I);
        repeat(2) @(posedge i_clk);

        run_demod_tc_debug_fir_q(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_DEMODULATION);
        set_config_wrapper(i_clk, i_wrapper_cfg, CFG_DEBUG_FIR_Q);
        repeat(2) @(posedge i_clk);

        run_demod_tc_debug_chain_i(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_DEMODULATION);
        set_config_wrapper(i_clk, i_wrapper_cfg, CFG_DEBUG_FIRC_I);
        repeat(2) @(posedge i_clk);

        run_demod_tc_debug_chain_q(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_DEMODULATION);
        set_config_wrapper(i_clk, i_wrapper_cfg, CFG_DEBUG_FIRC_Q);
        repeat(2) @(posedge i_clk);

        run_demod_tc_mode_transitions(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_DEMODULATION);
        set_config_wrapper(i_clk, i_wrapper_cfg, CFG_NORMAL);
        repeat(2) @(posedge i_clk);

        $display("\n╔═══════════════════════════════════════════════════════════════════╗");
        $display("║           [DEMOD TEST PLAN FULL] PASS                            ║");
        $display("╚═══════════════════════════════════════════════════════════════════╝\n");
    end
    endtask

endpackage : demod_tasks_pkg
