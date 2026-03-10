module loop_filter #

(
    parameter WIDTH = 16
)

(
    input wire clk,
    input wire rst,

    input wire up,
    input wire down,

    output reg signed [WIDTH-1:0] ctrl
);
reg[4:0] count;

always @(posedge clk or negedge rst) begin

    if (~rst)
    begin
        ctrl <= 0;
        count<=0;
    end
    else begin
        //count<=count+1;
        //if(count==5'h18)
        //begin 
        //    count<=0;
            if (up)
                ctrl <= ctrl + 10;

            else if (down)
                ctrl <= ctrl - 10;
            else ctrl <= ctrl;
       // end
        

    end

end

endmodule
