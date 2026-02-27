module cordic_init #(
    parameter WIDTH = 16
)(
    input  signed [WIDTH-1:0] I_in,
    input  signed [WIDTH-1:0] Q_in,
    output logic signed [WIDTH-1:0] I_init,
    output logic signed [WIDTH-1:0] Q_init,
    output logic signed [WIDTH-1:0] PHASE_init // Format Q1.15 (si WIDTH=16)
);

    // Constantes pour Phase: 0.5 et -0.5 en virgule fixe
    // 0.5 correspond à 2^(WIDTH-2)
    logic signed [WIDTH-1:0] PHASE_05  = (1 << (WIDTH-2));
    logic signed [WIDTH-1:0] PHASE_M05 = -(1 << (WIDTH-2));

    always_comb begin
        if (I_in >= 0) begin
            I_init     = I_in;
            Q_init     = Q_in;
            PHASE_init = 0;
        end else begin
            if (Q_in >= 0) begin
                // Quadrant 2: Rotation -90° (I_init = Q, Q_init = -I)
                I_init     = Q_in;
                Q_init     = -I_in;
                PHASE_init = PHASE_05;
            end else begin
                // Quadrant 3: Rotation +90° (I_init = -Q, Q_init = I)
                I_init     = -Q_in;
                Q_init     = I_in;
                PHASE_init = PHASE_M05;
            end
        end
    end

endmodule

