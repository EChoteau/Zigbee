task automatic test_cdr_wrapper_debug_decision();
    logic [21:0] bus_val;
    begin
        $display("\n========== TEST: CFG1 (DECISION BLOCK) ==========");
        tb_pkg::set_config(i_clk, i_cfg_local, 3'b001);
        repeat(2) @(posedge i_clk);

        $display("  [DECISION] Test de l'avance de phase (dphi = +8)...");
        bus_val = '0;
        bus_val[7:0] = 8'sd8; // w_dphi = +8
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        repeat(2) @(posedge i_clk);
        // o_bus_out[0] = s_decision_sig
        assert (o_bus_out[0] == 1'b1) 
            $display("  [DECISION] PASS: decision = 1");
        else $error("  [DECISION] FAIL: dphi=+8 doit donner decision=1");

        $display("  [DECISION] Test du retard de phase (dphi = -8)...");
        bus_val[7:0] = -8'sd8; // w_dphi = -8
        tb_pkg::set_bus(i_clk, i_bus_in, bus_val);
        repeat(2) @(posedge i_clk);
        assert (o_bus_out[0] == 1'b0) 
            $display("  [DECISION] PASS: decision = 0");
        else $error("  [DECISION] FAIL: dphi=-8 doit donner decision=0");

        $display("========== CFG1 COMPLETE ==========\n");
    end
endtask