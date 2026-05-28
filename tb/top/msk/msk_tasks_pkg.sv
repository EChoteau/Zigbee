package msk_tasks_pkg;

    import tb_pkg::*;
    import msk_pkg::*;

    // ----------------------------
    // Bus-style tests adapted from tb/msk
    // ----------------------------
    `define MSK_ARGS \
        ref logic i_clk, \
        ref logic i_rst_n, \
        ref logic [tb_pkg::CFG_WIDTH-1:0] i_cfg_local, \
        ref logic [tb_pkg::CFG_WIDTH-1:0] i_top_cfg, \
        ref logic [tb_pkg::BUS_IN_WIDTH-1:0] i_bus_in, \
        ref logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out
    // Helper accessors for top bus mapping
    function automatic logic signed [5:0] bus_get_I(input logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out);
        return $signed(o_bus_out[11:6]);
    endfunction

    function automatic logic signed [5:0] bus_get_Q(input logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out);
        return $signed(o_bus_out[5:0]);
    endfunction

    // Top-level MSK basic operation test (adapted from tb_top_msk_bus)
    task automatic test_msk_top_basic_operation(`MSK_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
        logic signed [5:0] signed_I;
        logic signed [5:0] signed_Q;
    begin
        $display("--- MSK TOP TEST : operation normale ---");

        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, CFG_NORMAL);
        repeat(2) @(posedge i_clk);

        bus_val = '0;
        bus_val[0] = 1'b1; // flag_enable
        bus_val[1] = 1'b1; // enable_ech
        bus_val[2] = 1'b1; // b_in
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

        repeat (8) @(posedge i_clk);

        signed_I = bus_get_I(o_bus_out);
        signed_Q = bus_get_Q(o_bus_out);

        assert (signed_I >= -31 && signed_I <= 31)
            else $error("MSK TOP FAIL: I hors limites, I=%0d", signed_I);
        assert (signed_Q >= -31 && signed_Q <= 31)
            else $error("MSK TOP FAIL: Q hors limites, Q=%0d", signed_Q);
        $display("MSK TOP PASS: sorties I=%0d Q=%0d", signed_I, signed_Q);
    end
    endtask

    // Top-level MSK debug bypass test (adapted from tb_top_msk_bus)
    task automatic test_msk_top_debug_bypass(`MSK_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
        logic dbg_b_enc_val;
    begin
        $display("--- MSK TOP TEST : debug bypass encodeur ---");

        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, CFG_DEBUG_ENC);
        repeat(2) @(posedge i_clk);

        bus_val = '0;
        bus_val[0] = 1'b1; // flag_enable
        bus_val[1] = 1'b1; // enable_ech
        bus_val[3] = 1'b1; // dbg_enc_override_en
        bus_val[4] = 1'b0; // dbg_enc_b_in
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

        repeat (4) @(posedge i_clk);

        dbg_b_enc_val = o_bus_out[0]; // debug encodeur appears at OUT[0] in CFG_DEBUG_ENC

        assert (dbg_b_enc_val !== 1'bx)
            else $error("MSK TOP FAIL: debug bus enc non initialise (contient X)");
        $display("MSK TOP PASS: debug output presente, o_dbg_b_enc=%b", dbg_b_enc_val);
    end
    endtask

    task automatic run_msk_bus_test_plan(`MSK_ARGS);
    begin
        test_msk_top_basic_operation(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        test_msk_top_debug_bypass(i_clk, i_rst_n, i_wrapper_cfg, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
    end
    endtask

    // Verify outputs after reset are stable/zeroed where expected
    task automatic test_msk_reset_behavior(`MSK_ARGS);
        logic signed [5:0] signed_I;
        logic signed [5:0] signed_Q;
    begin
        $display("--- MSK TOP TEST : reset behaviour ---");
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_MSK);
        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, CFG_NORMAL);
        repeat (2) @(posedge i_clk);

        signed_I = bus_get_I(o_bus_out);
        signed_Q = bus_get_Q(o_bus_out);

        assert (signed_I == 0)
            else $error("MSK RESET FAIL: I non nul après reset, I=%0d", signed_I);
        assert (signed_Q == 0)
            else $error("MSK RESET FAIL: Q non nul après reset, Q=%0d", signed_Q);

        $display("MSK RESET PASS: sorties I=%0d Q=%0d", signed_I, signed_Q);
    end
    endtask

    // Exercise encoder in debug-override mode with a small bit sequence
    task automatic test_msk_encoder_sequence(`MSK_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
        logic dbg_b_enc_val;
    begin
        $display("--- MSK TOP TEST : encoder sequence ---");

        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_MSK);
        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, CFG_DEBUG_ENC);
        repeat (2) @(posedge i_clk);

        // Sequence: 1 -> 0 -> 1, check encoder XNOR behavior (initial o_b_out == 1)
        // Step 1: b_in = 1
        bus_val = '0;
        bus_val[0] = 1'b1; // flag_enable
        bus_val[3] = 1'b1; // dbg_enc_override_en
        bus_val[4] = 1'b1; // dbg_enc_b_in
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        @(posedge i_clk);
        dbg_b_enc_val = o_bus_out[0];
        assert (dbg_b_enc_val === 1'b1)
            else $error("MSK ENC SEQ FAIL: step1 expected 1 got %b", dbg_b_enc_val);

        // Step 2: b_in = 0
        bus_val[4] = 1'b0; // dbg_enc_b_in
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        @(posedge i_clk);
        dbg_b_enc_val = o_bus_out[0];
        assert (dbg_b_enc_val === 1'b0)
            else $error("MSK ENC SEQ FAIL: step2 expected 0 got %b", dbg_b_enc_val);

        // Step 3: b_in = 1
        bus_val[4] = 1'b1; // dbg_enc_b_in
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        @(posedge i_clk);
        dbg_b_enc_val = o_bus_out[0];
        assert (dbg_b_enc_val === 1'b1)
            else $error("MSK ENC SEQ FAIL: step3 expected 1 got %b", dbg_b_enc_val);

        $display("MSK ENC SEQ PASS: encoder produced expected sequence");
    end
    endtask

    task automatic run_msk_test_plan_full(`MSK_ARGS);
    begin
        $display("              MSK BLOCK TEST PLAN (FULL)                          ");
        // INITIAL RESET + DEFAULT CONFIG
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_MSK);
        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, CFG_NORMAL);
        repeat (2) @(posedge i_clk);

        // Run wrapper-level tests first
        run_msk_wrapper_test_plan(i_clk, i_rst_n, i_wrapper_cfg, i_bus_in, o_bus_out);

        // ===== Bus-based top tests (adapted from legacy TBs) =====

        // BASIC OPERATION
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_MSK);
        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, CFG_NORMAL);
        repeat (2) @(posedge i_clk);
        test_msk_top_basic_operation(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);

        // DEBUG BYPASS (ENCODER)
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_MSK);
        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, CFG_DEBUG_ENC);
        repeat (2) @(posedge i_clk);
        test_msk_top_debug_bypass(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);

        $display("           [MSK TEST PLAN FULL] PASS                              ");
    end
    endtask

endpackage : msk_tasks_pkg