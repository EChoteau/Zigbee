`timescale 1ns/1ps

module top_msk_tb();

    // Signaux du testbench
    logic s_clk;
    logic s_rst_n;
    logic s_enable_ech;
    logic s_flag_enable;
    logic s_b_enc;
    logic signed [5:0] s_I_BB;
    logic signed [5:0] s_Q_BB;

    // Séquence de bits complexe (pour voir de belles courbes comme sur Matlab)
    logic s_sequence [0:9] = '{1, 0, 1, 1, 0, 0, 1, 0, 1, 1};

    // Branchement du TOP module
    top_msk DUT (
        .i_clk(s_clk),
        .i_rst_n(s_rst_n),
        .i_enable_ech(s_enable_ech),
        .i_flag_enable(s_flag_enable),
        .i_b_enc(s_b_enc),
        .o_I_BB(s_I_BB),
        .o_Q_BB(s_Q_BB)
    );

    // Horloge
    always #10 s_clk = ~s_clk;

    // Scénario
    initial begin
        // 1. Reset
        $display("--- DEBUT DE LA SIMULATION TOP MSK ---");
        s_clk = 0;
        s_rst_n = 0;
        s_enable_ech = 0;
        s_flag_enable = 0;
        s_b_enc = 0;
        
        #25 s_rst_n = 1;
        @(posedge s_clk);

        // 2. Envoi de la séquence de bits
        for (int i = 0; i < 10; i++) begin
            
            // --- A. On envoie UN nouveau bit au démultiplexeur ---
            s_b_enc = s_sequence[i];
            s_flag_enable = 1;
            @(posedge s_clk);
            s_flag_enable = 0; // Le demux a capturé le bit et l'a mis sur I ou Q
            
            // --- B. On laisse le Shaping dessiner l'arche pendant Tb ---
            // Puisqu'une arche entière (2Tb) fait 64 échantillons dans ton code,
            // la durée mathématique d'un seul bit (Tb) est EXACTEMENT de 32 échantillons !
            for (int ech = 0; ech < 32; ech++) begin
                s_enable_ech = 1;
                @(posedge s_clk);
                s_enable_ech = 0;
                
                // On simule une attente de quelques coups d'horloge entre chaque point de la courbe
                repeat(3) @(posedge s_clk);
            end
            
        end // Fin du bit, on boucle pour envoyer le suivant !

        $display("--- SIMULATION TERMINEE ---");
        $stop;
    end

endmodule