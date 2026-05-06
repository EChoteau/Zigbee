`ifdef meghelli_pd
    module phase_detector(clk,rst,data_in,data_out, up,down);
        //inout definition
         input wire  clk;
         input wire  data_in;
         //output wire data_out;
         output wire up_down;
         //output wire late;
         logic a;
         logic b;
         logic c;// up_down
         always @(edge clk or negedge rst)
         if (rst==1b'0)
         begin 
         
         end
             begin 
                 if clk==1b'0
                 begin
                     a <= data_in;
                 end
                 else 
                 begin
                     r_data <= data_in;
                 end
             end
             
       endmodule
 `endif
