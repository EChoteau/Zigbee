module cdr_wrapper #(
    parameter int CFG_WIDTH  = 3,
    parameter int BUS_IN_WIDTH  = 22,
    parameter int BUS_OUT_WIDTH = 14
)(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic [CFG_WIDTH-1:0] i_cfg,
    input  logic i_out_en,

    input  logic [BUS_IN_WIDTH-1:0]  i_bus_in,
    output logic [BUS_OUT_WIDTH-1:0] o_bus_out
);

    localparam logic [CFG_WIDTH-1:0] CFG0 = 'd0;
    localparam logic [CFG_WIDTH-1:0] CFG1 = 'd1;
    localparam logic [CFG_WIDTH-1:0] CFG2 = 'd2;
    localparam logic [CFG_WIDTH-1:0] CFG3 = 'd3;
    localparam logic [CFG_WIDTH-1:0] CFG4 = 'd4;

    // Largeur du bus de contrôle NCO / loop_filter
    localparam int CTRL_WIDTH = 4;
    localparam int D_PHI_W = 8;

    // ====================================================================
    // Input bus decoding (22 bits)
    // IN[7:0]    = i_dphi[7:0]
    // IN[10]     = s_pd_sample_clk, s_lf_ctrl_ack
    // IN[11]     = s_pd_decision_in, s_lf_down
    // IN[12]     = s_lf_up
    // IN[13:10]  = s_nco_ctrl[3:0]
    // ====================================================================
    logic [D_PHI_W-1:0]           w_dphi;
    logic                         w_pd_sample_clk;
    logic                         w_pd_decision_in;
    logic                         w_lf_up;
    logic                         w_lf_down;
    logic                         w_lf_ctrl_ack;
    logic signed [CTRL_WIDTH-1:0] w_nco_ctrl;

    assign w_dphi           = i_bus_in[7:0];
    assign w_pd_sample_clk  = i_bus_in[10];
    assign w_pd_decision_in = i_bus_in[11];
    assign w_lf_ctrl_ack    = i_bus_in[10];
    assign w_lf_down        = i_bus_in[11];
    assign w_lf_up          = i_bus_in[12];
    assign w_nco_ctrl       = signed'(i_bus_in[13:10]);
    // -----------------------------------------------------------------------
    // Signaux internes des sous-blocs
    // -----------------------------------------------------------------------

    // decision_block
    logic                           s_decision_sig;   // sortie du décodeur
    logic                           s_decision_out;   // registré sur recovered_clk

    // phase_detector
    logic                           s_pd_decision_in_internal;
    logic                           s_pd_sample_clk_internal;
    logic                           s_up;
    logic                           s_down;

    // loop_filter
    logic                           s_lf_up_internal;
    logic                           s_lf_down_internal;
    logic                           s_lf_ctrl_ack_internal;
    logic signed [CTRL_WIDTH-1:0]   s_control;

    // NCO
    logic signed [CTRL_WIDTH-1:0]   s_nco_ctrl_internal;
    logic                           s_recovered_clk;
    logic                           s_sample_enable;
    logic                           s_ack;

    // -----------------------------------------------------------------------
    // Mux des entrées des sous-blocs selon la configuration
    // -----------------------------------------------------------------------
    logic s_phase_detector_debug, s_loop_filter_debug,s_nco_debug;
    always_comb begin

        // --- phase_detector ---
        // CFG2 : on injecte les stimuli de test directement
        s_pd_decision_in_internal = w_pd_decision_in;
        s_pd_sample_clk_internal  = w_pd_sample_clk;
        if (i_cfg == CFG2) begin
            s_phase_detector_debug = 1'b1;
        end else begin
            // Chemin normal : sortie du décodeur + horloge récupérée du NCO
            s_phase_detector_debug = 1'b0;
        end

        // --- loop_filter ---
        // CFG3 : on injecte les stimuli de test directement
        s_lf_up_internal       = w_lf_up;
        s_lf_down_internal     = w_lf_down;
        s_lf_ctrl_ack_internal = w_lf_ctrl_ack;
        if (i_cfg == CFG3) begin
            s_loop_filter_debug = 1'b1;
        end else begin
            // Chemin normal : sorties du phase_detector + ack du NCO
            s_loop_filter_debug = 1'b0;
        end

        // --- NCO ---
        // CFG4 : on injecte la commande de contrôle directement
        s_nco_ctrl_internal = w_nco_ctrl;
        if (i_cfg == CFG4)
        begin
            s_nco_debug = 1'b1;
        end
        else
        begin
            s_nco_debug = 1'b0;
        end

    end

    // -----------------------------------------------------------------------
    // Instanciation des sous-blocs
    // -----------------------------------------------------------------------
// definition des sortie des block 
wire [CTRL_WIDTH-1:0] s_ctrl;
logic s_data;

CDR_top#(
        .phase_resolution(D_PHI_W),
        .ctrl_width(CTRL_WIDTH)
        ) 
u_CDR(  
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_dphi(w_dphi),
        .o_data(s_data),
        .o_enable(s_sample_enable),
        .i_phase_detector_debug(s_phase_detector_debug),
        .i_loop_filter_debug(s_loop_filter_debug),
        .i_nco_debug(s_nco_debug),
        .i_recovered_clk_d(s_pd_sample_clk_internal),
        .i_decision_d(s_pd_decision_in_internal),
        .i_up_d(s_lf_up_internal),
        .i_down_d(s_lf_down_internal),
        .i_ack_d(s_lf_ctrl_ack_internal),
        .i_control_d(s_nco_ctrl_internal),
        .o_decision(s_decision_sig),
        .o_up(s_up),
        .o_down(s_down),
        .o_ack(s_ack),
        .o_ctrl(s_control),
        .o_recovered_clk(s_recovered_clk)
 );

    // -----------------------------------------------------------------------
    // Decision output register (latched on recovered clock)
    // -----------------------------------------------------------------------
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n)
            s_decision_out <= 1'b0;
        else if (s_recovered_clk)
            s_decision_out <= s_decision_sig;
    end

    // -----------------------------------------------------------------------
    // Mux de sortie (14 bits)
    // ====================================================================
    // OUT[1]     = o_data (mode 0)
    // OUT[0]     = o_enable (mode 0)
    // OUT[0]     = s_decision_sig (mode 1)
    // OUT[1]     = s_up (mode 2)
    // OUT[0]     = s_down (mode 2)
    // OUT[3:0]   = s_control[3:0] (mode 3)
    // OUT[2]     = s_decision_out (mode 4)
    // OUT[1]     = o_enable (mode 4)
    // OUT[0]     = s_ack (mode 4)
    // ====================================================================
    always_comb begin
        o_bus_out = '0;  // Default: all zeros

        if (i_out_en) begin
            unique case (i_cfg)

                CFG0: // Mode normal CDR : data + enable
                    o_bus_out[1:0] = {s_data, s_sample_enable};

                CFG1: // Debug décodeur : décision combinatoire
                    o_bus_out[0] = s_decision_sig;

                CFG2: // Test phase_detector isolé : up / down
                    o_bus_out[1:0] = {s_up, s_down};

                CFG3: // Test loop_filter isolé : bus de contrôle
                    o_bus_out[CTRL_WIDTH-1:0] = s_control;

                CFG4: // Test NCO isolé : decision_out + enable + ack
                    o_bus_out[2:0] = {s_decision_out, s_sample_enable, s_ack};

                default:
                    o_bus_out = '0;

            endcase
        end
        // When i_out_en = 0, o_bus_out stays 0 (tri-state)
    end

endmodule
