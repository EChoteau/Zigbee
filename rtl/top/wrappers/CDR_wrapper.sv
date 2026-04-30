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

    input  logic [BUS_A_WIDTH-1:0] i_bus_a, // LSB used
    input  logic [BUS_B_WIDTH-1:0] i_bus_b, // unused
    output logic [BUS_C_WIDTH-1:0] o_bus_c,  // LSB used
    output logic [BUS_D_WIDTH-1:0] o_bus_d   // unused
);

    localparam logic [CFG_WIDTH-1:0] CFG0 = 'd0;
    localparam logic [CFG_WIDTH-1:0] CFG1 = 'd1;
    localparam logic [CFG_WIDTH-1:0] CFG2 = 'd2;
    localparam logic [CFG_WIDTH-1:0] CFG3 = 'd3;
    localparam logic [CFG_WIDTH-1:0] CFG4 = 'd4;

    // Largeur du bus de contrôle NCO / loop_filter
    localparam int CTRL_WIDTH = 2;

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
    always_comb begin

        // --- phase_detector ---
        // CFG2 : on injecte les stimuli de test directement
        if (i_cfg == CFG2) begin
            s_pd_decision_in = i_test_in[BUS_B_WIDTH-1];
            s_pd_sample_clk  = i_test_in[BUS_B_WIDTH-2];
        end else begin
            // Chemin normal : sortie du décodeur + horloge récupérée du NCO
            s_pd_decision_in = s_decision_sig;
            s_pd_sample_clk  = s_recovered_clk;
        end

        // --- loop_filter ---
        // CFG3 : on injecte les stimuli de test directement
        if (i_cfg == CFG3) begin
            s_lf_up       = i_test_in[BUS_B_WIDTH-1];
            s_lf_down     = i_test_in[BUS_B_WIDTH-2];
            s_lf_ctrl_ack = i_test_in[BUS_B_WIDTH-3];
        end else begin
            // Chemin normal : sorties du phase_detector + ack du NCO
            s_lf_up       = s_up;
            s_lf_down     = s_down;
            s_lf_ctrl_ack = s_ack;
        end

        // --- NCO ---
        // CFG4 : on injecte la commande de contrôle directement
        if (i_cfg == CFG4)
            s_nco_ctrl = signed'(i_test_in[CTRL_WIDTH-1:0]);
        else
            s_nco_ctrl = s_control;

    end

    // -----------------------------------------------------------------------
    // Instanciation des sous-blocs
    // -----------------------------------------------------------------------

    decision_block #(
        .resolution_in (N_TEST_IN)
    ) u_dec (
        .i_clk          (i_clk),
        .i_rst_n        (i_rst_n),
        .i_dphi_in      (i_test_in),      // toujours piloté par i_test_in
        .o_decision_out (s_decision_sig)
    );

    phase_detector u_pd (
        .i_clk         (i_clk),
        .i_rst_n       (i_rst_n),
        .i_sample_clk  (s_pd_sample_clk),
        .i_decision_in (s_pd_decision_in),
        .o_up          (s_up),
        .o_down        (s_down)
    );

    loop_filter #(
        .WIDTH (CTRL_WIDTH)
    ) u_lf (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_up       (s_lf_up),
        .i_down     (s_lf_down),
        .i_ctrl_ack (s_lf_ctrl_ack),
        .o_ctrl     (s_control)
    );

    nco #(
        .CTRL_W (CTRL_WIDTH)
    ) u_nco (
        .i_clk           (i_clk),
        .i_rst_n         (i_rst_n),
        .i_ctrl          (s_nco_ctrl),
        .o_sample_enable (s_sample_enable),
        .o_recovered_clk (s_recovered_clk),
        .o_ctrl_ack      (s_ack)
    );

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
        o_test_out = '0;
        unique case (i_cfg)

            CFG0: // Mode normal CDR : data + enable
                o_bus_c = {{BUS_C_WIDTH-3{1'b0}}, s_decision_out, s_sample_enable};

            CFG1: // Debug décodeur : décision combinatoire
                o_bus_c = {{BUS_C_WIDTH-2{1'b0}}, s_decision_sig};

            CFG2: // Test phase_detector isolé : up / down
                o_bus_c = {{BUS_C_WIDTH-3{1'b0}}, s_up, s_down};

            CFG3: // Test loop_filter isolé : bus de contrôle
                o_bus_c = {{BUS_C_WIDTH-CTRL_WIDTH-1{1'b0}}, s_control};

            CFG4: // Test NCO isolé : data + enable + ack
                o_bus_c = {{BUS_C_WIDTH-4{1'b0}}, s_decision_out, s_sample_enable, s_ack};

            default:
                o_test_out = '0;

        endcase
    end

endmodule
