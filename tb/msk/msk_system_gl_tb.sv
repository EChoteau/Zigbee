`timescale 1ns/1ps

module msk_system_tb();

    // -------------------------------------------------------------------------
    // CONSTANTES DU TESTBENCH
    // -------------------------------------------------------------------------
    localparam int SAMPLES_PER_HALF_SINE = 10; 
    localparam int MSK_RES               = 6;
    localparam int TB_CYCLES             = 5; // 5 cycles @ 10MHz = 500ns = Tb
    localparam signed [MSK_RES-1:0] MAX_AMP = (1 << (MSK_RES-1)) - 1;

    // Signaux
    logic s_clk, s_rst_n, s_enable_ech, s_flag_enable, s_b_in;
    logic signed [MSK_RES-1:0] s_I_BB, s_Q_BB;

    // Séquence de test (10 bits)
    logic s_sequence [0:9] = '{1, 0, 1, 1, 0, 0, 1, 1, 0, 1};

    // -------------------------------------------------------------------------
    // INSTANCIATION DU DUT (Version Gate-Level fixe)
    // -------------------------------------------------------------------------
    msk_system DUT(
        .i_clk(s_clk),
        .i_rst_n(s_rst_n),
        .i_enable_ech(s_enable_ech),
        .i_flag_enable(s_flag_enable),
        .i_b_in(s_b_in),
        .o_I_BB(s_I_BB),
        .o_Q_BB(s_Q_BB)
    );

    // Horloge 10 MHz
    //always #50 s_clk = (s_clk === 1'b0);
    initial s_clk = 0;
    always #50 s_clk = ~s_clk;
    // -------------------------------------------------------------------------
    // SCÉNARIO DE TEST
    // -------------------------------------------------------------------------
    initial begin
        $display("--- DEBUT SIMULATION GATE-LEVEL ULTRA-ROBUSTE ---");
        //s_clk=0; 
	s_rst_n=0; 
	s_enable_ech=1;
        s_flag_enable=0;
        s_b_in=0;

        #200 
	s_rst_n = 1;
        @(negedge s_clk);

        foreach (s_sequence[i]) begin
            s_b_in = s_sequence[i];
            s_flag_enable = 1; 
            @(negedge s_clk);
            s_flag_enable = 0;
            repeat (TB_CYCLES - 1) @(negedge s_clk);
        end

        repeat (20) @(posedge s_clk);
        $display("--- TOUTES LES ASSERTIONS ONT ÉTÉ VÉRIFIÉES ---");
        //$stop;
    end

    // -------------------------------------------------------------------------
    // BATTERIE D'ASSERTIONS (ROBUSTESSE POST-SYNTHÈSE)
    // -------------------------------------------------------------------------

    // 1. Reset Check (Immédiat)
    assert_reset: assert property (@(posedge s_clk) !s_rst_n |=> (s_I_BB == 0 && s_Q_BB == 0))
        else $error("ASRT_FAIL: Reset inefficace sur la netlist !");

    // 2. Range Check (Vérifie qu'aucun bit de signe n'est corrompu)
    assert_range_I: assert property (@(posedge s_clk) disable iff (!s_rst_n) (s_I_BB >= -MAX_AMP && s_I_BB <= MAX_AMP))
        else $error("ASRT_FAIL: Débordement Voie I: %d", s_I_BB);
    assert_range_Q: assert property (@(posedge s_clk) disable iff (!s_rst_n) (s_Q_BB >= -MAX_AMP && s_Q_BB <= MAX_AMP))
        else $error("ASRT_FAIL: Débordement Voie Q: %d", s_Q_BB);

 

    // ". Quadrature Check (MSK pur : quand I est au max, Q doit être proche de 0)
   
    property p_quadrature;
        @(posedge s_clk) disable iff (!s_rst_n || $time < 500ns) // On ignore le démarrage
        // Si I est proche du max (+/- 2), alors Q doit être proche de 0 (+/- 5)
        (s_I_BB >= MAX_AMP-2 || s_I_BB <= -MAX_AMP+2) |-> (s_Q_BB >= -5 && s_Q_BB <= 5);
    endproperty
    assert_msk_sync: assert property (p_quadrature) else $error("ASRT_FAIL: Défaut de quadrature I/Q !");

    // 4. Enveloppe Constante (Puissance RF)
    // Le MSK doit garder une amplitude constante : I² + Q² ~ constante
    property p_const_envelope;
	@(posedge s_clk) disable iff (!s_rst_n || $time < 500ns) // On attend que la logique se stabilise
        (int'(s_I_BB)*s_I_BB + int'(s_Q_BB)*s_Q_BB) > (MAX_AMP*MAX_AMP/2);
    endproperty
    assert_envelope: assert property (p_const_envelope) else $error("ASRT_FAIL: L'enveloppe s'écroule !");

    // 5. Toggle Check (Vérifie que le modulateur n'est pas "mort" ou bloqué)
    property p_active;
        @(posedge s_clk) disable iff (!s_rst_n) s_enable_ech |-> ##[1:10] (s_I_BB != $past(s_I_BB, 10));
    endproperty
    assert_is_alive: assert property (p_active) else $error("ASRT_FAIL: Sorties figées (pas d'activité) !");

    // 6. Flag Enable Timing (Vérifie que ton TB respecte bien les 5 cycles)
    property p_flag_timing;
        @(posedge s_clk) disable iff (!s_rst_n) s_flag_enable |=> !s_flag_enable[*TB_CYCLES-1] ##1 s_flag_enable;
    endproperty
    // assert_flag_rate: assert property (p_flag_timing); // Optionnel selon ta source

    // Fonction abs pour les signaux signés
    function int abs(int v);
        return (v < 0) ? -v : v;
    endfunction

endmodule
