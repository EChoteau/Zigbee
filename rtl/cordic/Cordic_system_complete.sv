module cordic_system_complete #(
    parameter int WIDTH_IN = 8,
    parameter FILTER_N = 8,
    int WIDTH_PHASE = WIDTH_IN + 2,
    parameter int OUT_WIDTH = WIDTH_PHASE + $clog2(FILTER_N)
    
)(
    input  logic clk,
    input  logic rst_n,
    input  logic signed [WIDTH_IN-1:0] I_in,
    input  logic signed [WIDTH_IN-1:0] Q_in,
    output logic signed [OUT_WIDTH-1:0] Phase_out
);

    logic signed [WIDTH_PHASE-1:0] phase_cordic;
    logic signed [WIDTH_PHASE-1:0] phase_deriv;
	logic signed [WIDTH_IN-1:0] I_in_buf;
	logic signed [WIDTH_IN-1:0] Q_in_buf;

    always_ff @(posedge clk) begin
       	Q_in_buf <= Q_in;
	I_in_buf <= I_in;
    end

    cordic_top #(
        .WIDTH_IN(WIDTH_IN),
        .WIDTH_PHASE(WIDTH_PHASE)
    ) cordic_top_inst (
        .clk(clk),
        .rst_n(rst_n),
        .I_in(I_in_buf), .Q_in(Q_in_buf),
        .Phase_out(phase_cordic)
    );

    derivative #(
    	.WIDTH(WIDTH_PHASE)
    ) derivative_inst (
        .clk(clk),
        .rst_n(rst_n),
        .phase_in(phase_cordic),
        .phase_deriv(phase_deriv)
    );

    boxcar_filter #(
        .WIDTH(WIDTH_PHASE), 
        .N(FILTER_N)
    ) boxcar_filter_inst (
        .clk(clk), .rst_n(rst_n),
        .data_in(phase_deriv), .data_out(Phase_out)
    );

endmodule

