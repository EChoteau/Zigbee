module bascule(i_ck, i_en, i_rst, i_D, o_Q);
    input wire i_ck, i_en, i_rst, i_D;
    output wire o_Q;

    wire s_en_d;      // i_en retardé d'un cycle
    wire s_enable;    // flanc montant de i_en
    wire s_D_mux;     // D avec maintien si pas d'enable

    // détection du flanc montant de i_en
    assign s_enable = i_en & ~s_en_d;

    // mux sur l'entrée D : capture i_D sur flanc, maintien sinon
    assign s_D_mux  = s_enable ? i_D : o_Q;

    `ifdef non_behaviour_model
        // FF1 : mémorise i_en
        DFC1 u_ff1 (.C(i_ck), .RN(i_rst), .D(i_en),   .Q(s_en_d));

        // FF2 : capture i_D quand enable, maintien sinon
        DFC1 u_ff2 (.C(i_ck), .RN(i_rst), .D(s_D_mux), .Q(o_Q));
    `else
        // modèle comportemental équivalent
        reg s_en_d_r, o_Q_r;
        assign s_en_d = s_en_d_r;
        assign o_Q    = o_Q_r;

        always @(posedge i_ck or negedge i_rst) begin
            if (~i_rst) begin
                s_en_d_r <= 1'b0;
                o_Q_r    <= 1'b0;
            end
            else begin
                s_en_d_r <= i_en;
                o_Q_r    <= s_D_mux;
            end
        end
    `endif

endmodule
