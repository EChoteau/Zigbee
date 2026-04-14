`ifdef alexander_pd
    module phase_detector(clk,rst,sample,data_in,data_out, up,late);
        //inout definition
         input wire  clk;
         input wire rst;
         input wire  data_in;
         //output wire data_out;
         output wire early;
         output wire late;
         input wire sample;
         
         logic a;
         logic b;
         logic c;
         logic d;
         always @(edge clk or negedge rst) 
             begin
             if (~rst)
                begin 
                a   <=  1b'0;
                b   <=  1b'0;
                c   <=  1b'0;
                d   <=  1b'0;
                end
             else if (sample==1'b1)
                begin 
                 if clk ==1b'0
                     begin 
                        b <=data_in;
                     end
                 else 
                     begin 
                         a <= data_in;
                         c <=a;
                         d <=b;
                     end
                 end
              end
         assign up      = c ^ a;
         assign down    = b ^ c;
       endmodule
 `endif
