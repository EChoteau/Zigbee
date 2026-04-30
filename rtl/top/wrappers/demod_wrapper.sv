<<<<<<< HEAD
=======
// ============================================================================
// Module      : demod_wrapper
// Description : Test wrapper for the Demodulation system.
//               Provides injection via `i_bus_a` and observation via output buses.
//               Supports 8 configs (CFG_WIDTH=3) for selecting different
//               test points and modes within the demod chain.
// ============================================================================

>>>>>>> 2822042 (Add CDR, Demod, and MSK wrappers to zigbee_chip_top; update interface_wrapper for new debug signals)
module demod_wrapper #(
    parameter int CFG_WIDTH   = 3,
    parameter int BUS_A_WIDTH = 12,
    parameter int BUS_B_WIDTH = 10,
    parameter int BUS_C_WIDTH = 12,
    parameter int BUS_D_WIDTH = 2
)(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic [CFG_WIDTH-1:0] i_cfg,

<<<<<<< HEAD
    input  logic [BUS_A_WIDTH-1:0] i_bus_a, // unused
    input  logic [BUS_B_WIDTH-1:0] i_bus_b, // input 

    output logic [BUS_C_WIDTH-1:0] o_bus_c, //  output 
    output logic [BUS_D_WIDTH-1:0] o_bus_d // unused
);

=======
    input  logic [BUS_A_WIDTH-1:0] i_bus_a,
    input  logic [BUS_B_WIDTH-1:0] i_bus_b,
    output logic [BUS_C_WIDTH-1:0] o_bus_c,
    output logic [BUS_D_WIDTH-1:0] o_bus_d
);

    // ------------------------------------------------------------------
    // Configuration modes
    // ------------------------------------------------------------------
>>>>>>> 2822042 (Add CDR, Demod, and MSK wrappers to zigbee_chip_top; update interface_wrapper for new debug signals)
    localparam logic [2:0] MODE_0 = 3'b000;
    localparam logic [2:0] MODE_1 = 3'b001;
    localparam logic [2:0] MODE_2 = 3'b010;
    localparam logic [2:0] MODE_3 = 3'b011;
    localparam logic [2:0] MODE_4 = 3'b100;
    localparam logic [2:0] MODE_5 = 3'b101;
    localparam logic [2:0] MODE_6 = 3'b110;
    localparam logic [2:0] MODE_7 = 3'b111;

