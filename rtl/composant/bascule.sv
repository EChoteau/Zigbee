module bascule(ck,rst,D,Q);
    input wire ck,rst,D;
    output reg Q;
    `ifdef behaviour_model
        always @(posedge ck or posedge rst)
            begin
            if (rst ==1'b0)
                begin
                    Q <=1'b0;
                end
            else
                begin
                    Q <=D;
                end
            end
    
    `else
        bascule_temp(.ck(ck),.clear(rst),.D(D),.Q(Q)); // instentiation à voir
    `endif
endmodule
