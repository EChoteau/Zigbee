module interface_test_wrapper_example #(
    parameter int N_TEST_IN  = 24,
    parameter int N_TEST_OUT = 12,
    parameter int CFG_WIDTH  = 3
)(
    input  logic                       i_clk,
    input  logic                       i_rst_n,
    input  logic [CFG_WIDTH-1:0]       i_cfg_local,
    input  logic [N_TEST_IN-1:0]       i_test_in,
    output logic [N_TEST_OUT-1:0]      o_test_out
);

    localparam logic [CFG_WIDTH-1:0] CFG0 = 'd0;
    localparam logic [CFG_WIDTH-1:0] CFG1 = 'd1;
    localparam logic [CFG_WIDTH-1:0] CFG2 = 'd2;

    // Mini exemple: ce wrapper ne fait pas de traitement métier,
    // il montre seulement comment router des entrées/sorties selon la config.
    always_comb begin
        o_test_out = '0;

        unique case (i_cfg_local)
            CFG0: begin
                // Mode "classique": on ressort les N_TEST_OUT bits de poids faible.
                o_test_out = i_test_in[N_TEST_OUT-1:0];
            end

            CFG1: begin
                // Mode "debug": on ressort les N_TEST_OUT bits de poids fort.
                o_test_out = i_test_in[N_TEST_IN-1 -: N_TEST_OUT];
            end

            CFG2: begin
                // Mode "mix": moitié basse + moitié haute.
                if (N_TEST_OUT >= 2) begin
                    o_test_out[(N_TEST_OUT/2)-1:0] = i_test_in[(N_TEST_OUT/2)-1:0];
                    o_test_out[N_TEST_OUT-1:N_TEST_OUT/2] =
                        i_test_in[N_TEST_IN-1 -: (N_TEST_OUT - (N_TEST_OUT/2))];
                end else begin
                    o_test_out[0] = i_test_in[0];
                end
            end

            default: begin
                o_test_out = '0;
            end
        endcase
    end

endmodule
