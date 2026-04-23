    module phase_detector(i_clk,i_rst_n,i_sample_clk,i_decision_in,o_decision_out, o_up,o_down);
        //inout definition
         input wire  i_clk;
         input wire i_rst_n,i_sample_clk;
         input wire  i_decision_in;
         output wire o_decision_out;
         output wire o_up,o_down;
         
         logic s_a;
         logic s_b;
         logic s_sample_p;
         
         bascule b0(.i_ck(i_clk),.i_en(i_sample_clk),.i_rst(i_rst_n),.i_D(i_decision_in), .o_Q(s_a));
         bascule b1(.i_ck(i_clk),.i_en(~i_sample_clk),.i_rst(i_rst_n),.i_D(s_a), .o_Q(s_b));
         /*
         always @(edge i_clk or negedge i_rst_n)
             begin 
                 if (i_rst_n== 1'b0)
                 begin
                    s_a<=1'b0;
                    s_b<=1'b0;
                 end
                 else begin
                    s_sample_p <= i_sample_clk;
                    if ( s_sample_p==1'b0 && i_sample_clk ==1'b1 ) 
                    begin 
                         s_a <= i_decision_in;
                     end
                    else if( s_sample_p==1'b1 && i_sample_clk ==1'b0 )
                    begin
                        s_b <= s_a;
                     end
                     else
                     begin 
                        s_a<=s_a;
                        s_b<=s_b;
                     end
                 end
             end
             */
        assign o_decision_out     =s_b;
        assign o_up           =(i_decision_in ^ s_a );
        assign o_down         = (s_a ^ s_b);

       endmodule
