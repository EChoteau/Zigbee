package cdr_tasks_pkg;

    import tb_pkg::*;
    import cdr_pkg::*;

    `define CDR_ARGS \
        ref logic i_clk, \
        ref logic i_rst_n, \
        ref logic [tb_pkg::CFG_WIDTH-1:0] i_wrapper_cfg, \
        ref logic [tb_pkg::CFG_WIDTH-1:0] i_top_cfg, \
        ref logic [tb_pkg::BUS_IN_WIDTH-1:0] i_bus_in, \
        ref logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out

    function automatic logic get_sample_enable(input logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out);
        return o_bus_out[0];
    endfunction

    function automatic logic get_data(input logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out);
        return o_bus_out[1];
    endfunction

    function automatic logic get_ack(input logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out);
        return o_bus_out[0];
    endfunction

    function automatic logic signed [3:0] get_ctrl(input logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out);
        return $signed(o_bus_out[3:0]);
    endfunction

    function automatic logic get_decision(input logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out);
        return o_bus_out[0];
    endfunction

    function automatic logic get_up(input logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out);
        return o_bus_out[1];
    endfunction

    function automatic logic get_down(input logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out);
        return o_bus_out[0];
    endfunction

    task automatic test_cdr_mode0_normal(`CDR_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
        int timeout;
        bit data_ok;
    begin
        $display("--- CDR TOP TEST : MODE_0 NORMAL ---");

        assert (i_top_cfg == TOP_CFG_CDR)
            else $error("CDR MODE0 FAIL: top config is %0d, expected TOP_CFG_CDR", i_top_cfg);

        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, CFG_NORMAL);
        repeat (2) @(posedge i_clk);

        bus_val = '0;
        bus_val[7:0] = 8'sd8;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

        timeout = 0;
        data_ok = 1'b0;
        while (timeout < 50 && data_ok == 1'b0) begin
            @(posedge i_clk);
            if (get_sample_enable(o_bus_out)) begin
                data_ok = (get_data(o_bus_out) == 1'b1);
            end
            timeout++;
        end

        assert (data_ok == 1'b1)
            else $error("CDR MODE0 FAIL: data '1' not recovered");

        $display("CDR MODE0 PASS");
    end
    endtask

    task automatic test_cdr_mode1_debug_decision(`CDR_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
    begin
        $display("--- CDR TOP TEST : MODE_1 DECISION ---");

        assert (i_top_cfg == TOP_CFG_CDR)
            else $error("CDR MODE1 FAIL: top config is %0d, expected TOP_CFG_CDR", i_top_cfg);

        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, CFG_DEBUG_DECISION);
        repeat (2) @(posedge i_clk);

        bus_val = '0;
        bus_val[7:0] = 8'sd8;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        repeat (2) @(posedge i_clk);

        assert (get_decision(o_bus_out) == 1'b1)
            else $error("CDR MODE1 FAIL: positive dphi should give decision=1");

        bus_val[7:0] = -8'sd8;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        repeat (2) @(posedge i_clk);

        assert (get_decision(o_bus_out) == 1'b0)
            else $error("CDR MODE1 FAIL: negative dphi should give decision=0");

        $display("CDR MODE1 PASS");
    end
    endtask

    task automatic test_cdr_mode2_debug_pd(`CDR_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
    begin
        $display("--- CDR TOP TEST : MODE_2 PHASE DETECTOR ---");

        assert (i_top_cfg == TOP_CFG_CDR)
            else $error("CDR MODE2 FAIL: top config is %0d, expected TOP_CFG_CDR", i_top_cfg);

        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, CFG_DEBUG_PD);
        repeat (2) @(posedge i_clk);

        bus_val = '0;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        repeat (2) @(posedge i_clk);

        bus_val[11] = 1'b1;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        repeat (1) @(posedge i_clk);

        bus_val[10] = 1'b1;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        repeat (2) @(posedge i_clk);

        assert (get_up(o_bus_out) != 1'b0 || get_down(o_bus_out) != 1'b0)
            else $error("CDR MODE2 FAIL: phase detector did not react");

        $display("CDR MODE2 PASS");
    end
    endtask

    task automatic test_cdr_mode3_debug_lf(`CDR_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
    begin
        $display("--- CDR TOP TEST : MODE_3 LOOP FILTER ---");

        assert (i_top_cfg == TOP_CFG_CDR)
            else $error("CDR MODE3 FAIL: top config is %0d, expected TOP_CFG_CDR", i_top_cfg);

        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, CFG_DEBUG_LF);
        repeat (2) @(posedge i_clk);

        bus_val = '0;
        bus_val[12] = 1'b1;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        bus_val[12] = 1'b0;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        repeat (2) @(posedge i_clk);

        assert (get_ctrl(o_bus_out) == 4'sd1)
            else $error("CDR MODE3 FAIL: ctrl should be +1 after UP");

        bus_val = '0;
        bus_val[10] = 1'b1;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        bus_val[10] = 1'b0;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        repeat (2) @(posedge i_clk);

        assert (get_ctrl(o_bus_out) == 4'sd0)
            else $error("CDR MODE3 FAIL: ctrl should be 0 after ACK");

        $display("CDR MODE3 PASS");
    end
    endtask

    task automatic test_cdr_mode4_debug_nco(`CDR_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
        int timeout;
    begin
        $display("--- CDR TOP TEST : MODE_4 NCO ---");

        assert (i_top_cfg == TOP_CFG_CDR)
            else $error("CDR MODE4 FAIL: top config is %0d, expected TOP_CFG_CDR", i_top_cfg);

        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, CFG_DEBUG_NCO);
        repeat (2) @(posedge i_clk);

        bus_val = '0;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);

        timeout = 0;
        while (get_ack(o_bus_out) == 1'b0 && timeout < 20) begin
            @(posedge i_clk);
            timeout++;
        end

        assert (timeout < 20)
            else $error("CDR MODE4 FAIL: NCO did not toggle ack");

        $display("CDR MODE4 PASS");
    end
    endtask

    task automatic run_cdr_test_plan_full(`CDR_ARGS);
    begin
        $display("              CDR BLOCK TEST PLAN (FULL)                         ");

        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_CDR);
        repeat (2) @(posedge i_clk);
        test_cdr_mode0_normal(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);

        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_CDR);
        repeat (2) @(posedge i_clk);
        test_cdr_mode1_debug_decision(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);

        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_CDR);
        repeat (2) @(posedge i_clk);
        test_cdr_mode2_debug_pd(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);

        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_CDR);
        repeat (2) @(posedge i_clk);
        test_cdr_mode3_debug_lf(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);

        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_CDR);
        repeat (2) @(posedge i_clk);
        test_cdr_mode4_debug_nco(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);

        $display("           [CDR TEST PLAN FULL] PASS                           ");
    end
    endtask

endpackage : cdr_tasks_pkg