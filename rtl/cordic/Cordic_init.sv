module cordic_init #(
    parameter WIDTH_IN = 16,
    parameter WIDTH_PHASE = WIDTH_IN + 2,
    parameter WIDTH_INTERNAL = WIDTH_IN + 4 // +3 LSB bits, +1 MSB bit
)(
    input  signed [WIDTH_IN-1:0] I_in,
    input  signed [WIDTH_IN-1:0] Q_in,
    output logic signed [WIDTH_INTERNAL-1:0] I_init,
    output logic signed [WIDTH_INTERNAL-1:0] Q_init,
    output logic signed [WIDTH_PHASE-1:0] PHASE_init // Format Q1.15 (si WIDTH=16)
);

    // Constantes pour Phase: 0.5 et -0.5 en virgule fixe
    // 0.5 correspond   2^(WIDTH-2)
    localparam logic signed [WIDTH_PHASE-1:0] PHASE_05  = (1 << (WIDTH_PHASE-2));
    localparam logic signed [WIDTH_PHASE-1:0] PHASE_M05 = -(1 << (WIDTH_PHASE-2));

    // Internal helper signals for bit-growth conversion
    // We sign-extend the input then shift left by 3 to add LSBs
    logic signed [WIDTH_INTERNAL-1:0] I_ext, Q_ext;

    // Elaboration-time check: enforce internal width relationship to keep scaling consistent
    initial begin
        if (WIDTH_INTERNAL != WIDTH_IN + 4) begin
            $fatal(1, "cordic_init: WIDTH_INTERNAL (%0d) must equal WIDTH_IN + 4 (%0d) to preserve internal scaling.",
                      WIDTH_INTERNAL, WIDTH_IN + 4);
        end
    end
    
    always_comb begin
        // Perform sign extension and LSB padding
        // SystemVerilog automatically sign-extends during the cast/assignment
        I_ext = (WIDTH_INTERNAL)'(I_in) << 3;
        Q_ext = (WIDTH_INTERNAL)'(Q_in) << 3;

        if (I_in >= 0) begin
            I_init     = I_ext;
            Q_init     = Q_ext;
            PHASE_init = 0;
        end else begin
            if (Q_in >= 0) begin
                // Quadrant 2: Rotation -90
                I_init     = Q_ext;
                Q_init     = -I_ext;
                PHASE_init = PHASE_05;
            end else begin
                // Quadrant 3: Rotation +90
                I_init     = -Q_ext;
                Q_init     = I_ext;
                PHASE_init = PHASE_M05;
            end
        end
    end

endmodule

