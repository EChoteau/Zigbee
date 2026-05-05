module cordic_system #(
    parameter int WIDTH_IN = 6,
    parameter int FILTER_N = 5,
    parameter int WIDTH_PHASE = WIDTH_IN + 2,
    parameter bool INSIDE_WRAPPER = 0
    
)(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic signed [WIDTH_IN-1:0] i_i,
    input  logic signed [WIDTH_IN-1:0] i_q,
    output logic signed [WIDTH_PHASE-1:0] o_phase,

    // All intermediate signals for wrapper visibility
    // w_signal_module_out is signal that comes out of module and is used as input to next module
    // w_signal_module_in is signal that comes into the nextmodule and is driven by module
    output  logic signed [WIDTH_PHASE-1:0] o_phase_cordic,         // Output of cordic
    input   logic signed [WIDTH_PHASE-1:0] i_phase_to_derivative,   //input to derivate 
    output  logic signed [WIDTH_PHASE-1:0] o_phase_derivative,      // Output of derivative,
    input   logic signed [WIDTH_PHASE-1:0] i_phase_to_boxcar       // input to boxcar filter
);

	logic signed [WIDTH_IN-1:0] s_i_buf;
	logic signed [WIDTH_IN-1:0] s_q_buf;
    logic signed [WIDTH_PHASE-1:0] w_phase_cordic;
    logic signed [WIDTH_PHASE-1:0] w_phase_to_derivative;
    logic signed [WIDTH_PHASE-1:0] w_phase_derivative;
    logic signed [WIDTH_PHASE-1:0] w_phase_to_boxcar;

    assign o_phase_cordic       = w_phase_cordic;
    assign o_phase_derivative   = w_phase_derivative;
    
    // Si wrapper_flag == 1 : utilise inputs externes, sinon : utilise signaux internes
    assign w_phase_to_derivative = INSIDE_WRAPPER ? i_phase_to_derivative : w_phase_cordic;
    assign w_phase_to_boxcar     = INSIDE_WRAPPER ? i_phase_to_boxcar : w_phase_derivative;
    

    always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
	    s_q_buf <= '0;
        s_i_buf <= 'd1; // Avoid undefined phase at reset (arctan(0/0) is undefined, arctan(1/0) is 90 degrees)
	end else begin
	    s_q_buf <= i_q;
	    s_i_buf <= i_i;
	end
    end

    cordic_top #(
        .WIDTH_IN(WIDTH_IN),
        .WIDTH_PHASE(WIDTH_PHASE)
    ) cordic_top_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_i(s_i_buf), .i_q(s_q_buf),
        .o_phase(o_phase_cordic)
    );

    derivative #(
    	.WIDTH(WIDTH_PHASE)
    ) derivative_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_phase(w_phase_to_derivative),
        .o_phase_deriv(o_phase_derivative)
    );

    boxcar_filter #(
        .WIDTH(WIDTH_PHASE), 
        .N(FILTER_N)
    ) boxcar_filter_inst (
        .i_clk(i_clk), .i_rst_n(i_rst_n),
        .i_data(w_phase_to_boxcar), .o_data(o_phase)
    );

endmodule

