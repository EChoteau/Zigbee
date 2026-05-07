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
        assign o_decision_out     =s_b;
        assign o_up           =(i_decision_in ^ s_a );
        assign o_down         = (s_a ^ s_b);

       endmodule
