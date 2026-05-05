    // used phase detector : hogge
    module phase_detector(i_clk,i_rst_n,i_sample_clk,i_decision_in,o_decision_out, o_up,o_down);
        //inout definition
         input wire  i_clk;
         input wire i_rst_n,i_sample_clk;
         input wire  i_decision_in;
         output wire o_decision_out;
         output wire o_up,o_down;
        `ifdef hogge_pd
            hogge_phase_detector u_hpd(.i_clk(i_clk),.i_rst_n(i_rst_n),.i_sample_clk(i_sample_clk),.i_decision_in(i_decision_in),.o_decision_out(o_decision_out),.o_up(o_up),.o_down(o_down));
         `else 
         `ifdef alexander_pd
            alexander_phase_detector u_apd (.i_clk(i_clk),.i_rst_n(i_rst_n),.i_sample_clk(i_sample_clk),.i_decision_in(i_decision_in),.o_decision_out(o_decision_out),.o_up(o_up),.o_down(o_down));
        `endif
        `endif
       endmodule
