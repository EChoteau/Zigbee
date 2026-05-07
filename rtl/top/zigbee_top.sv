// ============================================================================
// Module      : zigbee_top
// Description : Top-level integration wrapper for Zigbee receiver.
//               Unified bus interface (22-bit IN, 14-bit OUT).
//               Supports 8 test configurations for complete system validation.
//               Instantiates all processing blocks:
//                 - Interface (serializer, deserializer, FIFO, baud generator)
//                 - Demodulation (IQ demod + FIR filters)
//                 - MSK Modulation (encoder, demultiplexer, shaping)
//                 - CORDIC (phase detection + derivative + filter)
//                 - CDR (clock/data recovery with PLL)
// ============================================================================

module zigbee_top #(
    parameter int BUS_IN_WIDTH  = 22,
    parameter int BUS_OUT_WIDTH = 14
)(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic [2:0] i_cfg_top,
    input  logic [2:0] i_cfg,
    input  logic i_out_en,
    
    input  logic [BUS_IN_WIDTH-1:0]  i_bus_in,
    output logic [BUS_OUT_WIDTH-1:0] o_bus_out
);

    // ====================================================================
    // CONFIGURATION MAPPING TABLE - Signal Chain & I/O Routing
    // ====================================================================
    // Mode  Config         Input Source   Input Width   Active Chain           Output Observed  Output Width
    // ----  ------         -----          -----------   ------------------     ----------------  -----------
    // 000   RX_PATH        i_bus_in       22 bits       Interface→Demod        w_demod_out       14 bits
    //                                                   Deserialize→FIFO→APB→IQ-Demod→FIR
    //
    // 001   TX_PATH        i_bus_in       22 bits       Intf→MSK→Cordic→CDR    w_cdr_out         14 bits
    //                                                   APB→FIFO→Serial→Baud→MSK→PhaseD→CDR
    //
    // 010   MOD_CORDIC     i_bus_in       22 bits       MSK→Cordic→CDR         w_cdr_out         14 bits
    //                                                   MSK-Encoder→Demux→Shaping→PhaseD→CDR
    //
    // 011   INTERFACE      i_bus_in       22 bits       Interface (isolated)   w_interface_out   14 bits
    //                                                   Serial/Deserial/FIFO/Baud only
    //
    // 100   MODULATION     i_bus_in       22 bits       MSK (isolated)         w_msk_out         14 bits
    //                                                   Encoder→Demux→Shaping only
    //
    // 101   DEMODULATION   i_bus_in       22 bits       Demod (isolated)       w_demod_out       14 bits
    //                                                   IQ-Demod→FIR-I→FIR-Q only
    //
    // 110   CORDIC         i_bus_in       22 bits       Cordic (isolated)      w_cordic_out      14 bits
    //                                                   Phase-Detect→Derivative→Boxcar only
    //
    // 111   CDR            i_bus_in       22 bits       CDR (isolated)         w_cdr_out         14 bits
    //                                                   Phase-Detector→Loop-Filter→NCO only
    //
    // ====================================================================
    // KEY BIT-WIDTH CONVERSIONS:
    // - 14-bit outputs padded to 22-bit inputs: {{8{1'b0}}, w_*_out[13:0]}
    // - All intermediate signals use 22-bit interconnect for consistency
    // - Final output mux selects 14-bit wrapper output (o_bus_out)
    // ====================================================================

    // ====================================================================
    // Configuration modes (8 modes total)
    // ====================================================================
    localparam logic [2:0] CFG_RX_PATH       = 3'b000;  // RX chain testing (receive path)
    localparam logic [2:0] CFG_TX_PATH       = 3'b001;  // TX chain testing (transmit path)
    localparam logic [2:0] CFG_MOD_CORDIC    = 3'b010;  // Modulation + Cordic + CDR integrated
    localparam logic [2:0] CFG_INTERFACE     = 3'b011;  // Interface block isolation
    localparam logic [2:0] CFG_MODULATION    = 3'b100;  // MSK modulation isolation
    localparam logic [2:0] CFG_DEMODULATION  = 3'b101;  // IQ demodulation isolation
    localparam logic [2:0] CFG_CORDIC        = 3'b110;  // CORDIC processing isolation
    localparam logic [2:0] CFG_CDR           = 3'b111;  // Clock Data Recovery isolation

    // ====================================================================
    // Wrapper output buses (all 14-bit)
    // ====================================================================
    logic [BUS_OUT_WIDTH-1:0] w_interface_out;
    logic [BUS_OUT_WIDTH-1:0] w_demod_out;
    logic [BUS_OUT_WIDTH-1:0] w_msk_out;
    logic [BUS_OUT_WIDTH-1:0] w_cordic_out;
    logic [BUS_OUT_WIDTH-1:0] w_cdr_out;

    // ====================================================================
    // Internal interconnection buses (adapted between wrapper outputs and inputs)
    // Each wrapper can receive either external input or output from previous stage
    // ====================================================================
    logic [BUS_IN_WIDTH-1:0] w_interface_input;   // Input to interface wrapper
    logic [BUS_IN_WIDTH-1:0] w_demod_input;       // Input to demod wrapper (from interface or external)
    logic [BUS_IN_WIDTH-1:0] w_msk_input;         // Input to msk wrapper
    logic [BUS_IN_WIDTH-1:0] w_cordic_input;      // Input to cordic wrapper (from demod or external)
    logic [BUS_IN_WIDTH-1:0] w_cdr_input;         // Input to cdr wrapper (from cordic or external)

    // ====================================================================
    // CONFIGURATION MAPPING FOR EACH WRAPPER
    // Maps top-level i_cfg to block-specific modes (critical to avoid mode conflicts!)
    // ====================================================================
    logic [2:0] w_interface_cfg;  // Interface block config (forced 3'b000 in chains, i_cfg in isolation)
    logic [2:0] w_demod_cfg;      // Demod block config (forced 3'b000 in chains, i_cfg in isolation)
    logic [2:0] w_msk_cfg;        // MSK block config (forced 3'b000 in chains, i_cfg in isolation)
    logic [2:0] w_cordic_cfg;     // Cordic block config (forced 3'b000 in chains, i_cfg in isolation)
    logic [2:0] w_cdr_cfg;        // CDR block config (forced 3'b000 in chains, i_cfg in isolation)

    // ====================================================================
    // CONFIGURATION MAPPING LOGIC
    // Maps top-level i_cfg to block-specific modes to avoid mode conflicts
    // In chain modes: force blocks to 3'b000 (normal/safe operation)
    // In isolation modes: pass i_cfg to the tested block, force others to 3'b000
    // ====================================================================
    always_comb begin
        // Default: All blocks in mode 3'b000 (safe/normal operation)
        w_interface_cfg = 3'b000;
        w_demod_cfg     = 3'b000;
        w_msk_cfg       = 3'b000;
        w_cordic_cfg    = 3'b000;
        w_cdr_cfg       = 3'b000;

        unique case (i_cfg_top)
            CFG_RX_PATH: begin
                // RX Chain: Demod → Cordic → CDR → Interface
                // All blocks forced to mode 3'b000 (normal operation in chain)
                // No special cfg mapping needed, all stay at 3'b000
            end

            CFG_TX_PATH: begin
                // TX Chain: Interface → MSK
                // All blocks forced to mode 3'b000 (normal operation in chain)
                // No special cfg mapping needed, all stay at 3'b000
            end

            CFG_MOD_CORDIC: begin
                // MOD+CORDIC+CDR Chain: MSK → Cordic → CDR
                // All blocks forced to mode 3'b000 (normal operation in chain)
                // No special cfg mapping needed, all stay at 3'b000
            end

            CFG_INTERFACE: begin
                // Interface block isolation: test interface independently
                w_interface_cfg = i_cfg;  // Pass i_cfg to Interface (mode 3'b011 = isolated test)
                // All other blocks stay at 3'b000 (disabled)
            end

            CFG_MODULATION: begin
                // MSK block isolation: test MSK independently
                w_msk_cfg = i_cfg;  // Pass i_cfg to MSK (mode 3'b100 = isolated test)
                // All other blocks stay at 3'b000 (disabled)
            end

            CFG_DEMODULATION: begin
                // Demod block isolation: test Demod independently
                w_demod_cfg = i_cfg;  // Pass i_cfg to Demod (mode 3'b101 = isolated test)
                // All other blocks stay at 3'b000 (disabled)
            end

            CFG_CORDIC: begin
                // Cordic block isolation: test Cordic independently
                w_cordic_cfg = i_cfg;  // Pass i_cfg to Cordic (mode 3'b110 = isolated test)
                // All other blocks stay at 3'b000 (disabled)
            end

            CFG_CDR: begin
                // CDR block isolation: test CDR independently
                w_cdr_cfg = i_cfg;  // Pass i_cfg to CDR (mode 3'b111 = isolated test)
                // All other blocks stay at 3'b000 (disabled)
            end

            default: begin
                // Safe state: all blocks at 3'b000
            end
        endcase
    end

    // ====================================================================
    always_comb begin
        // 1. Fan-out par défaut : Tout le monde écoute le bus externe i_bus_in[21:0]
        w_interface_input = i_bus_in;
        w_demod_input     = i_bus_in;
        w_msk_input       = i_bus_in;
        w_cordic_input    = i_bus_in;
        w_cdr_input       = i_bus_in;

        // 2. Écrasement chirurgical des bits de données pour les modes chaînés
        unique case (i_cfg_top)
            
            CFG_RX_PATH: begin
                // Demod : Reçoit l'ADC (pins i_i, i_q externes dédiées)
                
                // Cordic : Écoute le Demod (ATTENTION : Inversion I/Q réparée !)
                w_cordic_input[5:0]  = w_demod_out[11:6]; // I sort sur 11:6, entre sur 5:0
                w_cordic_input[11:6] = w_demod_out[5:0];  // Q sort sur 5:0, entre sur 11:6
                
                // CDR : Écoute la phase du Cordic
                w_cdr_input[7:0]     = w_cordic_out[7:0]; 
                
                // Interface : Conserve l'APB sur i_bus_in, mais remplace la réception série par le CDR
                w_interface_input[19] = w_cdr_out[1]; // bit 1 = o_data du CDR
                w_interface_input[20] = w_cdr_out[0]; // bit 0 = o_enable du CDR
            end

            CFG_TX_PATH: begin
                // Interface : Écoute l'extérieur (APB, FIFO data)
                
                // MSK : Écoute les sorties série de l'interface, garde l'extérieur pour s_flag_enable
                w_msk_input[2] = w_interface_out[12]; // bit 12 = serial_tx -> s_b_in
                w_msk_input[1] = w_interface_out[13]; // bit 13 = tx_valid -> s_enable_ech
                w_msk_input[0] = 1'b1;                // Toujours activé
            end

            CFG_MOD_CORDIC: begin
                // MSK : Écoute l'extérieur (i_bus_in)
                
                // Cordic : Écoute MSK (Inversion I/Q réparée)
                w_cordic_input[5:0]  = w_msk_out[11:6]; 
                w_cordic_input[11:6] = w_msk_out[5:0];  
                
                // CDR : Écoute le Cordic
                w_cdr_input[7:0]     = w_cordic_out[7:0];
            end
            
            // Pour tous les autres modes isolés (3 à 7), le Fan-out par défaut suffit !
            default: ; 
        endcase
    end
    // ====================================================================

    // --- Interface Wrapper (for CFG 0, 1, 3) ---
    // Purpose: Test serializer, deserializer, FIFOs, baud generator
    interface_wrapper #(
        .BUS_IN_WIDTH(BUS_IN_WIDTH),
        .BUS_OUT_WIDTH(BUS_OUT_WIDTH)
    ) interface_wrapper_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(w_interface_cfg),
        .i_out_en(i_out_en),
        .i_bus_in(w_interface_input),
        .o_bus_out(w_interface_out)
    );

    // --- Demodulation Wrapper (for CFG 5, and chain mode 0) ---
    // Purpose: Test IQ demodulation and FIR filtering chains
    demod_wrapper #(
        .BUS_IN_WIDTH(BUS_IN_WIDTH),
        .BUS_OUT_WIDTH(BUS_OUT_WIDTH)
    ) demod_wrapper_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(w_demod_cfg),
        .i_out_en(i_out_en),
        .i_bus_in(w_demod_input),
        .o_bus_out(w_demod_out)
    );

    // --- MSK Modulation Wrapper (for CFG 4, and chain mode 1) ---
    // Purpose: Test MSK encoder, demultiplexer, shaping filter
    msk_wrapper #(
        .BUS_IN_WIDTH(BUS_IN_WIDTH),
        .BUS_OUT_WIDTH(BUS_OUT_WIDTH)
    ) msk_wrapper_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(w_msk_cfg),
        .i_out_en(i_out_en),
        .i_bus_in(w_msk_input),
        .o_bus_out(w_msk_out)
    );

    // --- CORDIC Wrapper (for CFG 6, and chain modes 1 & 2) ---
    // Purpose: Test CORDIC phase detector, derivative filter, boxcar filter
    cordic_wrapper #(
        .BUS_IN_WIDTH(BUS_IN_WIDTH),
        .BUS_OUT_WIDTH(BUS_OUT_WIDTH)
    ) cordic_wrapper_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(w_cordic_cfg),
        .i_out_en(i_out_en),
        .i_bus_in(w_cordic_input),
        .o_bus_out(w_cordic_out)
    );

    // --- CDR Wrapper (for CFG 7, and chain modes 1 & 2) ---
    // Purpose: Test clock/data recovery with phase detector, loop filter, NCO
    cdr_wrapper #(
        .BUS_IN_WIDTH(BUS_IN_WIDTH),
        .BUS_OUT_WIDTH(BUS_OUT_WIDTH)
    ) cdr_wrapper_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_cfg(w_cdr_cfg),
        .i_out_en(i_out_en),
        .i_bus_in(w_cdr_input),
        .o_bus_out(w_cdr_out)
    );

    // ====================================================================
    // OUTPUT ROUTING (Les pins de sortie)
    // ====================================================================
    always_comb begin
        o_bus_out = '0; // Sécurité Tri-state

        if (i_out_en) begin
            unique case (i_cfg_top)
                // Chaîne RX : On sort tout ce que l'interface a à nous dire
                CFG_RX_PATH:      o_bus_out = w_interface_out; 
                
                // Chaîne TX : 12 bits pour le signal MSK, 2 bits pour l'état Interface
                CFG_TX_PATH: begin
                    o_bus_out[11:0]  = w_msk_out[11:0];       // Signal modulé (I & Q)
                    o_bus_out[13:12] = w_interface_out[13:12]; // tx_valid & serial_tx
                end
                
                // Chaîne Interne : On regarde le bout de la chaîne (CDR)
                CFG_MOD_CORDIC:   o_bus_out = w_cdr_out;
                
                // Modes isolés : On branche directement le composant testé sur les pins
                CFG_INTERFACE:    o_bus_out = w_interface_out;
                CFG_MODULATION:   o_bus_out = w_msk_out;
                CFG_DEMODULATION: o_bus_out = w_demod_out;
                CFG_CORDIC:       o_bus_out = w_cordic_out;
                CFG_CDR:          o_bus_out = w_cdr_out;
            endcase
        end
    end

endmodule