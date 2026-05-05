
   `ifdef alexander_pd
    module alexander_phase_detector(i_clk,i_rst_n,i_sample_clk,i_decision_in,o_decision_out, o_up,o_down);
        //inout definition
         input wire  i_clk;
         input wire i_rst_n;
         input wire  i_decision_in;
         output wire o_decision_out;
         output wire o_up;
         output wire o_down;
         input wire i_sample_clk;
         
         logic s_a;
         logic s_b;
         logic s_c;
         //logic s_d;
         
         
         bascule b1(.i_ck(i_clk),.i_en( i_sample_clk),.i_rst(i_rst_n),.i_D(i_decision_in),.o_Q(s_a)); // transition
        bascule b2(.i_ck(i_clk),.i_en(~i_sample_clk),.i_rst(i_rst_n),.i_D(i_decision_in),.o_Q(s_b)); // milieu
        bascule b3(.i_ck(i_clk),.i_en( i_sample_clk),.i_rst(i_rst_n),.i_D(s_a),          .o_Q(s_c)); // transition précédente

assign o_decision_out = s_b;
assign o_up           = (s_a ^ s_b) & ~(s_b ^ s_c);  
assign o_down         = (s_b ^ s_c) & ~(s_a ^ s_b); 
       `endif
