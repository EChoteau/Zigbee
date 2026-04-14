module bascule(ck,en,rst,D,Q);
    input wire ck,en,rst,D;
    output reg Q;
    reg en_d;
    `ifdef non_behaviour_model
    
        bascule_temp(.ck(ck),.clear(rst),.D(D),.Q(Q));
     `else
        always @(posedge ck or negedge rst)
            begin
            if (~rst)
                begin
                    Q <=1'b0;
                end
            else
                begin
                en_d <=en;
                if(en & ~en_d)
                begin
                    Q <=D;
                    end
                end
            end
      `endif
endmodule
