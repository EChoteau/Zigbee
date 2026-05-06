        
// ==============================================================================
// Module      : shaping_msk
// Description : Mise en forme Half-Sine 100% Configurable et Automatisée
//               Calcule sa propre ROM et ses timings selon les paramètres.
// ==============================================================================

module shaping_msk #(
    parameter int SAMPLES_PER_HALF_SINE = 10, // Nb points pour 1µs (bosse)
    parameter int MSK_RES               = 6  // Résolution (ex: 6 bits signés)
   // parameter real PI = 3.14159265358979323846
)(
    input  logic                 i_clk,
    input  logic                 i_rst_n,
    input  logic                 i_enable_ech, // Pulse à la fréquence d'échantillonnage
    input  logic                 i_a_I,        // Symbole voie I (-1/+1)
    input  logic                 i_a_Q,        // Symbole voie Q (-1/+1)
    output logic signed [MSK_RES-1:0] o_I_BB,
    output logic signed [MSK_RES-1:0] o_Q_BB
);

    // --------------------------------------------------------------------------
    // 1. CALCULS AUTOMATIQUES DES CONSTANTES (COMPILE-TIME)
    // --------------------------------------------------------------------------
    localparam int TOTAL_POINTS = SAMPLES_PER_HALF_SINE * 2; // Cycle complet (2µs)
    localparam int TB_POINTS    = SAMPLES_PER_HALF_SINE / 2; // Décalage Tb (0.5µs)
    localparam int QUARTER_SINE = SAMPLES_PER_HALF_SINE / 2; // Montée (0.5µs)
    localparam int ADDR_W       = $clog2(TOTAL_POINTS);      // Taille compteur
    localparam int MAX_VAL      = (1 << (MSK_RES-1)) - 1;    // Amplitude max (ex: 31)

    // --------------------------------------------------------------------------
    // 2. GÉNÉRATION DE LA ROM (AUTOMATISÉE)
    // --------------------------------------------------------------------------
    logic signed [MSK_RES-1:0] rom_quarter [0:QUARTER_SINE-1];
    always_comb begin 
	rom_quarter[0] = 6'sd0;
	rom_quarter[1] = 6'sd10;
	rom_quarter[2] = 6'sd18;
	rom_quarter[3] = 6'sd25;
	rom_quarter[4] = 6'sd29;
    end 
    //initial begin
    //   for (int i = 0; i < QUARTER_SINE; i++) begin
            // Calcul du sinus casté en entier : sin(i * pi/2 / Nb_points_montée) * Amplitude
    //        rom_quarter[i] = $rtoi($sin((real'(i) * (PI/2.0)) / real'(QUARTER_SINE)) * real'(MAX_VAL));
    //    end
    //end

    // --------------------------------------------------------------------------
    // 3. SIGNAUX INTERNES
    // --------------------------------------------------------------------------
    logic [ADDR_W-1:0] s_phase;     // Compteur de phase global
    logic [ADDR_W-1:0] w_phase_I;   // Phase décalée pour la voie I
    logic              s_bit_I;     // Signe mémorisé voie I
    logic              s_bit_Q;     // Signe mémorisé voie Q

    // --------------------------------------------------------------------------
    // 4. COMPTEUR ET CAPTURE DES SIGNES
    // --------------------------------------------------------------------------
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            s_phase <= '0;
            s_bit_I <= 1'b0;
            s_bit_Q <= 1'b0;
        end else if (i_enable_ech) begin
            // Incrémentation du compteur de phase
            if (s_phase == (TOTAL_POINTS - 1)) 
                s_phase <= '0;
            else 
                s_phase <= s_phase + 1'b1;

            // Capture Q au début de sa bosse (0 µs)
            if (s_phase == 0) 
                s_bit_Q <= i_a_Q;
            
            // Capture I au début de sa bosse (0.5 µs)
            if (s_phase == TB_POINTS) 
                s_bit_I <= i_a_I;
        end
    end

    // --------------------------------------------------------------------------
    // 5. LOGIQUE DE DÉPHASAGE ET LECTURE ROM (MIROIR)
    // --------------------------------------------------------------------------
    
    // Décalage Tb pour la voie I
    assign w_phase_I = (s_phase < TB_POINTS) ? 
                       (s_phase + (TOTAL_POINTS - TB_POINTS)) : 
                       (s_phase - TB_POINTS);

    // Fonction pour lire la bosse complète à partir du quart de sinus
    function automatic logic signed [MSK_RES-1:0] get_shaping_val(logic [ADDR_W-1:0] p_global);
        logic [ADDR_W-1:0] idx_local;
        logic [ADDR_W-1:0] addr;

        // On ramène la phase globale dans l'intervalle d'une bosse [0, SAMPLES_PER_HALF_SINE-1]
        idx_local = (p_global < SAMPLES_PER_HALF_SINE) ? p_global : (p_global - SAMPLES_PER_HALF_SINE);

        if (idx_local < QUARTER_SINE) begin
            // Phase montante
            return rom_quarter[idx_local];
        end else begin
            // Phase descendante (symétrie miroir)
            addr = (SAMPLES_PER_HALF_SINE - 1) - idx_local;
            return rom_quarter[addr];
        end
    endfunction

    // --------------------------------------------------------------------------
    // 6. SORTIES AVEC APPLICATION DU SIGNE
    // --------------------------------------------------------------------------
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_I_BB <= '0;
            o_Q_BB <= '0;
        end else if (i_enable_ech) begin
            // Sortie I = (Signe I) * Valeur ROM déphasée
            o_I_BB <= (s_bit_I) ? get_shaping_val(w_phase_I) : -get_shaping_val(w_phase_I);
            
            // Sortie Q = (Signe Q) * Valeur ROM
            o_Q_BB <= (s_bit_Q) ? get_shaping_val(s_phase) : -get_shaping_val(s_phase);
        end
    end

endmodule
