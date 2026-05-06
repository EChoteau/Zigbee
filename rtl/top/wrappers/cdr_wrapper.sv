module CDR_wrapper #(
    parameter int CFG_WIDTH  = 3,
    parameter int BUS_A_WIDTH = 12,
    parameter int BUS_B_WIDTH = 10,
    parameter int BUS_C_WIDTH = 12,
    parameter int BUS_D_WIDTH = 2
)(
    input  logic                    i_clk,
    input  logic                    i_rst_n,
    input  logic [CFG_WIDTH-1:0] i_cfg,

    input  logic [BUS_A_WIDTH-1:0] i_bus_a,// unused 
    input  logic [BUS_B_WIDTH-1:0] i_bus_b, // MSB used
    output logic [BUS_C_WIDTH-1:0] o_bus_c,  // MSB used
    output logic [BUS_D_WIDTH-1:0] o_bus_d   // unused
);

    localparam logic [CFG_WIDTH-1:0] CFG0 = 'd0;
    localparam logic [CFG_WIDTH-1:0] CFG1 = 'd1;
    localparam logic [CFG_WIDTH-1:0] CFG2 = 'd2;
    localparam logic [CFG_WIDTH-1:0] CFG3 = 'd3;
    localparam logic [CFG_WIDTH-1:0] CFG4 = 'd4;

    // Largeur du bus de contrôle NCO / loop_filter
    localparam int CTRL_WIDTH = 4;
    localparam int D_PHI_W = 8;
    // -----------------------------------------------------------------------
    // Signaux internes des sous-blocs
    // -----------------------------------------------------------------------

    // decision_block
    logic                           s_decision_sig;   // sortie du décodeur
    logic                           s_decision_out;   // registré sur recovered_clk

    // phase_detector
    logic                           s_pd_decision_in;
    logic                           s_pd_sample_clk;
    logic                           s_up;
    logic                           s_down;

    // loop_filter
    logic                           s_lf_up;
    logic                           s_lf_down;
    logic                           s_lf_ctrl_ack;
    logic signed [CTRL_WIDTH-1:0]   s_control;

    // NCO
    logic signed [CTRL_WIDTH-1:0]   s_nco_ctrl;
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
        if (i_cfg == CFG2) begin
            s_pd_decision_in = i_bus_b[1];
            s_pd_sample_clk  = i_bus_b[0];
            s_phase_detector_debug = 1'b1;
        end else begin
            // Chemin normal : sortie du décodeur + horloge récupérée du NCO
            s_phase_detector_debug = 1'b0;
        end

        // --- loop_filter ---
        // CFG3 : on injecte les stimuli de test directement
        if (i_cfg == CFG3) begin
            s_lf_up       = i_bus_b[2];
            s_lf_down     = i_bus_b[1];
            s_lf_ctrl_ack = i_bus_b[0];
            s_loop_filter_debug = 1'b1;
        end else begin
            // Chemin normal : sorties du phase_detector + ack du NCO
            s_loop_filter_debug = 1'b0;
        end

        // --- NCO ---
        // CFG4 : on injecte la commande de contrôle directement
        if (i_cfg == CFG4)
        begin
            s_nco_ctrl = signed'(i_bus_b[CTRL_WIDTH-1:0]);
            s_nco_debug = 1'b1;
        end
        else
        begin
            s_nco_ctrl = s_control;
            s_nco_debug = 1'b0;
        end

    end

    // -----------------------------------------------------------------------
    // Instanciation des sous-blocs
    // -----------------------------------------------------------------------

CDR_top#(.phase_resolution(D_PHI_W),.ctrl_width(CTRL_WIDTH)) u_CDR(.i_clk(i_clk),.i_rst_n(i_rst_n),.i_dphi(i_bus_b[D_PHI_W-1:0]),.o_data(),.o_enable(),.i_phase_detector_debug(s_phase_detector_debug), .i_loop_filter_debug(s_loop_filter_debug),.i_nco_debug(s_nco_debug),.i_recovered_clk_d(s_pd_sample_clk),.i_decision_d(s_pd_decision_in),.i_up_d(s_lf_up),.i_down_d(s_lf_down),.i_decision_sig_d(s_pd_decision_in),.i_ack_d(s_lf_ctrl_ack),.i_control_d(s_nco_ctrl));

    // Registre de décision (identique à CDR) : capture sur recovered_clk
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n)
            s_decision_out <= 1'b0;
        else if (s_recovered_clk)
            s_decision_out <= s_decision_sig;
    end

    // -----------------------------------------------------------------------
    // Mux de sortie
    // -----------------------------------------------------------------------
    always_comb begin
        unique case (i_cfg)

            CFG0: // Mode normal CDR : data + enable
                o_bus_c = {10'h0, u_CDR.o_data, u_CDR.o_enable};

            CFG1: // Debug décodeur : décision combinatoire
                o_bus_c = {11'h0, u_CDR.s_decision_sig};

            CFG2: // Test phase_detector isolé : up / down
                o_bus_c = {10'h0, u_CDR.s_up, u_CDR.s_down};

            CFG3: // Test loop_filter isolé : bus de contrôle
                o_bus_c = {11'h0, u_CDR.s_control};

            CFG4: // Test NCO isolé : enable + ack
                o_bus_c = {10'h0, u_CDR.s_decision_out, u_CDR.o_enable, u_CDR.s_ack};

            default:
                o_bus_c = 12'h0;

        endcase
    end

endmodule
