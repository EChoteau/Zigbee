module fir_top (
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic              i_adc_eoc,
    input  logic signed [7:0] i_x_in,
    output logic signed [7:0] o_y_out
);

    FIR_filter u_fir_filter (
        .i_clk       (i_clk),
        .i_rst_n     (i_rst_n),
        .i_adc_eoc   (i_adc_eoc),
        .i_inputData (i_x_in),
        .o_outputData(o_y_out)
    );

endmodule