<<<<<<< HEAD
    // =========================================================
    // Découpage bus B
    // =========================================================
    // i_bus_b[7:4] = I test ADC 4 bits
    // i_bus_b[3:0] = Q test ADC 4 bits
    // i_bus_b[7:0] = entrée FIR test 8 bits

    logic [3:0]        s_test_i;
    logic [3:0]        s_test_q;
    logic signed [7:0] s_test_fir_in;

    assign s_test_i      = i_bus_b[7:4];
    assign s_test_q      = i_bus_b[3:0];
    assign s_test_fir_in = i_bus_b[7:0];

    // =========================================================
    // MUX entrée démodulateur
    // =========================================================

    logic [3:0] s_demod_i_in;
    logic [3:0] s_demod_q_in;

    always_comb begin
        s_demod_i_in = s_test_i;
        s_demod_q_in = s_test_q;

        unique case (i_cfg)

            // Test cos + demod I
            MODE_2: begin
                s_demod_i_in = s_test_i;
                s_demod_q_in = s_test_q;
            end

            // Test sin + demod Q
            MODE_3: begin
                s_demod_i_in = s_test_i;
                s_demod_q_in = s_test_q;
            end

            // Test chaîne complète côté I uniquement
            MODE_6: begin
                s_demod_i_in = s_test_i;
                s_demod_q_in = 4'b1000;
            end

            // Test chaîne complète côté Q uniquement
            MODE_7: begin
                s_demod_i_in = 4'b1000;
                s_demod_q_in = s_test_q;
            end

            default: begin
                s_demod_i_in = s_test_i;
                s_demod_q_in = s_test_q;
            end

        endcase
    end

    // =========================================================
    // Démodulateur
    // =========================================================

    logic signed [7:0] s_demod_out_i;
    logic signed [7:0] s_demod_out_q;

    logic signed [3:0] s_cos_test;
    logic signed [3:0] s_sin_test;

    IQ_DEMOD u_iqdemod (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),

        .i_I_in     (s_demod_i_in),
        .i_Q_in     (s_demod_q_in),

        .o_I_out    (s_demod_out_i),
        .o_Q_out    (s_demod_out_q),

        .o_cos_test (s_cos_test),
        .o_sin_test (s_sin_test)
    );

    // =========================================================
    // MUX entrée FIR
    // =========================================================

    logic signed [7:0] s_fir_i_in;
    logic signed [7:0] s_fir_q_in;

    always_comb begin
        s_fir_i_in = s_demod_out_i;
        s_fir_q_in = s_demod_out_q;

        unique case (i_cfg)

            // Test FIR uniquement côté I
            MODE_4: beginsim:/tb_demod_wrapper/o_bus_c

                s_fir_i_in = s_test_fir_in;
                s_fir_q_in = 8'sd0;
            end

            // Test FIR uniquement côté Q
            MODE_5: begin
                s_fir_i_in = 8'sd0;
                s_fir_q_in = s_test_fir_in;
            end

            default: begin
                s_fir_i_in = s_demod_out_i;
                s_fir_q_in = s_demod_out_q;
            end

        endcase
    end

    // =========================================================
    // FIR I / FIR Q
    // =========================================================

    logic signed [5:0] s_i_bb;
    logic signed [5:0] s_q_bb;

    fir_top u_fir_i (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_x_in  (s_fir_i_in),
        .o_y_out (s_i_bb)
    );

    fir_top u_fir_q (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_x_in  (s_fir_q_in),
        .o_y_out (s_q_bb)
    );

    // =========================================================
    // MUX sortie bus C
    // =========================================================

    always_comb begin
        o_bus_c = '0;
        o_bus_d = '0;

        unique case (i_cfg)

            // Test cos seul / cos + sortie I demod
            MODE_0: begin
                o_bus_c = {s_cos_test, s_demod_out_i};
            end

            // Test sin seul / sin + sortie Q demod
            MODE_1: begin
                o_bus_c = {s_sin_test, s_demod_out_q};
            end

            // Test cos + sortie I demod
            MODE_2: begin
                o_bus_c = {s_cos_test, s_demod_out_i};
            end

            // Test sin + sortie Q demod
            MODE_3: begin
                o_bus_c = {s_sin_test, s_demod_out_q};
            end

            // Test FIR I seul
            MODE_4: begin
                o_bus_c = {s_i_bb, s_q_bb};
            end

            // Test FIR Q seul
            MODE_5: begin
                o_bus_c = {s_i_bb, s_q_bb};
            end

            // Test chaîne complète côté I
            MODE_6: begin
                o_bus_c = {s_i_bb, s_q_bb};
            end

            // Test chaîne complète côté Q
            MODE_7: begin
                o_bus_c = {s_i_bb, s_q_bb};
            end

            default: begin
                o_bus_c = '0;
            end

        endcase

        o_bus_d = {s_i_bb[5], s_q_bb[5]};
=======
    // Default assignments - pass input bus A to output bus C
    always_comb begin
        o_bus_c = {{(BUS_C_WIDTH-BUS_A_WIDTH){1'b0}}, i_bus_a};
        o_bus_d = '0;

        unique case (i_cfg)
            MODE_0: begin
                // Default: pass through Bus A to Bus C
                o_bus_c = {{(BUS_C_WIDTH-BUS_A_WIDTH){1'b0}}, i_bus_a};
            end
            MODE_1: begin
                // Route Bus B to Bus C
                o_bus_c = {{(BUS_C_WIDTH-BUS_B_WIDTH){1'b0}}, i_bus_b};
            end
            MODE_2: begin
                // Combine Bus A and Bus B
                o_bus_c = {i_bus_b[BUS_C_WIDTH-BUS_A_WIDTH-1:0], i_bus_a[BUS_A_WIDTH-1:0]};
            end
            MODE_3: begin
                // Mirror Bus A to both upper and lower halves of Bus C
                o_bus_c = {i_bus_a[BUS_A_WIDTH-1:0], i_bus_a[BUS_A_WIDTH-1:0]};
            end
            MODE_4: begin
                // Inverted Bus A
                o_bus_c = {{(BUS_C_WIDTH-BUS_A_WIDTH){1'b0}}, ~i_bus_a};
            end
            MODE_5: begin
                // Shift Bus A left
                o_bus_c = {i_bus_a[BUS_A_WIDTH-2:0], 1'b0};
            end
            MODE_6: begin
                // Shift Bus A right
                o_bus_c = {{1{1'b0}}, i_bus_a[BUS_A_WIDTH-1:1]};
            end
            MODE_7: begin
                // All zeros
                o_bus_c = '0;
            end
        endcase
>>>>>>> 2822042 (Add CDR, Demod, and MSK wrappers to zigbee_chip_top; update interface_wrapper for new debug signals)
    end

endmodule
