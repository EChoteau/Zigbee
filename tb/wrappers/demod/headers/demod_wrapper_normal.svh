task automatic test_demod_wrapper_normal();
    logic signed [5:0] res_i;
    logic signed [5:0] res_q;

    begin
        $display("\n========== TEST: NORMAL MODE (0x0) ==========");
        
        // 1. Configurer en mode Normal
        tb_pkg::set_config(i_clk, d_cfg_local, 3'b000); 
        repeat(2) @(posedge i_clk);

        $display("  [NORMAL] Mode production actif. Ecoute des ports ADC directs.");

        // 2. Simuler une donnee provenant de l'ADC
        // Rappel: i_i et i_q sont des signaux non-signes (0 a 15)
        // La valeur 8 (4'b1000) correspond au "zero" apres suppression de l'offset
        $display("  [NORMAL] Injection ADC : I=15 (Max Positif), Q=8 (Zero)...");
        
        // Pilotage direct des entrees ADC du Testbench (A adapter selon les noms de tes signaux TB)
        tb_i = 4'd15; // Valeur max
        tb_q = 4'd8;  // Valeur neutre (DC offset)
        
        // On laisse le filtre FIR se remplir (il a 5 etages de delai)
        repeat(10) @(posedge i_clk);

        // 3. Capture des sorties Baseband
        res_i = o_bus_out[5:0];
        res_q = o_bus_out[11:6];

        $display("  [NORMAL] Sortie Baseband I: %d", res_i);
        $display("  [NORMAL] Sortie Baseband Q: %d", res_q);

        // Verification basique : Si on met un I fort, la sortie I doit reagir et Q doit rester faible
        if (res_i != 0)
            $display("  [NORMAL] PASS : La chaine I reagit aux donnees ADC !");
        else
            $error("  [NORMAL] FAIL : La chaine I est muette !");

        // 4. Inversion pour verifier Q
        $display("  [NORMAL] Injection ADC : I=8 (Zero), Q=0 (Max Negatif)...");
        tb_i = 4'd8; 
        tb_q = 4'd0; 

        repeat(10) @(posedge i_clk);

        res_i = o_bus_out[5:0];
        res_q = o_bus_out[11:6];

        $display("  [NORMAL] Sortie Baseband I: %d", res_i);
        $display("  [NORMAL] Sortie Baseband Q: %d", res_q);

        if (res_q != 0)
            $display("  [NORMAL] PASS : La chaine Q reagit aux donnees ADC !");
        else
            $error("  [NORMAL] FAIL : La chaine Q est muette !");

        $display("========== NORMAL MODE COMPLETE ==========\n");
    end
endtask