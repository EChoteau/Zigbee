module zigbee_top #(
    parameter int BUS_IN_WIDTH  = 22,
    parameter int BUS_OUT_WIDTH = 14
)(
    input  logic i_clk,
    input  logic i_rst_n,
    
    // Config globale du TOP (sélectionne la chaîne ou le composant isolé)
    input  logic [2:0] i_cfg_top,
    
    // Config locale passée au bloc testé en mode isolé
    input  logic [2:0] i_cfg,
    
    input  logic [BUS_IN_WIDTH-1:0]  i_bus_in,
    output logic [BUS_OUT_WIDTH-1:0] o_bus_out
);

    // ====================================================================
    // MODES DE CONFIGURATION DU TOP LEVEL
    // ====================================================================
    localparam logic [2:0] CFG_RX_PATH       = 3'b000; // Chaîne RX complète
    localparam logic [2:0] CFG_TX_PATH       = 3'b001; // Chaîne TX complète
    localparam logic [2:0] CFG_MOD_CORDIC    = 3'b010; // Sous-chaîne MSK -> Cordic -> CDR
    localparam logic [2:0] CFG_INTERFACE     = 3'b011; // Isoler Interface
    localparam logic [2:0] CFG_MODULATION    = 3'b100; // Isoler MSK
    localparam logic [2:0] CFG_DEMODULATION  = 3'b101; // Isoler Demod
    localparam logic [2:0] CFG_CORDIC        = 3'b110; // Isoler Cordic
    localparam logic [2:0] CFG_CDR           = 3'b111; // Isoler CDR

    // ====================================================================
    // BUS INTERNES (Sorties des Wrappers)
    // ====================================================================
    logic [BUS_OUT_WIDTH-1:0] w_interface_out;
    logic [BUS_OUT_WIDTH-1:0] w_demod_out;
    logic [BUS_OUT_WIDTH-1:0] w_msk_out;
    logic [BUS_OUT_WIDTH-1:0] w_cordic_out;
    logic [BUS_OUT_WIDTH-1:0] w_cdr_out;

    // ====================================================================
    // BUS INTERNES (Entrées des Wrappers)
    // ====================================================================
    logic [BUS_IN_WIDTH-1:0] w_interface_input;
    logic [BUS_IN_WIDTH-1:0] w_demod_input;
    logic [BUS_IN_WIDTH-1:0] w_msk_input;
    logic [BUS_IN_WIDTH-1:0] w_cordic_input;
    logic [BUS_IN_WIDTH-1:0] w_cdr_input;

    // ====================================================================
    // SIGNAUX DE CONTROLE DES WRAPPERS
    // ====================================================================
    logic [2:0] w_interface_cfg, w_demod_cfg, w_msk_cfg, w_cordic_cfg, w_cdr_cfg;
    logic       w_interface_out_en, w_demod_out_en, w_msk_out_en, w_cordic_out_en, w_cdr_out_en;

    // ====================================================================
    // 1. GESTION DES MODES ET DES ENABLE
    // ====================================================================
    always_comb begin
        // Par défaut: Tout le monde est en mode 0 (Normal) et silencieux (out_en = 0)
        w_interface_cfg = 3'b000; w_demod_cfg  = 3'b000; w_msk_cfg    = 3'b000;
        w_cordic_cfg    = 3'b000; w_cdr_cfg    = 3'b000;
        
        w_interface_out_en = 1'b0; w_demod_out_en  = 1'b0; w_msk_out_en    = 1'b0;
        w_cordic_out_en    = 1'b0; w_cdr_out_en    = 1'b0;

        unique case (i_cfg_top)
            CFG_RX_PATH: begin
                w_interface_out_en = 1'b1; w_demod_out_en  = 1'b1;
                w_cordic_out_en    = 1'b1; w_cdr_out_en    = 1'b1;
            end
            CFG_TX_PATH: begin
                w_interface_out_en = 1'b1; w_msk_out_en    = 1'b1;
            end
            CFG_MOD_CORDIC: begin
                w_msk_out_en       = 1'b1; w_cordic_out_en = 1'b1; w_cdr_out_en = 1'b1;
            end
            // Modes isolés: On passe la config utilisateur (i_cfg) uniquement au bloc ciblé
            CFG_INTERFACE:    begin w_interface_cfg = i_cfg; w_interface_out_en = 1'b1; end
            CFG_MODULATION:   begin w_msk_cfg       = i_cfg; w_msk_out_en       = 1'b1; end
            CFG_DEMODULATION: begin w_demod_cfg     = i_cfg; w_demod_out_en     = 1'b1; end
            CFG_CORDIC:       begin w_cordic_cfg    = i_cfg; w_cordic_out_en    = 1'b1; end
            CFG_CDR:          begin w_cdr_cfg       = i_cfg; w_cdr_out_en       = 1'b1; end
            default: ;
        endcase
    end

    // ====================================================================
    // 2. ROUTAGE DES ENTRÉES
    // ====================================================================
    always_comb begin
        w_interface_input = i_bus_in;
        w_demod_input     = i_bus_in;
        w_msk_input       = i_bus_in;
        w_cordic_input    = i_bus_in;
        w_cdr_input       = i_bus_in;

        // Écrasement chirurgical des bits pour les chaînes de traitement
        unique case (i_cfg_top)
            
            CFG_RX_PATH: begin
                // Demodulation : Écoute l'ADC simulé via i_bus_in (Rien à changer)
                
                // Cordic : Écoute Demod
                // Demod sort I sur [5:0] et Q sur [11:6]. Cordic veut I sur [5:0] et Q sur [11:6].
                w_cordic_input[11:0]  = w_demod_out[11:0]; 
                
                // CDR : Écoute la phase du Cordic
                w_cdr_input[7:0]      = w_cordic_out[7:0];
                
                // Interface : Récéption série branchée sur le CDR
                w_interface_input[19] = w_cdr_out[1]; // o_data du CDR
                w_interface_input[20] = w_cdr_out[0]; // o_enable du CDR
            end

            CFG_TX_PATH: begin
                // MSK : Écoute les sorties série de l'interface
                w_msk_input[2] = w_interface_out[12]; // serial_tx -> b_in
                w_msk_input[1] = w_interface_out[13]; // tx_valid -> enable_ech
                w_msk_input[0] = 1'b1;                // flag_enable toujours à 1
            end

            CFG_MOD_CORDIC: begin
                // Cordic : Écoute MSK
                // MSK sort I sur [11:6] et Q sur [5:0]. Cordic veut I sur [5:0] et Q sur [11:6] => CROISEMENT
                w_cordic_input[5:0]  = w_msk_out[11:6]; 
                w_cordic_input[11:6] = w_msk_out[5:0];
                
                // CDR : Écoute le Cordic
                w_cdr_input[7:0]     = w_cordic_out[7:0];
            end
            
            default: ; // Modes isolés : le Fan-out i_bus_in suffit.
        endcase
    end

    // ====================================================================
    // 3. INSTANCIATIONS DES WRAPPERS
    // ====================================================================
    
    interface_wrapper #(.BUS_IN_WIDTH(BUS_IN_WIDTH), .BUS_OUT_WIDTH(BUS_OUT_WIDTH)) interface_inst (
        .i_clk(i_clk), .i_rst_n(i_rst_n), .i_cfg(w_interface_cfg), .i_out_en(w_interface_out_en),
        .i_bus_in(w_interface_input), .o_bus_out(w_interface_out)
    );

    demod_wrapper #(.BUS_IN_WIDTH(BUS_IN_WIDTH), .BUS_OUT_WIDTH(BUS_OUT_WIDTH)) demod_inst (
        .i_clk(i_clk), .i_rst_n(i_rst_n), .i_cfg(w_demod_cfg), .i_out_en(w_demod_out_en),
        .i_bus_in(w_demod_input), .o_bus_out(w_demod_out)
    );

    msk_wrapper #(.BUS_IN_WIDTH(BUS_IN_WIDTH), .BUS_OUT_WIDTH(BUS_OUT_WIDTH)) msk_inst (
        .i_clk(i_clk), .i_rst_n(i_rst_n), .i_cfg(w_msk_cfg), .i_out_en(w_msk_out_en),
        .i_bus_in(w_msk_input), .o_bus_out(w_msk_out)
    );

    cordic_system_wrapper #(.BUS_IN_WIDTH(BUS_IN_WIDTH), .BUS_OUT_WIDTH(BUS_OUT_WIDTH)) cordic_inst (
        .i_clk(i_clk), .i_rst_n(i_rst_n), .i_cfg(w_cordic_cfg), .i_out_en(w_cordic_out_en),
        .i_bus_in(w_cordic_input), .o_bus_out(w_cordic_out)
    );

    cdr_wrapper #(.BUS_IN_WIDTH(BUS_IN_WIDTH), .BUS_OUT_WIDTH(BUS_OUT_WIDTH)) cdr_inst (
        .i_clk(i_clk), .i_rst_n(i_rst_n), .i_cfg(w_cdr_cfg), .i_out_en(w_cdr_out_en),
        .i_bus_in(w_cdr_input), .o_bus_out(w_cdr_out)
    );

    // ====================================================================
    // 4. ROUTAGE DE LA SORTIE GLOBALE (MUX DE SORTIE)
    // ====================================================================
    always_comb begin
        o_bus_out = '0;

        unique case (i_cfg_top)
            // Chaînes complètes
            CFG_RX_PATH:      o_bus_out = w_interface_out; 
            CFG_TX_PATH: begin
                o_bus_out[11:0]  = w_msk_out[11:0];       // Signal modulé
                o_bus_out[13:12] = w_interface_out[13:12]; // tx_valid & serial_tx
            end
            CFG_MOD_CORDIC:   o_bus_out = w_cdr_out;
            
            // Modes isolés (seul le bloc ciblé a son out_en actif, les autres crachent 0)
            // On pourrait faire un OR global, mais un case est plus strict pour la synthèse
            CFG_INTERFACE:    o_bus_out = w_interface_out;
            CFG_MODULATION:   o_bus_out = w_msk_out;
            CFG_DEMODULATION: o_bus_out = w_demod_out;
            CFG_CORDIC:       o_bus_out = w_cordic_out;
            CFG_CDR:          o_bus_out = w_cdr_out;
        endcase
    end

endmodule