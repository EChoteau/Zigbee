task automatic test_msk_wrapper_debug_shaping();
    logic [21:0] bus_val;
    begin
        $display("\n========== TEST: CFG3 (DEBUG SHAPING) ==========");
        tb_pkg::set_config(i_clk, i_cfg_local, 3'b011);
        repeat(2) @(posedge i_clk);

        $display("  [SHAPING] Force a_I=1 et a_Q=1...");
        bus_val = '0;
        bus_val[5] = 1'b1; // dbg_shaping_a_I
        bus_val[6] = 1'b1; // dbg_shaping_a_Q
        bus_val[1] = 1'b1; // enable_ech
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        
        repeat(15) @(posedge i_clk);

        assert ($signed(o_bus_out[11:6]) != 0 || $signed(o_bus_out[5:0]) != 0)
            $display("  [SHAPING] PASS: Les ROMs de shaping generent les ondes I/Q !");
        else $error("  [SHAPING] FAIL: Sorties nulles");

        $display("========== CFG3 COMPLETE ==========\n");
    end
endtask