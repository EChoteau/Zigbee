module cdr_wrapper #(
    parameter int CFG_WIDTH      = 3,
    parameter int BUS_IN_WIDTH   = 22,
    parameter int BUS_OUT_WIDTH  = 14
) (
    input  logic                          i_clk,
    input  logic                          i_rst_n,
    input  logic [CFG_WIDTH-1:0]          i_cfg,
    input  logic                          i_out_en,
    input  logic [BUS_IN_WIDTH-1:0]       i_bus_in,
    output logic [BUS_OUT_WIDTH-1:0]      o_bus_out
);

    localparam logic [CFG_WIDTH-1:0] CFG0 = 3'b000;
    localparam logic [CFG_WIDTH-1:0] CFG1 = 3'b001;
    localparam logic [CFG_WIDTH-1:0] CFG2 = 3'b010;
    localparam logic [CFG_WIDTH-1:0] CFG3 = 3'b011;
    localparam logic [CFG_WIDTH-1:0] CFG4 = 3'b100;

    localparam int CTRL_WIDTH = 4;
    localparam int D_PHI_W = 8;

    // ====================================================================
    // Input bus decoding (22 bits)
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
    // Signaux internes
    // -----------------------------------------------------------------------
    logic                           s_decision_sig;
    logic                           s_pd_decision_in_internal;
    logic                           s_pd_sample_clk_internal;
    logic                           s_up;
    logic                           s_down;
    logic                           s_lf_up_internal;
    logic                           s_lf_down_internal;
    logic                           s_lf_ctrl_ack_internal;
    logic signed [CTRL_WIDTH-1:0]   s_control;
    logic signed [CTRL_WIDTH-1:0]   s_nco_ctrl_internal;
    logic                           s_recovered_clk;
    logic                           s_sample_enable;
    logic                           s_ack;

    logic s_phase_detector_debug, s_loop_filter_debug, s_nco_debug;

    always_comb begin
        s_pd_decision_in_internal = w_pd_decision_in;
        s_pd_sample_clk_internal  = w_pd_sample_clk;
        s_phase_detector_debug    = (i_cfg == CFG2);

        s_lf_up_internal       = w_lf_up;
        s_lf_down_internal     = w_lf_down;
        s_lf_ctrl_ack_internal = w_lf_ctrl_ack;
        s_loop_filter_debug    = (i_cfg == CFG3);

        s_nco_ctrl_internal = w_nco_ctrl;
        s_nco_debug         = (i_cfg == CFG4);
    end

    // -----------------------------------------------------------------------
    // Instanciation du TOP
    // -----------------------------------------------------------------------
    logic signed [CTRL_WIDTH-1:0] s_ctrl;
    logic                         s_data;

    cdr_top#(
        .phase_resolution(D_PHI_W),
        .ctrl_width(CTRL_WIDTH)
    ) u_cdr(  
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
    // Mux de sortie (14 bits)
    // -----------------------------------------------------------------------
    always_comb begin
        o_bus_out = '0; 

        if (i_out_en) begin
            unique case (i_cfg)
                CFG0: o_bus_out[1:0] = {s_data, s_sample_enable};
                CFG1: o_bus_out[0]   = s_decision_sig;
                CFG2: o_bus_out[1:0] = {s_up, s_down};
                CFG3: o_bus_out[CTRL_WIDTH-1:0] = s_control;
                CFG4: o_bus_out[2:0] = {s_data, s_sample_enable, s_ack};
                default: o_bus_out = '0;
            endcase
        end
    end

endmodule