module loop_filter #

(
    parameter WIDTH = 16
)

(
    input wire i_clk,
    input wire i_rst_n,

    input wire i_up,
    input wire i_down,

    output reg signed [WIDTH-1:0] o_ctrl
);
logic s_up_l,s_down_l;
always @(posedge i_clk or negedge i_rst_n) begin

    if (~i_rst_n)
    begin
        o_ctrl <= 0;
    end
    else begin
        //count<=count+1;
        //if(count==5'h18)
        //begin 
        //    count<=0;
            s_up_l <= i_up;
            s_down_l <= i_down;
            if (i_up & ~s_up_l)
                o_ctrl <= 32;

            else if (i_down & s_down_l)
                o_ctrl <=  - 32;
            else o_ctrl <= o_ctrl;
       // end
        

    end

end

endmodule
