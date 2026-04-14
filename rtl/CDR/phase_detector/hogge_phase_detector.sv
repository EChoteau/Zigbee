`ifdef hogge_pd
    module phase_detector(clk,rst,data_in,data_out, up,down);
        //inout definition
         input wire  clk;
         input wire  data_in;
         //output wire data_out;
         output wire up_down;
         //output wire late;
         
         logic a;
         logic b;
         always @(edge clk or negedge rst)
             begin 
                 if (rst== 1b'0)
                 begin
                    a<=1b'0;
                    b<=1b'0;
                 end
                 else begin
                    if clk ==1b'1;
                    begin 
                     a <= data_in;
                     end
                    else
                    begin
                     b <= a;
                     end
                 end
             end
        assign data_out     =a;
        assign up           =data ^ a;
        assign down         = a ^ b;
       endmodule
 `endif
