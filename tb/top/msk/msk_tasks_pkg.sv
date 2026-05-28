package msk_tasks_pkg;

    import tb_pkg::*;
    import msk_pkg::*;

    // ----------------------------
    // Bus-style tests adapted from tb/msk
    // ----------------------------
    `define MSK_ARGS \
        ref logic i_clk, \
        ref logic i_rst_n, \
        ref logic [tb_pkg::CFG_WIDTH-1:0] i_wrapper_cfg, \
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

    task automatic test_msk_top_basic_operation(`MSK_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
        logic signed [5:0] signed_I;
        logic signed [5:0] signed_Q;
    begin
        $display("--- MSK TOP TEST : operation normale ---");

        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, CFG_NORMAL);
        repeat (2) @(posedge i_clk);

        bus_val = '0;
        bus_val[0] = 1'b1;
        bus_val[1] = 1'b1;
        bus_val[2] = 1'b1;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

        repeat (8) @(posedge i_clk);

        signed_I = bus_get_I(o_bus_out);
        signed_Q = bus_get_Q(o_bus_out);

        assert (signed_I >= -31 && signed_I <= 31)
            else $error("MSK TOP FAIL: I hors limites, I=%0d", signed_I);
        assert (signed_Q >= -31 && signed_Q <= 31)
            else $error("MSK TOP FAIL: Q hors limites, Q=%0d", signed_Q);
        assert (o_bus_out[12] == 1'b1)
            else $error("MSK TOP FAIL: enable_ech non reflété sur OUT[12]");

        $display("MSK TOP PASS: sorties I=%0d Q=%0d", signed_I, signed_Q);
    end
    endtask

    task automatic test_msk_top_debug_enc(`MSK_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
    begin
        $display("--- MSK TOP TEST : debug encodeur ---");

        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, CFG_DEBUG_ENC);
        repeat (2) @(posedge i_clk);

        bus_val = '0;
        bus_val[0] = 1'b1;
        bus_val[3] = 1'b0;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        assert (o_bus_out[0] === 1'b1)
            else $error("MSK TOP FAIL: encodeur debug attendu=1, obtenu=%b", o_bus_out[0]);

        bus_val[3] = 1'b1;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        assert (o_bus_out[0] === 1'b1)
            else $error("MSK TOP FAIL: encodeur debug attendu=1 après toggle, obtenu=%b", o_bus_out[0]);

        bus_val[3] = 1'b0;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        assert (o_bus_out[0] !== 1'bx)
            else $error("MSK TOP FAIL: encodeur debug contient X");

        $display("MSK TOP PASS: debug encodeur observé");
    end
    endtask

    task automatic test_msk_top_debug_demux(`MSK_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
    begin
        $display("--- MSK TOP TEST : debug demux ---");

        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, CFG_DEBUG_DEMUX);
        repeat (2) @(posedge i_clk);

        bus_val = '0;
        bus_val[0] = 1'b1;
        bus_val[4] = 1'b0;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        assert (o_bus_out[1:0] == 2'b10)
            else $error("MSK TOP FAIL: demux debug pulse1 attendu 10, obtenu=%b", o_bus_out[1:0]);

        bus_val[4] = 1'b1;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        assert (o_bus_out[1:0] == 2'b10 || o_bus_out[1:0] == 2'b11)
            else $error("MSK TOP FAIL: demux debug pulse2 inattendu=%b", o_bus_out[1:0]);

        $display("MSK TOP PASS: debug demux observé");
    end
    endtask

    task automatic test_msk_top_debug_shaping(`MSK_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
        logic signed [5:0] signed_I;
        logic signed [5:0] signed_Q;
    begin
        $display("--- MSK TOP TEST : debug shaping ---");

        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, CFG_DEBUG_SHAPING);
        repeat (2) @(posedge i_clk);

        bus_val = '0;
        bus_val[1] = 1'b1;
        bus_val[5] = 1'b1;
        bus_val[6] = 1'b1;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

        repeat (10) @(posedge i_clk);

        signed_I = bus_get_I(o_bus_out);
        signed_Q = bus_get_Q(o_bus_out);

        assert (signed_I inside {[-31:31]})
            else $error("MSK TOP FAIL: shaping I hors limites, I=%0d", signed_I);
        assert (signed_Q inside {[-31:31]})
            else $error("MSK TOP FAIL: shaping Q hors limites, Q=%0d", signed_Q);
        assert (signed_I != 0 || signed_Q != 0)
            else $error("MSK TOP FAIL: shaping debug sorties nulles");

        $display("MSK TOP PASS: debug shaping I=%0d Q=%0d", signed_I, signed_Q);
    end
    endtask

    task automatic test_msk_top_debug_all(`MSK_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
    begin
        $display("--- MSK TOP TEST : debug all ---");

        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, CFG_DEBUG_ALL);
        repeat (2) @(posedge i_clk);

        bus_val = '0;
        bus_val[0] = 1'b1;
        bus_val[1] = 1'b1;
        bus_val[3] = 1'b1;
        bus_val[4] = 1'b1;
        bus_val[5] = 1'b1;
        bus_val[6] = 1'b1;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

        assert (o_bus_out[2:0] !== 3'b000)
            else $error("MSK TOP FAIL: debug all muet");

        $display("MSK TOP PASS: debug all observé, OUT[2:0]=%b", o_bus_out[2:0]);
    end
    endtask

    task automatic run_msk_test_plan_full(`MSK_ARGS);
    begin
        $display("              MSK BLOCK TEST PLAN (FULL)                          ");

        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_MSK);
        repeat (2) @(posedge i_clk);

        test_msk_top_basic_operation(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_MSK);
        repeat (2) @(posedge i_clk);

        test_msk_top_debug_enc(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_MSK);
        repeat (2) @(posedge i_clk);

        test_msk_top_debug_demux(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_MSK);
        repeat (2) @(posedge i_clk);

        test_msk_top_debug_shaping(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);
        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_MSK);
        repeat (2) @(posedge i_clk);

        test_msk_top_debug_all(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);

        $display("           [MSK TEST PLAN FULL] PASS                              ");
    end
    endtask

endpackage : msk_tasks_pkg