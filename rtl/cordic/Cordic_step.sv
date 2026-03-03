module cordic_step #(
    parameter int WIDTH = 16,
    parameter int WIDTH_PHASE = WIDTH + 2,
    parameter int ITER  = 0,
    parameter signed [WIDTH_PHASE-1:0] ANGLE_VAL = 16'h1234 
)(
    input  logic signed [WIDTH-1:0] I_in,
    input  logic signed [WIDTH-1:0] Q_in,
    input  logic signed [WIDTH_PHASE-1:0] PHASE_in,
    output logic signed [WIDTH-1:0] I_next,
    output logic signed [WIDTH-1:0] Q_next,
    output logic signed [WIDTH_PHASE-1:0] PHASE_next
);

    // Décalages arithmétiques
    wire signed [WIDTH-1:0] i_shr = I_in >>> ITER;
    wire signed [WIDTH-1:0] q_shr = Q_in >>> ITER;

    // Décision basée sur le bit de signe de Q_in (Q_in[WIDTH-1] == 0 signifie Q >= 0)
    wire is_positive = !Q_in[WIDTH-1];

    // Implémentation par Multiplexeurs (Opérateur ternaire)
    assign I_next     = is_positive ? (I_in + q_shr)     : (I_in - q_shr);
    assign Q_next     = is_positive ? (Q_in - i_shr)     : (Q_in + i_shr);
    assign PHASE_next = is_positive ? (PHASE_in + ANGLE_VAL) : (PHASE_in - ANGLE_VAL);

endmodule

