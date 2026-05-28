package cordic_tasks_pkg;

    import tb_pkg::*;
    import cordic_pkg::*;

    function automatic logic signed [7:0] get_phase(input logic [tb_pkg::BUS_OUT_WIDTH-1:0] o_bus_out);
        return $signed(o_bus_out[7:0]);
    endfunction

    task automatic test_cordic_mode1_debug_cordic(`CORDIC_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
        logic signed [7:0] phase_out;
    begin
        $display("--- CORDIC TOP TEST : MODE_1 CORDIC ONLY ---");

        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, MODE_1_CORDIC_ONLY);
        repeat (2) @(posedge i_clk);

        bus_val = '0;
        bus_val[5:0]  = 6'd31;
        bus_val[11:6] = 6'd31;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        repeat (15) @(posedge i_clk);

        phase_out = get_phase(o_bus_out);
        assert (phase_out > 8'sd20)
            else $error("CORDIC MODE1 FAIL: quadrant+ attendu >20, obtenu=%0d", phase_out);

        bus_val[11:6] = -6'sd31;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        repeat (15) @(posedge i_clk);

        phase_out = get_phase(o_bus_out);
        assert (phase_out < -8'sd20)
            else $error("CORDIC MODE1 FAIL: quadrant- attendu <-20, obtenu=%0d", phase_out);

        $display("CORDIC MODE1 PASS");
    end
    endtask

    task automatic test_cordic_mode2_debug_deriv(`CORDIC_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
        logic signed [7:0] deriv_out;
    begin
        $display("--- CORDIC TOP TEST : MODE_2 DERIV ONLY ---");

        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, MODE_2_DERIV_ONLY);
        repeat (2) @(posedge i_clk);

        bus_val = '0;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        repeat (2) @(posedge i_clk);

        bus_val[7:0] = 8'd10;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        @(posedge i_clk);
        deriv_out = get_phase(o_bus_out);
        assert (deriv_out == 8'sd10)
            else $error("CORDIC MODE2 FAIL: derivee attendu 10, obtenu=%0d", deriv_out);

        bus_val[7:0] = 8'd20;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        @(posedge i_clk);
        deriv_out = get_phase(o_bus_out);
        assert (deriv_out == 8'sd10)
            else $error("CORDIC MODE2 FAIL: derivee attendu 10 (step2), obtenu=%0d", deriv_out);

        $display("CORDIC MODE2 PASS");
    end
    endtask

    task automatic test_cordic_mode3_debug_filter(`CORDIC_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
        logic signed [7:0] filt_out;
    begin
        $display("--- CORDIC TOP TEST : MODE_3 FILTER ONLY ---");

        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, MODE_3_FILTER_ONLY);
        repeat (2) @(posedge i_clk);

        bus_val = '0;
        bus_val[7:0] = 8'sd20;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        repeat (10) @(posedge i_clk);

        filt_out = get_phase(o_bus_out);
        assert (filt_out == 8'sd100)
            else $error("CORDIC MODE3 FAIL: filtre attendu 100, obtenu=%0d", filt_out);

        $display("CORDIC MODE3 PASS");
    end
    endtask

    task automatic test_cordic_mode4_cordic_deriv(`CORDIC_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
        logic signed [7:0] deriv_out;
    begin
        $display("--- CORDIC TOP TEST : MODE_4 CORDIC+DERIV ---");

        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, MODE_4_CORDIC_DERIV);
        repeat (2) @(posedge i_clk);

        bus_val = '0;
        bus_val[5:0]  = 6'd31;
        bus_val[11:6] = 6'd31;
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        repeat (20) @(posedge i_clk);

        deriv_out = get_phase(o_bus_out);
        assert (deriv_out >= -8'sd2 && deriv_out <= 8'sd2)
            else $error("CORDIC MODE4 FAIL: derivee statique attendue proche 0, obtenu=%0d", deriv_out);

        $display("CORDIC MODE4 PASS");
    end
    endtask

    task automatic test_cordic_mode5_full_chain(`CORDIC_ARGS);
        logic [tb_pkg::BUS_IN_WIDTH-1:0] bus_val;
        logic signed [7:0] out_phase;
    begin
        $display("--- CORDIC TOP TEST : MODE_5 FULL CHAIN ---");

        tb_pkg::set_config_wrapper(i_clk, i_wrapper_cfg, MODE_5_FULL_CHAIN);
        repeat (2) @(posedge i_clk);

        for (int i = 0; i < 20; i++) begin
            bus_val = '0;
            case (i % 4)
                0: begin bus_val[5:0] =  6'sd31; bus_val[11:6] =  6'sd31; end
                1: begin bus_val[5:0] = -6'sd31; bus_val[11:6] =  6'sd31; end
                2: begin bus_val[5:0] = -6'sd31; bus_val[11:6] = -6'sd31; end
                default: begin bus_val[5:0] =  6'sd31; bus_val[11:6] = -6'sd31; end
            endcase
            tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        end

        repeat (8) @(posedge i_clk);
        out_phase = get_phase(o_bus_out);

        assert (out_phase !== 8'sbx)
            else $error("CORDIC MODE5 FAIL: sortie invalide X");
        assert (out_phase > 8'sd0)
            else $error("CORDIC MODE5 FAIL: frequence attendue positive, obtenu=%0d", out_phase);

        $display("CORDIC MODE5 PASS");
    end
    endtask

    task automatic run_cordic_test_plan_full(`CORDIC_ARGS);
    begin
        $display("              CORDIC BLOCK TEST PLAN (FULL)                       ");

        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_CORDIC);
        repeat (2) @(posedge i_clk);

        test_cordic_mode1_debug_cordic(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);

        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_CORDIC);
        repeat (2) @(posedge i_clk);
        test_cordic_mode2_debug_deriv(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);

        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_CORDIC);
        repeat (2) @(posedge i_clk);
        test_cordic_mode3_debug_filter(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);

        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_CORDIC);
        repeat (2) @(posedge i_clk);
        test_cordic_mode4_cordic_deriv(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);

        tb_pkg::apply_reset(i_clk, i_rst_n, i_bus_in, 3);
        tb_pkg::set_config_top(i_clk, i_top_cfg, TOP_CFG_CORDIC);
        repeat (2) @(posedge i_clk);
        test_cordic_mode5_full_chain(i_clk, i_rst_n, i_wrapper_cfg, i_top_cfg, i_bus_in, o_bus_out);

        $display("           [CORDIC TEST PLAN FULL] PASS                           ");
    end
    endtask

endpackage : cordic_tasks_pkg
