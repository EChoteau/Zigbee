module bascule(i_ck,i_en,i_rst,i_D,o_Q);
    input wire i_ck,i_en,i_rst,i_D;
    output reg o_Q;
    reg s_en_d;
    `ifdef non_behaviour_model
    
        bascule_temp(.ck(i_ck),.clear(i_rst),.D(i_D),.Q(i_Q));
     `else
        always @(posedge i_ck or negedge i_rst)
            begin
            if (~i_rst)
                begin
                    o_Q <=1'b0;
                end
            else
                begin
                s_en_d <= i_en;
                if(i_en & ~s_en_d)
                begin
                    o_Q <=i_D;
                    end
                end
            end
      `endif
endmodule
