

module cdr_top
  #(parameter phase_resolution=6) (i_clk,i_rst_n,i_dphi, o_data,o_enable);
   input wire 		       	i_clk;
   input wire 			i_rst_n;
   input  wire [phase_resolution-1:0] 	i_dphi;
   output wire 		       	o_data;
   output wire 		      	o_enable;
   wire s_recovered_clk;
   wire 		       	s_decision;
   wire			s_decision_out;
   wire s_up;
   wire s_down;
   wire s_decision_sig;
   wire signed [7:0] s_control;

   
    decision_block u_dec (.i_dphi_in(i_dphi),.o_decision_out(s_decision_sig));

   phase_detector u_pd(.i_clk(i_clk),.i_sample_clk(s_recovered_clk),.i_rst_n(i_rst_n),.i_decision_in(s_decision_sig),.o_decision_out(s_decision_out),.o_up(s_up),.o_down(s_down));
    loop_filter #(.WIDTH(8)) u_lf (.i_clk(i_clk),.i_rst_n(i_rst_n),.i_up(s_up),.i_down(s_down),.o_ctrl(s_control));
   nco u_nco (.i_clk(i_clk),.i_rst_n(i_rst_n),.i_ctrl(s_control),.o_sample_enable(o_enable),.o_recovered_clk(s_recovered_clk));
   assign o_data =s_decision_out;

endmodule
