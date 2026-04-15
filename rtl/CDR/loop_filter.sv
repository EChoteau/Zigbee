module loop_filter #

(
    parameter WIDTH = 16
)

(
    input wire clk,
    input wire rst,

    input wire up,
    input wire down,

    output reg signed [7:0] ctrl
);
logic up_l,down_l;
always @(posedge clk or negedge rst) begin

    if (~rst)
    begin
        ctrl <= 0;
    end
    else begin
        //count<=count+1;
        //if(count==5'h18)
        //begin 
        //    count<=0;
            up_l <= up;
            down_l <= down;
            if (up & ~up_l)
                ctrl <= 109;

            else if (down & down_l)
                ctrl <= -101;
            else ctrl <= ctrl;
       // end
        

    end

end

endmodule
