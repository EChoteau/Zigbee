
module bascule (
    input  logic  i_ck,
    input  logic  i_en,
    input  logic  i_rst,
    input  logic  i_D,
    output logic  o_Q
);

    logic s_en_d;      // i_en delayed by one cycle
    logic s_enable;    // rising edge of i_en
    logic s_D_mux;     // D with hold if no enable

    // Rising edge detection of i_en
    assign s_enable = i_en & ~s_en_d;

    // Mux on input D: capture i_D on edge, hold otherwise
    assign s_D_mux = s_enable ? i_D : o_Q;

    // Behavioral model (standard)
    logic s_en_d_r, o_Q_r;
    assign s_en_d = s_en_d_r;
    assign o_Q = o_Q_r;

    always_ff @(posedge i_ck or negedge i_rst) begin
        if (~i_rst) begin
            s_en_d_r <= 1'b0;
            o_Q_r <= 1'b0;
        end
        else begin
            s_en_d_r <= i_en;
            o_Q_r <= s_D_mux;
        end
    end

endmodule
