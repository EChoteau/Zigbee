module cordic_system_complete #(
    parameter int WIDTH_IN = 8,
    parameter FILTER_N = 8,
    int WIDTH_PHASE = WIDTH_IN + 2,
    parameter int OUT_WIDTH = WIDTH_PHASE + $clog2(FILTER_N)
    
)(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic signed [WIDTH_IN-1:0] i_i_in,
    input  logic signed [WIDTH_IN-1:0] i_q_in,
    output logic signed [OUT_WIDTH-1:0] o_phase_out
);

    logic signed [WIDTH_PHASE-1:0] w_phase_cordic;
    logic signed [WIDTH_PHASE-1:0] w_phase_deriv;
	logic signed [WIDTH_IN-1:0] s_i_in_buf;
	logic signed [WIDTH_IN-1:0] s_q_in_buf;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
	    s_q_in_buf <= '0;
	    s_i_in_buf <= '0;
	end else begin
	    s_q_in_buf <= i_q_in;
	    s_i_in_buf <= i_i_in;
	end
    end

    cordic_top #(
        .WIDTH_IN(WIDTH_IN),
        .WIDTH_PHASE(WIDTH_PHASE)
    ) cordic_top_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_i_in(s_i_in_buf), .i_q_in(s_q_in_buf),
        .o_phase_out(w_phase_cordic)
    );

    derivative #(
    	.WIDTH(WIDTH_PHASE)
    ) derivative_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_phase_in(w_phase_cordic),
        .o_phase_deriv(w_phase_deriv)
    );

    boxcar_filter #(
        .WIDTH(WIDTH_PHASE), 
        .N(FILTER_N)
    ) boxcar_filter_inst (
        .i_clk(i_clk), .i_rst_n(i_rst_n),
        .i_data_in(w_phase_deriv), .o_data_out(o_phase_out)
    );

endmodule

