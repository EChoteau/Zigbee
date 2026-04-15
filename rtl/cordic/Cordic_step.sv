module cordic_step #(
    parameter int WIDTH = 16,
    parameter int WIDTH_PHASE = WIDTH + 2,
    parameter int ITER  = 0,
    parameter signed [WIDTH_PHASE-1:0] ANGLE_VAL = 16'h1234 
)(
    input  logic signed [WIDTH-1:0] i_i,
    input  logic signed [WIDTH-1:0] i_q,
    input  logic signed [WIDTH_PHASE-1:0] i_phase,
    output logic signed [WIDTH-1:0] o_i_next,
    output logic signed [WIDTH-1:0] o_q_next,
    output logic signed [WIDTH_PHASE-1:0] o_phase_next
);

    // Décalages arithmétiques
    wire signed [WIDTH-1:0] w_i_shr = i_i >>> ITER;
    wire signed [WIDTH-1:0] w_q_shr = i_q >>> ITER;

    // Décision basée sur le bit de signe de Q_in (Q_in[WIDTH-1] == 0 signifie Q >= 0)
    wire w_is_positive = !i_q[WIDTH-1];

    // Implémentation par Multiplexeurs (Opérateur ternaire)
    assign o_i_next     = w_is_positive ? (i_i + w_q_shr)     : (i_i - w_q_shr);
    assign o_q_next     = w_is_positive ? (i_q - w_i_shr)     : (i_q + w_i_shr);
    assign o_phase_next = w_is_positive ? (i_phase + ANGLE_VAL) : (i_phase - ANGLE_VAL);

endmodule

