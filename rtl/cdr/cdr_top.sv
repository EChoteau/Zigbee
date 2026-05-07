

module cdr_top #(
    parameter int phase_resolution = 6,
    parameter int ctrl_width = 4
) (
    input  logic                          i_clk,
    input  logic                          i_rst_n,
    input  logic [phase_resolution-1:0]   i_dphi,
    output logic                          o_data,
    output logic                          o_enable,
    output logic                          o_decision,
    output logic                          o_up,
    output logic                          o_down,
    output logic                          o_ack,
    output logic                          o_recovered_clk,
    output logic signed [ctrl_width-1:0]  o_ctrl,
    
    // Debug control signals
    input  logic                          i_phase_detector_debug,
    input  logic                          i_loop_filter_debug,
    input  logic                          i_nco_debug,
    
    // Forced debug inputs
    input  logic                          i_recovered_clk_d,
    input  logic                          i_decision_d,
    input  logic                          i_up_d,
    input  logic                          i_down_d,
    input  logic                          i_ack_d,
    input  logic signed [ctrl_width-1:0]  i_control_d
);

    // ==========================================================================
    // INTERNAL SIGNALS
    // ==========================================================================
    logic                          s_decision;
    logic                          s_decision_out;
    logic signed [ctrl_width-1:0]  s_control;
    
    // Phase detector debug mux
    logic s_sample_clk;
    logic s_decision_in;
    
    // Loop filter debug mux
    logic s_ctrl_ack;
    logic s_up_in;
    logic s_down_in;
    
    // NCO debug mux
    logic signed [ctrl_width-1:0] s_control_in;
    
    // ==========================================================================
    // DEBUG MULTIPLEXERS
    // ==========================================================================
    assign s_sample_clk  = (i_phase_detector_debug) ? i_recovered_clk_d : o_recovered_clk;
    assign s_decision_in = (i_phase_detector_debug) ? i_decision_d : o_decision;
    
    assign s_ctrl_ack    = (i_loop_filter_debug) ? i_ack_d : o_ack;
    assign s_up_in       = (i_loop_filter_debug) ? i_up_d : o_up;
    assign s_down_in     = (i_loop_filter_debug) ? i_down_d : o_down;
    
    assign s_control_in  = (i_nco_debug) ? i_control_d : s_control;
    
    // ==========================================================================
    // DECISION OUTPUT REGISTER
    // ==========================================================================
    always @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n)
            s_decision_out <= 1'b0;
        else if (s_sample_clk)
            s_decision_out <= o_decision;
    end
    
    assign o_data = s_decision_out;
    
    // ==========================================================================
    // MODULE INSTANTIATIONS
    // ==========================================================================
    
    decision_block #(
        .resolution_in(phase_resolution)
    ) u_decision (
        .i_dphi_in(i_dphi),
        .o_decision_out(o_decision)
    );
    
    phase_detector u_phase_detector (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_sample_clk(s_sample_clk),
        .i_decision_in(s_decision_in),
        .o_decision_out(),
        .o_up(o_up),
        .o_down(o_down)
    );
    
    loop_filter #(
        .WIDTH(ctrl_width)
    ) u_loop_filter (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_up(s_up_in),
        .i_down(s_down_in),
        .i_ctrl_ack(s_ctrl_ack),
        .o_ctrl(s_control)
    );
    
    nco #(
        .CTRL_W(ctrl_width)
    ) u_nco (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_ctrl(s_control_in),
        .o_recovered_clk(o_recovered_clk),
        .o_sample_enable(o_enable),
        .o_ctrl_ack(o_ack)
    );

endmodule
