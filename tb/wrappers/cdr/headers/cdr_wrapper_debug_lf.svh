task automatic test_cdr_wrapper_debug_lf();
    logic [21:0] bus_val;
    logic signed [3:0] ctrl;
    begin
        $display("\n========== TEST: CFG3 (LOOP FILTER) ==========");
        set_config(3'b011);
        repeat(2) @(posedge i_clk);

        $display("  [LF] Injection d'une impulsion UP...");
        bus_val = '0;
        bus_val[12] = 1'b1; // w_lf_up = 1
        set_bus(bus_val);
        bus_val[12] = 1'b0;
        set_bus(bus_val); // Rabaisser le signal
        
        ctrl = o_bus_out[3:0]; // o_bus_out contient s_control
        assert (ctrl == 4'sd1) 
            $display("  [LF] PASS: Commande de controle = +1");
        else $error("  [LF] FAIL: ctrl devrait etre +1 apres un UP");

        $display("  [LF] Envoi de l'acquittement (ACK)...");
        bus_val[10] = 1'b1; // w_lf_ctrl_ack = 1
        set_bus(bus_val);
        bus_val[10] = 1'b0;
        set_bus(bus_val);
        
        ctrl = o_bus_out[3:0];
        assert (ctrl == 4'sd0) 
            $display("  [LF] PASS: Commande remise a zero");
        else $error("  [LF] FAIL: ctrl devrait etre 0 apres un ACK");

        $display("========== CFG3 COMPLETE ==========\n");
    end
endtask