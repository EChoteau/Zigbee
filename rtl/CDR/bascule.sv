module bascule(i_ck, i_en, i_rst, i_D, o_Q);
    input wire i_ck, i_en, i_rst, i_D;
    output wire o_Q;

    `ifdef non_behaviour_model
        bascule_temp(.ck(i_ck),.clear(i_rst),.D(i_D),.Q(o_Q));
    `else
        reg s_en_d_pos, s_en_d_neg;  // mémorisation de i_en sur chaque front
        reg s_Q_pos,    s_Q_neg;     // sortie capturée sur chaque front

        // front montant
        always @(posedge i_ck or negedge i_rst) begin
            if (~i_rst) begin
                s_Q_pos    <= 1'b0;
                s_en_d_pos <= 1'b0;
            end
            else begin
                s_en_d_pos <= i_en;
                if (i_en & ~s_en_d_pos)
                    s_Q_pos <= i_D;
            end
        end

        // front descendant
        always @(negedge i_ck or negedge i_rst) begin
            if (~i_rst) begin
                s_Q_neg    <= 1'b0;
                s_en_d_neg <= 1'b0;
            end
            else begin
                s_en_d_neg <= i_en;
                if (i_en & ~s_en_d_neg)
                    s_Q_neg <= i_D;
            end
        end

        // mux double-edge : sélectionne selon le niveau courant de i_ck
        assign o_Q = i_ck ? s_Q_pos : s_Q_neg;

    `endif
endmodule
